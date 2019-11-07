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

version="0.2.0"
timestamp=datetime.now()

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

print("""### OS ###
        """)

# try to figure out which os we are running on

## The old way
#if os.path.isfile("/etc/redhat-release"):
#    print("OS Version: " + )
#    isredhat = True

os_system = platform.system()

if os_system != "Linux":
    print("OS: " + os_system)
else:
    print("OS: " + platform.linux_distribution()[0] + " " + platform.linux_distribution()[1])
print("Python: " + sys.version.split('\n')[0])
print("CPU cores: " + str(multiprocessing.cpu_count()))
print("RAM: " + str((os.sysconf('SC_PAGE_SIZE') * os.sysconf('SC_PHYS_PAGES'))//(1024.**3)) + " Gi")
#import subprocess
#subprocess.call(["ls", "-l"])

