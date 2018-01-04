#!/bin/sh
# Icinga Diagnostics
# Collect basic data about your Icinga 2 installation
# maintainer: Thomas Widhalm <thomas.widhalm@icinga.com>
# Original source: https://github.com/widhalmt/icinga2-diagnostics

VERSION=0.0

echo "### Icinga 2 Diagnostics ###"
echo "# Version: ${VERSION}"
echo "# Run on $(hostname) at $(date)"
echo ""

### VARIABLES ###

## Static variables ##

OPTSTR="fht"

TIMESTAMP=$(date +%Y%m%d)
UNAME_S=$(uname -s)

# The GnuPG key used for signing packages in the Icinga repository
ICINGAKEY="c6e319c334410682"

## Computed variables ##

if [ "$(id -u)" != "0" ]; then
  echo "Not running as root. Not all checks might be successful"
  RUNASROOT=false
else
  echo "Running as root"
  RUNASROOT=true
fi

if [ $(which systemctl 2>/dev/null) ]
then
  SYSTEMD=true
fi

if [ -f "/etc/redhat-release" ]
then
  QUERYPACKAGE="rpm -q"
  OS="REDHAT"
  OSVERSION="$(cat /etc/redhat-release)"
elif [ -f "/etc/debian_version" ]
then
  QUERYPACKAGE="dpkg -l"
  OS="$(grep ^NAME /etc/os-release | cut -d\" -f2)"
  OSVERSION="${OS} $(cat /etc/debian_version)"
elif [ "${UNAME_S}" = "FreeBSD" ]
then
  QUERYPACKAGE="pkg info"
  OS="${UNAME_S}"
  PREFIX="/usr/local"
  uname -srm 
elif [ -f "/etc/SuSE-release" ]
then
  QUERYPACKAGE="rpm -q"
  OS="SuSE"
  OSVERSION="${OS} $(cat /etc/SuSE-release)"
else
  lsb_release -irs
fi

### Functions ###

show_help() {
  echo "

  Usage:
  -f add full Icinga 2 configuration to output (use with -t)
  -h show this help
  -t create a tarball instead of just printing the output
  "
  exit 0
}

check_service() {
  if [ "${SYSTEMD}" = "true" ]
  then
    systemctl is-active $1
  else
    service $1 status > /dev/null && echo "active" || echo "inactive"
  fi
}

doc_icinga2() {
  echo ""

  # query all installed packages with "icinga" in their name
  # check every package whether it was signed with the GnuPG key of the icinga team
  echo "Packages:"
  case "${OS}" in
    REDHAT)
      for i in $(rpm -qa | grep icinga)
      do
        rpm -qi $i | grep ^Name | cut -d: -f2
        rpm -qi $i | grep Version
        if [ "$(rpm -qi $i | grep ^Signature | cut -d, -f3 | awk '{print $3}')" = "${ICINGAKEY}" ]
        then
          echo "Signed with Icinga key";
        else
          echo "Not signed with Icinga Key, might be original anyway";
        fi
      done
      ;;
    FreeBSD) ${QUERYPACKAGE} -x icinga ;;
    *) echo "Can not query packages on ${OS}" ;;
  esac

  # rpm -q --queryformat '%|DSAHEADER?{%{DSAHEADER:pgpsig}}:{%|RSAHEADER?{%{RSAHEADER:pgpsig}}:{%|SIGGPG?{%{SIGGPG:pgpsig}}:{%|SIGPGP?{%{SIGPGP:pgpsig}}:{(none)}|}|}|}|\n\' icinga2

  echo ""
  echo "Features:"
  icinga2 feature list

  # change the IFS variable to have whitespaces not split up items in a `for i in` loop.
  # this is to be used because some zone-names might contain whitespaces
  SAVEIFS=${IFS}
  IFS=$(printf "\n\b")
  echo ""
  echo "Zones and Endpoints:"
  for i in $(icinga2 object list --type zone | grep ^Object | cut -d\' -f2)
  do
    echo $i
    icinga2 object list --type Zone --name $i | grep -e 'endpoints =' -e 'parent =' -e 'global =' | grep -v -e '= null' -e '= false' -e '= ""'
  done
  IFS=${SAVEIFS}

  echo ""
  # count how often every check interval is used. This helps with getting an overview and finding misconfigurations
  # * are there lots of different intervals? -> Users might get confused
  # * very high or very low intervals -> could mean messed up units (e.g.: s instead of m)
  # * many different intervals? -> could lead to problems with graphs
  echo "Check intervals:"
  icinga2 object list --type Host | grep check_interval | sort | uniq -c | sort -rn
  icinga2 object list --type Service | grep check_interval | sort | uniq -c | sort -rn

}

doc_icingaweb2() {

  echo ""
  echo "Packages:"
  ${QUERYPACKAGE} icingaweb2
  if [ "${UNAME_S}" = "FreeBSD" ]; then
    ${QUERYPACKAGE} -x php
    ${QUERYPACKAGE} -x apache
    ${QUERYPACKAGE} -x nginx
    ${QUERYPACKAGE} -g '*sql*-server'
  else
    ${QUERYPACKAGE} php
  fi
  if [ "${OS}" = "REDHAT" ]
  then
    ${QUERYPACKAGE} httpd
  else
    echo "Can not query webserver package on ${OS}"
  fi

  echo ""
  echo "Icinga Web 2 Modules:"
  # Add options for modules in other directories
  icingacli module list
  for i in $(icingacli module list | grep -v ^MODULE | awk '{print $1}')
  do
    if [ -d ${PREFIX}/usr/share/icingaweb2/modules/$i/.git ]
    then
      echo "$i via git - $(cd ${PREFIX}/usr/share/icingaweb2/modules/$i && git log -1 --format=\"%H\")"
    else
      echo "$i via release archive/package"
    fi
  done

  echo ""
  echo "Icinga Web 2 commandtransport configuration:"
  cat ${PREFIX}/etc/icingaweb2/modules/monitoring/commandtransports.ini

}

doc_firewall() {
  echo -n "Firewall: "

  if [ "$1" = "f" ]
  then  
    if [ "${RUNASROOT}" = "true" ]
    then
      case "${UNAME_S}" in
        Linux) iptables -nvL ;;
        FreeBSD)
          pfctl -s rules 2>/dev/null
          ipfw show 2>/dev/null
          ;;
        *) ;;
      esac
    else
      echo "# Can not read firewall configuration without root permissions #"
    fi
  else
    if [ "${SYSTEMD}" = "true" ]
    then
      check_service firewalld
    else
      check_service iptables
    fi
  fi 
}

doc_os() {

  echo ""
  echo "## OS ##"
  echo ""
  echo -n "OS Version: "

  echo ${OSVERSION}

  echo -n "Hypervisor: "

  case "${UNAME_S}" in
    Linux)
      VIRT=$(bash virt-what 2>/dev/null)

      if [ -z "${VIRT}" ]
      then
        echo "Running on hardware or unknown hypervisor"
      else
        if [ "$(echo ${VIRT} | awk '{print $1}')" = "xen" ]
        then
          if [ "$(echo ${VIRT} | awk '{print $2}')" = "xen-dom0" ]
          then
            VIRTUAL=false
          else
            VIRTUAL=true
            HYPERVISOR="Xen"
          fi
        elif [ "$(echo ${VIRT} | awk '{print $1}')" = "kvm" ]
        then
          VIRTUAL=true
          HYPERVISOR="KVM"
        elif [ "$(echo ${VIRT} | awk '{print $1}')" = "vmware" ]
        then
          VIRTUAL=true
          HYPERVISOR="VMware"
        elif [ "$(echo ${VIRT} | awk '{print $1}')" = "virtualbox" ]
        then
          # see https://github.com/Icinga/icinga2-diagnostics/issues/1 for why this still needs some tests
          VIRTUAL=true
          HYPERVISOR="VirtualBox"
        elif [ "$(echo ${VIRT} | awk '{print $1}')" = "bhyve" ]
        then
          VIRTUAL=true
          HYPERVISOR="bhyve"
        elif [ "$(echo ${VIRT} | awk '{print $1}')" = "vmm" ]
        then
          VIRTUAL=true
          HYPERVISOR="vmm"
        else
          VIRTUAL=false
        fi

      fi
      ;;
    FreeBSD)
      VIRT="$(sysctl -n kern.vm_guest)" 
      VIRTUAL=true
      case "${VIRT}" in 
        none)          VIRTUAL=false ;;
        generic|bhyve) HYPERVISOR=byhve ;;
        xen)           HYPERVISOR=Xen ;;
        hv)            HYPERVISOR=Hyper-V ;;
        vmware)        HYPERVISOR=VMware ;;
        kvm)           HYPERVISOR=KVM ;;
        *) ;; #XXX
      esac
      ;;
    *) ;; # XXX
  esac

  if [ "${VIRTUAL}" = "false" -o -z "${VIRTUAL}" ]
  then
    if [ "${RUNASROOT}" = "true" ]
    then
      echo "Running on Hardware or unknown Hypervisor"
    else
      echo "Insufficient permissions to check Hypervisor"
    fi
  else
    echo "Running virtually on a ${HYPERVISOR} hypervisor"
  fi

  #dmidecode | grep -i vmware
  #lspci | grep -i vmware
  #grep -q ^flags.*\ hypervisor\ /proc/cpuinfo && echo "This machine is a VM"

  case "${UNAME_S}" in
    Linux)
      echo -n "CPU cores: "
      cat /proc/cpuinfo | grep ^processor | wc -l
      echo -n "RAM: "
      if [ "${OS}" = "SuSE" ]
      then
        free -g | grep ^Mem | awk '{print $2"G"}'
      else
        free -h | grep ^Mem | awk '{print $2}'
      fi
      ;;
    FreeBSD)
      echo -n "CPU cores: "
      sysctl -n hw.ncpu
      echo -n "RAM: "
      echo $(expr $(sysctl -n hw.physmem) / 1024 / 1024) MB
      ;;
    *) ;;
  esac

  if [ "${OS}" = "REDHAT" ]
  then
    echo -n "SELinux: "
    getenforce
  fi

  ## troubleshooting SELinux for Icinga 2
  #semodule -l | grep -e icinga2 -e nagios -e apache
  #ps -eZ | grep icinga2
  #semanage port -l | grep icinga2
  #getsebool -a | grep icinga2
  #audit2allow -li /var/log/audit/audit.log

  doc_firewall
}

create_tarball() {
  OUTPUTDIR=$(mktemp -dt ic_diag.XXXXX)
  # run this diagnostics script again and print it's output into the tarball
  if [ "${FULL}" = true ]
  then
    $0 -f > ${OUTPUTDIR}/icinga_diagnostics
  else
    $0 > ${OUTPUTDIR}/icinga_diagnostics
  fi
  tar -cjf /tmp/icinga-diagnostics_$(hostname)_${TIMESTAMP}.tar.bz2 ${OUTPUTDIR}/* 2>/dev/null
  chmod 0600 /tmp/icinga-diagnostics_$(hostname)_${TIMESTAMP}.tar.bz2
  echo "Your tarball is ready at: /tmp/icinga-diagnostics_$(hostname)_${TIMESTAMP}.tar.bz2"
  exit 0
}

### Main ###


while getopts ${OPTSTR} SWITCHVAR
do
  case ${SWITCHVAR} in
    f) FULL=true;;
    h) show_help;;
    t) create_tarball;;
  esac
done

doc_os

echo ""
echo "# Icinga 2 #"
echo ""
${QUERYPACKAGE} icinga2 > /dev/null
if [ $? -eq 0 ]
then
  doc_icinga2
else
  echo "Icinga 2 is not installed"
fi

echo ""
echo "# Icinga Web 2 #"
echo ""
${QUERYPACKAGE} icingaweb2 > /dev/null
if [ $? -eq 0 ]
then
  doc_icingaweb2
else
  echo "Icinga Web 2 is not installed"
fi


