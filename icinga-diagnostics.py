# Icinga Diagnostics
# Collect basic data about your Icinga 2 installation
# maintainer: Thomas Widhalm <thomas.widhalm@icinga.com>
# Original source: https://github.com/icinga/icinga2-diagnostics

# ToDo:
# socket.gethostname just get's the short name. getfqdn return localhost

import os
import socket
from datetime import datetime
import getpass
import platform
import sys
import multiprocessing
import subprocess

version="0.2.0"
timestamp=datetime.now()

class Oshost:
    def __init__(self):
        self.os = platform.system()
        if self.os != "Linux":
            self.distro = "n/a"
        else:
            hostnamectl_output = str(subprocess.check_output(["hostnamectl"])).splitlines()
            for line in hostnamectl_output:
                if "Operating System" in line:
                    self.distro = line.split(':')[1]
        self.pythonversion = sys.version.split('\n')[0]
        self.cpucores = multiprocessing.cpu_count()
        self.memory = (os.sysconf('SC_PAGE_SIZE') * os.sysconf('SC_PHYS_PAGES'))//(1024.**3)


# print header

print("""### Icinga Diagnostics ###
# Version: """ + version + """
# Run on """ + socket.gethostname() + " at " + timestamp.strftime("%Y-%m-%d %H:%M:%S"))

# check whether we are running as root or not

if str(getpass.getuser()) != "root":
    print("""
    Not running as root. Not all checks might be successful
    """)
    runasroot = False

### OS information ###

icingahost = Oshost()

print("""### OS ###
        """)

if icingahost.os != "Linux":
    print("OS: " + icingahost.os)
else:
    print("OS: " + icingahost.distro)
print("Python: " + icingahost.pythonversion)
print("CPU cores: " + str(icingahost.cpucores))
print("RAM: " + str(icingahost.memory) + " Gi")

