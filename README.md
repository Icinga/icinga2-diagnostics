# icinga2-diagnostics ##
A script to gather valuable data for providing to support engineer

This script is mostly intended as tool for support engineers. If a user reports a problem, the output of the scripts should cover the most common questions a support engineer will have.

The intention is not to collect as much data as possible but collect what is helpful in most cases and providing an overview whithout drowning support in too much data.

Later versions might include options to collect this "usually helpful" set of data or lots of data for deep diving (e.g. whole logfiles, etc.)

## Usage ##

This script has several different modes:

* Default mode: Give a quick overview over your setup for professional or community support
* Tarball mode: Create a tarball of the configuration of your setup for thorough investigation by professional support
* Suggestion mode: Search things to improve and possible problems and give advice (still to be implemented)

### Default Mode ###

Just use the script without any parameter.

    # ./icinga-diagnostics.sh

### Tarball Mode ###

Just run the script with the `-t` parameter.

    # ./icinga-diagnostics.sh -t

**Be aware that this collects your whole configuration including passwords, etc. Think before you send this to someone!**

The script will thell you where you can find your tarball when it's finished. You can still remove data from the tarball before sending it to someone.

## Currently supported systems ##

The script currently works on the following operating systems:

* RHEL/CentOS/Oracle Linux/Scientific Linux
* SLES (thanks, wnieder)
* FreeBSD (thanks, @larsengels)
* Debian (still some functionality is missing)

The script currently works with the following software components:

* Icinga 2
* Icinga Web 2

## Planned supported systems ##

The script should work on all Operating systems supported by Icinga 2

The script should gather informations about the most common addons to Icinga 2 and collect data relevant to monitoring setups.

e.g.

* MariaDB/MySQL
* PostgresSQL
* Graphite
* PNP4Nagios
* InfluxDB
* Elasticsearch
* Logstash

# Example output #

This is an abrreviated output from a run on a [Icinga 2 Vagrant box](https://github.com/Icinga/icinga-vagrant)

    ### Icinga 2 Diagnostics ###
    # Version: 0.0
    # Run on icinga2 at Tue Jan  2 11:14:52 UTC 2018
    
    Running as root
    
    ## OS ##
    
    OS Version: CentOS Linux release 7.4.1708 (Core) 
    Hypervisor: Running virtually on a VirtualBox hypervisor
    CPU cores: 2
    RAM: 1.8G
    SELinux: Permissive
    Firewall: unknown
    
    # Icinga 2 #
    
    
    Packages:
     icingacli
    Version     : 2.5.0.2.g890013c
    Signed with Icinga key
     icingaweb2-vendor-HTMLPurifier
    Version     : 2.5.0.2.g890013c
    Signed with Icinga key
     icingaweb2
    Version     : 2.5.0.2.g890013c
    Signed with Icinga key
    [...]
    Features:
    Disabled features: command compatlog elasticsearch gelf influxdb livestatus opentsdb perfdata statusdata syslog
    Enabled features: api checker debuglog graphite ido-mysql mainlog notification
    
    Zones and Endpoints:
    director-global
      * global = true
    global-templates
      * global = true
    icinga2
      * endpoints = [ "icinga2" ]
    
    Check intervals:
         88   * check_interval = 300
          1   * check_interval = 60
        113   * check_interval = 60
         13   * check_interval = 30
          5   * check_interval = 5
          3   * check_interval = 300
    
    # Icinga Web 2 #
    
    
    Packages:
    icingaweb2-2.5.0.2.g890013c-0.2017.11.28+2.el7.icinga.noarch
    package php is not installed
    httpd-2.4.6-67.el7.centos.6.x86_64
    
    Icinga Web 2 Modules:
    MODULE         VERSION   STATE     DESCRIPTION
    businessprocess 2.1.0     enabled   A Business Process viewer and modeler
    director       master    enabled   Director - Config tool for Icinga 2
    doc            2.5.0     enabled   Documentation module
    monitoring     2.5.0     enabled   Icinga monitoring module
    
    businessprocess via git - "00e2f1886a9b07244e8dad237776b629fad59c0a"
    director via git - "c825d0b441ae9a57e70ea53ccee464bf35c78aba"
    doc via release archive/package
    monitoring via release archive/package
    
    Icinga Web 2 commandtransport configuration:
    [icinga 2 api localhost]
    transport = "api"
    host = "localhost"
    port = "5665"
    username = "icingaweb2"
    [...]


