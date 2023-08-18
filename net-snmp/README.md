# Install Net-SNMP with strong encryption support (AES192/AES256)
The Net-SNMP version available through the package manager apt currently offers only a limited range of encryption algorithms (DES/AES) and hash functions (MD5/SHA).
To support also AES192/AES256 or hash functions like SHA256 the software needs to be compiled from source. The script outlines how to do that (the snmp-agent piece was disabled as it is not needed in my use case).

Hash-Algorithms:  
**MD5|SHA|SHA-224|SHA-256|SHA-384|SHA-512**  

Encryption-Algorithms:  
**DES|AES|AES-192|AES-256**  

Known Issues:  
In case of an error like *"error while loading shared libraries: libnetsnmp.so.40: cannot open shared object file: No such file or directory"* a link should do the trick `ln -s /usr/local/lib/libnetsnmp.so.40 /usr/lib/libnetsnmp.so.40`.

More Information:  
[http://www.net-snmp.org/](http://www.net-snmp.org/)
