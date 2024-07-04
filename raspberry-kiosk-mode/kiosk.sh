#!/bin/bash

# ========
# SETTINGS
# ========
HOSTNAME=raspberry-kiosk
IP_ADDRESS=192.168.1.100
GATEWAY=192.168.1.1
SERVICE_HOST=192.168.1.200
SERVICE_ACCOUNT=student
URL=http://ipconfig.me

# ======
# CHECKS
# ======
echo "> checks"

echo ">> permission check"
if [ $EUID != 0 ]; then
    echo "ERROR: Please run as root"
    exit
fi

echo ">> internet access check"
ping -c 1 -W 1 dns.google > /dev/null
NETWORK_CHECK=$?
if [ $NETWORK_CHECK != 0 ] ; then
    echo "ERROR: no internet Access - check your connectivity settings and try again"
    exit
fi

echo ">> raspbian version check"
grep -P ".*Raspbian.*10.*" /etc/os-release > /dev/null
OS_VERSION_CHECK=$?
if [ $OS_VERSION_CHECK != 0 ]; then
  echo "INFO: this script was tested under Raspbian 10"
fi

echo ">> raspberry model check"
grep -a "Raspberry Pi 3 Model B Rev 1.2" /proc/device-tree/model > /dev/null
RP_VERSION_CHECK=$?
if [ $RP_VERSION_CHECK != 0 ]; then
  echo "INFO: this script was tested with a Raspberry Pi 3 Model B Rev 1.2"
fi

# ACKNOWLEDGE PROBLEMS TO CONTINUE
if [ $OS_VERSION_CHECK != 0 ] || [ $RP_VERSION_CHECK != 0 ]; then
  echo ""
  while true; do
    read -p "Are you sure you want to continue [y/n]?" ANSWER
    case $ANSWER in
      [Yy]* ) break;;
      [Nn]* ) exit;;
      * ) echo "Please enter yes or no [y/n]";;
    esac
  done
fi

# =============
# GENERAL SETUP
# =============
echo "> general setup"

echo ">> set hostname"
sed -i "s/raspberrypi/$HOSTNAME/g" /etc/hosts /etc/hostname

echo ">> configure IP address"
sed -i "s/^#static ip_address=192.168.1.23\/24/static ip_address=$IP_ADDRESS\/24/g" /etc/dhcpcd.conf
sed -i "s/^#static routers=192.168.1.1/static routers=$GATEWAY/g" /etc/dhcpcd.conf
sed -i "s/^#static domain_name_servers=192.168.1.1/static domain_name_servers=8.8.8.8 1.1.1.1/g" /etc/dhcpcd.conf

echo ">> setup iptables"
iptables -F
ip6tables -F
iptables -A INPUT -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i eth0 -m state --state NEW -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -i eth0 -p icmp --icmp-type 8 -j ACCEPT
iptables -A INPUT -i eth0 -j DROP
ip6tables -A INPUT -i eth0 -j DROP
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt-get -qq install iptables-persistent -y > /dev/null
mkdir -p /etc/iptables/
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

echo ">> configure hosts.allow"
echo "sshd : $SERVICE_HOST" >> /etc/hosts.allow
echo "sshd : ALL" >> /etc/hosts.deny

echo ">> enable ssh service"
systemctl enable ssh -q
service ssh start -q

echo ">> enable overscan"
sed -i "s/disable_overscan=1/disable_overscan=0/g" /boot/config.txt

# ======================
# EXTEND LIFE OF SD-CARD
# ======================
echo "> sd-card specific settings"

echo ">> turn off swap"
swapoff -a
apt-get -qq purge dphys-swapfile -y > /dev/null
update-rc.d dphys-swapfile remove

echo ">> disable syslog"
systemctl disable rsyslog -q
systemctl stop rsyslog -q

echo ">> add ramdisk for partitions with a heavy write load"
echo "tmpfs /tmp tmpfs defaults,noatime,nosuid 0 0" >> /etc/fstab
echo "tmpfs /var/log tmpfs defaults,noatime,nosuid,size=20m 0 0" >> /etc/fstab

# ================
# SYSTEM HARDENING
# ================
echo "> system hardening"

echo ">> disable unnecessary services (avahi-daemon, bluetooth, wifi)"
systemctl disable autologin@tty1 -q
echo "dtoverlay=disable-bt" >> /boot/config.txt
echo "dtoverlay=disable-wifi" >> /boot/config.txt

echo ">> delete unnecessary software"
apt-get -qq purge wolfram-engine libreoffice libreoffice-common minecraft-pi bluej geany greenfoot nodered scratch scratch2 sense-hat sense-emu-tools sonic-pi python3-thonny realvnc-vnc-server realvnc-vnc-viewer avahi-daemon -y > /dev/null
apt-get -qq autoremove -y > /dev/null

echo ">> add service account"
useradd -d /home/$SERVICE_ACCOUNT -m $SERVICE_ACCOUNT -G sudo -s /bin/bash
passwd $SERVICE_ACCOUNT

echo ">> add kiosk account"
useradd -d /home/kiosk -m kiosk
sed -i "s/--autologin pi/--autologin kiosk/g" /etc/systemd/system/autologin\@.service
sed -i "s/^autologin-user=pi/autologin-user=kiosk/g" /etc/lightdm/lightdm.conf
userdel -r -f pi 2> /dev/null

echo ">> disable usb ports"
# see also https://github.com/mvp/uhubctl#raspberry-pi-4b
apt-get -qq install libusb-1.0-0-dev -y > /dev/null
cd /root
git clone --quiet https://github.com/mvp/uhubctl > /dev/null
cd uhubctl
make
make install
uhubctl -a off -l 1-1 -p 2-5 -r 100
sed -i "19i\uhubctl -a off -l 1-1 -p 2-5 -r 100" /etc/rc.local

# =========
# AUTOSTART
# =========
echo "> autostart"

echo ">> setup autostart for chromium-browser"
apt-get -qq install unclutter -y > /dev/null
AUTOSTART="/etc/xdg/lxsession/LXDE-pi/autostart"
sed -i "s/^@xscreensaver -no-splash/#@xscreensaver -no-splash/g" $AUTOSTART
sed -i "s/^@point-rpi/#@point-rpi/g" $AUTOSTART
echo "@xset s off" >> $AUTOSTART
echo "@xset -dpms" >> $AUTOSTART
echo "@xset s noblank" >> $AUTOSTART
echo "@sed -i 's/\"exited_cleanly\":false/\"exited_cleanly\":true/' /home/kiosk/.config/chromium/Default/Preferences" >> $AUTOSTART
echo "@chromium-browser --noerrdialogs --kiosk $URL --incognito --disable-translate" >> $AUTOSTART

# ======
# REBOOT
# ======
echo "> rebooting in 10 seconds"
sleep 10
reboot
