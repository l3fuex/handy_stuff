# RaspberryPi kiosk mode

This script sets up a RaspberryPi with a freshly installed Raspbian in kiosk mode to be used in public accessible locations for example as info screen. For the setup internet access is needed as software packages will be installed.

The script does the following:
+ sets a hostname
+ configures an IP address
+ sets up iptables
+ changes hosts.allow
+ enables ssh
+ varios stuff to extend life of SD card
+ disables services like bluetooth and wifi
+ adds a service account
+ adds a kiosk account
+ disable usb ports
+ autostarts chromium-browser after the next reboot

**BEFORE RUNNING THE SCRIPT CHANGE THE SETUP VARIABLES ACCORINGLY:**
```
HOSTNAME=<hostname of the raspberry>
IP_ADDRESS=<IP address of the raspberry>
GATEWAY=<network gateway>
SERVICE_HOST=<IP of your machine from where you want to access the raspberry with ssh>
SERVICE_ACCOUNT=<a service account name for ssh access>
URL=<URL to be displayed in chromium-browser after reboot>
```
