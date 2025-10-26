#!/bin/bash

# Installs net-snmp package from source with strong encryption support and without snmp-agent.

apt install gcc make libperl-dev libssl-dev -y
wget https://sourceforge.net/projects/net-snmp/files/net-snmp/5.9.1/net-snmp-5.9.1.tar.gz
tar -xf net-snmp-5.9.1.tar.gz
cd net-snmp-5.9.1
./configure \
  --with-default-snmp-version="3" \
  --with-sys-contact="@@no.where" \
  --with-sys-location="Unknown" \
  --with-logfile="/var/log/snmpd" \
  --with-persistent-directory="/var/net-snmp" \
  --enable-blumenthal-aes \
  --disable-agent 
make
make install
