# icinga2-diagnostics ##
A script to gather valuable data for providing to support engineer

This script is mostly intended as tool for support engineers. If a user reports a problem, the output of the scripts should cover the most common questions a support engineer will have.

The intention is not to collect as much data as possible but collect what is helpful in most cases and providing an overview whithout drowning support in too much data.

**Please note:** Even though this script is meant to just collect really useful data, it does still collect a lot. Browse through any output before you send it so that you don't send any confidential data without noticing.

**Please note as well:** The main intention of the script is to provide data *when asked for it*. While it might be helpful when working with commercial support, sending unwanted big blobs of data into community channels might lower your chances of getting help. Always try the [troubleshooting section](https://www.icinga.com/docs/icinga2/latest/doc/15-troubleshooting/) of the Icinga 2 documentation before requesting any community help. The upcoming "suggestion mode" of this script might help with troubleshooting as well.

Later versions might include options to collect this "usually helpful" set of data or lots of data for deep diving (e.g. whole logfiles, etc.)

## Usage ##

This script has several different modes:

* Default mode: Give a quick overview over your setup for professional or community support
* Tarball mode: Create a tarball of the configuration of your setup for thorough investigation by professional support
* Suggestion mode: Search things to improve and possible problems and give advice (still to be implemented)

If your setup consists of multiple hosts you can run on it on every node to get a more thorough overview. If you have e.g. dedicated nodes for graphing the script will work and only analyse the tools you installed on the node. (Although details about Graphers are still missing)

### Default Mode ###

Just use the script without any parameter.

    # ./icinga-diagnostics.sh

### Tarball Mode ###

Just run the script with the `-t` parameter.

    # ./icinga-diagnostics.sh -t

**Be aware that this collects your whole configuration including passwords, etc. Think before you send this to someone!**

The script will thell you where you can find your tarball when it's finished. You can still remove data from the tarball before sending it to someone.

### Extra options ###

* -z : Calculate zones with their endpoints (very time consuming on large setups)
* -g : add `gdb` output

`gdb` Output is only useful for debugging problems in the Icinga 2 binary, not for configuration problems. For `gdb` to work you have to install `gdb` and the "degbugging symbols" for all the programs you want to have their information added. e.g. for Icinga 2 the corresponding package is `icinga2-debuginfo` on RedHat/CentOS or `icinga2-dbg` on Debian or Ubuntu. In addition you will need the `icinga-gdb` file containing the `gdb` commands in the directory where icinga2-diagnostics resides.

## Icinga 2 configuration ##

In the folder `debug-configuration` you find a sample configuration file you can place in a zone where you have problems with executing checks with Icinga. This will create some services that check for the presence of some script interpreters including version and include paths on the host. You will get extra services showing you the user and other data about this specific host.

This is especially helpful if you have problems with finding the reason why a specific check is not able to be executed. A common situation is that you can run a check as `root` or `icinga` user via shell but the Icinga daemon can't.

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

    # ./icinga-diagnostics.sh 
    ### Icinga 2 Diagnostics ###
    # Version: 0.0
    # Run on icinga2 at Thu Jan 11 18:02:14 UTC 2018
    
    Running as root
    
    ## OS ##
    
    OS Version: CentOS Linux release 7.4.1708 (Core)
    Hypervisor: Running virtually on a VirtualBox hypervisor
    CPU cores: 2
    RAM: 1.8G
    SELinux: Permissive
    Firewall: inactive
    
    # Icinga 2 #
    
    ## Packages: ##
    
    Icinga 2  Version     : 2.8.0.187.g025abc3
    
    Done checking packages. See Anomaly section if something odd was found.
    
    Features:
    Disabled features: command compatlog elasticsearch gelf influxdb livestatus opentsdb perfdata statusdata syslog
    Enabled features: api checker debuglog graphite ido-mysql mainlog notification
    
    Check intervals:
         88   * check_interval = 300, Host
          1   * check_interval = 60, Host
        113   * check_interval = 60, Service
         13   * check_interval = 30, Service
          5   * check_interval = 5, Service
          3   * check_interval = 300, Service
    
    Used commands (numbers are relative to each other, not showing configured objects):
      28093 /etc/icinga2/scripts/mail-service-notification.sh
      14120 /usr/lib64/nagios/plugins/check_mysql_health
      10146 /usr/lib64/nagios/plugins/check_http
       6428 /usr/lib64/nagios/plugins/check_ping
       4396 /usr/lib64/nagios/plugins/check_load
       3415 /usr/lib64/nagios/plugins/check_ssh
       1758 /usr/lib64/nagios/plugins/check_dns
       1758 /usr/lib64/nagios/plugins/check_disk
        880 /usr/lib64/nagios/plugins/check_procs
        879 /usr/lib64/nagios/plugins/check_users
        879 /usr/lib64/nagios/plugins/check_swap
        528 /usr/bin/icingacli
    
    information/cli: Icinga application loader (version: v2.8.0-187-g025abc3)
    information/cli: Loading configuration file(s).
    information/ConfigItem: Committing config item(s).
    information/ApiListener: My API identity: icinga2
    warning/globals.getHostGeoLocation: Cannot find 'be' in GeoLocationShort
    warning/ApplyRule: Apply rule 'many-dummy' (in /etc/icinga2/demo/many.conf: 36:1-36:39) for type 'Notification' does not match anywhere!
    warning/ApplyRule: Apply rule 'many-dummy' (in /etc/icinga2/demo/many.conf: 41:1-41:42) for type 'Notification' does not match anywhere!
    warning/ApplyRule: Apply rule 'many-test-0' (in /etc/icinga2/demo/many.conf: 16:3-16:32) for type 'Service' does not match anywhere!
    warning/ApplyRule: Apply rule 'many-test-1' (in /etc/icinga2/demo/many.conf: 16:3-16:32) for type 'Service' does not match anywhere!
    warning/ApplyRule: Apply rule 'many-test-2' (in /etc/icinga2/demo/many.conf: 16:3-16:32) for type 'Service' does not match anywhere!
    information/ConfigItem: Instantiated 1 ApiListener.
    information/ConfigItem: Instantiated 3 Zones.
    information/ConfigItem: Instantiated 1 Endpoint.
    information/ConfigItem: Instantiated 4 ApiUsers.
    information/ConfigItem: Instantiated 2 FileLoggers.
    information/ConfigItem: Instantiated 28 Notifications.
    information/ConfigItem: Instantiated 1 UserGroup.
    information/ConfigItem: Instantiated 2 Users.
    information/ConfigItem: Instantiated 203 CheckCommands.
    information/ConfigItem: Instantiated 3 NotificationCommands.
    information/ConfigItem: Instantiated 4 HostGroups.
    information/ConfigItem: Instantiated 1 IcingaApplication.
    information/ConfigItem: Instantiated 89 Hosts.
    information/ConfigItem: Instantiated 3 TimePeriods.
    information/ConfigItem: Instantiated 134 Services.
    information/ConfigItem: Instantiated 3 ServiceGroups.
    information/ConfigItem: Instantiated 1 CheckerComponent.
    information/ConfigItem: Instantiated 1 GraphiteWriter.
    information/ConfigItem: Instantiated 1 IdoMysqlConnection.
    information/ConfigItem: Instantiated 1 NotificationComponent.
    information/ScriptGlobal: Dumping variables to file '/var/cache/icinga2/icinga2.vars'
    information/cli: Finished validating the configuration file(s).
    
    # Icinga Web 2 #
    
    
    Packages:
    icingaweb2-2.5.0.2.g890013c-0.2017.11.28+2.el7.icinga.noarch
    package php is not installed
    httpd-2.4.6-67.el7.centos.6.x86_64
    
    Icinga Web 2 Modules:
    MODULE         VERSION   STATE     DESCRIPTION
    businessprocess 2.1.0     enabled   A Business Process viewer and modeler
    cube           1.0.1     enabled   Cube for Icinga Web 2
    director       1.3.2     enabled   Director - Config tool for Icinga 2
    doc            2.5.0     enabled   Documentation module
    grafana        1.1.10    enabled   Grafana - A perfdata visualisation module
    map            1.0.4     enabled   Map - Visualize your hosts and service status
    monitoring     2.5.0     enabled   Icinga monitoring module
    
    businessprocess via git - "00e2f1886a9b07244e8dad237776b629fad59c0a"
    cube via git - "7ba3feb71601fd2433e0b787ea87dddf53878e49"
    director via git - "c4a97692df23e428a2eb6f1be41a7c25ea7b19a4"
    doc via release archive/package
    grafana via git - "5ba8995a15fb4b1e72232e3dffd4b45c6bb89ab8"
    map via git - "ec7fed3e4085f98f6f30f3557d85d5ed498e2a7d"
    monitoring via release archive/package
    
    Icinga Web 2 commandtransport configuration:
    [icinga 2 api localhost]
    transport = "api"
    host = "localhost"
    port = "5665"
    username = "icingaweb2"
    password = MASKED
    
    Director is release 1.3.2
    Director was installed as a git clone
    
    # Anomalies found #
    
    * Director is installed but no release archive was used for installation. (Please note that it still could the code of a release)
