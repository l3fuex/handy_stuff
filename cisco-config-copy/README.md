# CISCO CONFIG COPY

The script implements functionality to tamper with cisco configs through snmp on devices that supports the CISCO-CONFIG-COPY-MIB.  
Basic instructions like upload or download a given config are sent over snmp. However, a tftp server is needed for this to work as it serves as a way 
to exchange data like command outputs.

The first use case is to execute commands through snmp. This is useful if you accidentally lock yourself out of the system and only have access to it through snmp.
Any commands that you want to execute have to be placed in a file named *config.txt* under the tftp directory on your server.
If you want to execute show commands you have to redirect the output in a second file on the tftp server. Depending on your tftp server settings you may need to create the file first.  
This is the default behavior of the script.

A second scenario would be to download the complete configuration from a device for backup purposes.
To achive that just change ccCopySourceFileType from networkFile to runningConfig and ccCopyDestFileType from runningConfig to networkFile.
The script will now download the configuration from the given device and write it in the file *config.txt*. Depending on your tftp server settings you may need to create the file first.  

Outlined below are the necessary steps for these two use cases:

```
# ccCopyEntryRowStatus (createAndWait)
.1.3.6.1.4.1.9.9.96.1.1.1.1.14.123 i <5>

# ccCopyProtocol (tftp)
.1.3.6.1.4.1.9.9.96.1.1.1.1.2.123 i <1>

# ccCopySourceFileType (networkFile|runningConfig)
.1.3.6.1.4.1.9.9.96.1.1.1.1.3.123 i <1|4>

# ccCopyDestFileType (runningConfig|networkFile)
.1.3.6.1.4.1.9.9.96.1.1.1.1.4.123 i <4|1>

# ccCopyServerAddress (IpAddress)
.1.3.6.1.4.1.9.9.96.1.1.1.1.5.123 a <IP-ADDRESS>

# ccCopyFileName (DisplayString)
.1.3.6.1.4.1.9.9.96.1.1.1.1.6.123 s <FILENAME>

# ccCopyEntryRowStatus (active)
.1.3.6.1.4.1.9.9.96.1.1.1.1.14.123 i <1>

# ccCopyEntryRowStatus (destroy)
.1.3.6.1.4.1.9.9.96.1.1.1.1.14.123 i <6>
```

Dependencies:
+ net-snmp
+ tftp-hpa (or any other tftp server software that suites you best)

More Information:  
https://www.cisco.com/c/en/us/support/docs/ip/simple-network-management-protocol-snmp/15217-copy-configs-snmp.html  
https://snmp.cloudapps.cisco.com/Support/SNMP/do/BrowseMIB.do?local=en&step=2&mibName=CISCO-CONFIG-COPY-MIB  
http://www.net-snmp.org/  
