# Windows-Sandbox

The purpose of the example configuration sandbox.wsb is to open suspicious files in a safe environment. Therefore the sandbox has no internet connectivity and mounts the folder under C:\sandbox from the Host-System in Read-Only mode. Obviously you have to create this folder before you start the sandbox.

Enable the Windows-Sandbox feature:  
+ Open the run application by pressing **Windows Key + R**
+ Type ```optionalfeatures``` and press enter
+ Enable the **Windows-Sandbox** feature
+ **Reboot** your machine

More Information:  
https://learn.microsoft.com/de-de/windows/security/threat-protection/windows-sandbox/windows-sandbox-configure-using-wsb-file?source=recommendations
