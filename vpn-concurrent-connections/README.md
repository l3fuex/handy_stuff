# Monitor concurrent VPN connections

In the following is outlined how to monitor concurrent VPN users on a Checkpoint Firewall with snmp (pull) using a newly created OID combined with a script that is triggered every time the OID is requested.

+ Upload the script vpn-concurrent-connections.sh to the Gateway under /home/admin/scripts  
+ Make the script executable  
`chmod +x /home/admin/scripts/vpn-concurrent-connections.sh`
+ Save a copy of the user defined snmp settings  
`cp /etc/snmp/userDefinedSettings.conf /etc/snmp/userDefinedSettings.conf_original`
+ Insert the following line at the bottom of the userDefinedSettings.conf file  
`extend .1.2.3.4.5.6.7.8.15 process_monitor /bin/sh /home/admin/scripts/vpn-concurrent-connections.sh`
+ Restart the snmp agent and save the config  
`clish`  
`set snmp agent off`  
`set snmp agent on`  
`save config`

You should now be able to retrieve the number of concurrent VPN users via snmp.

More Information:  
https://community.checkpoint.com/t5/Security-Gateways/How-to-Monitor-Concurrent-VPN-users-connected-to-a-Gateway-OID/td-p/79897
