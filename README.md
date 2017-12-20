# icinga2-diagnostics ##
A script to gather valuable data for providing to support engineer

This script is mostly intended as tool for support engineers. If a user reports a problem, the output of the scripts should cover the most common questions a support engineer will have.

The intention is not to collect as much data as possible but collect what is helpful in most cases and providing an overview whithout drowning support in too much data.

Later versions might include options to collect this "usually helpful" set of data or lots of data for deep diving (e.g. whole logfiles, etc.)

## Currently supported systems ##

The script currently works on the following operating systems:

* RHEL/CentOS/Oracle Linux/Scientific Linux

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
