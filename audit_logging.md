# Audit Logging

## Option 1: snoopy
Clearly my favorite method as it is extremely easy to get it running. Additionally the output is well formatted and readable.
```
apt install snoopy
```

## Option 2: auditd
This is the built in method to do audit logging. However - very detailed and noisy output.
```
apt install auditd
```
Append the following lines to /etc/audit/rules.d/audit.rules
```
-a exit,always -F arch=b32 -S execve -k auditcmd
-a exit,always -F arch=b64 -S execve -k auditcmd
```
Per default the logs are written to /var/log/audit/audit.log. To send the logs to a syslog server edit the file /etc/audisp/plugins.d/syslog.conf and change active = no to active = yes.
```
active = yes
direction = out
path = builtin_syslog
type = builtin
args = LOG_INFO
format = string
```

## Option 3: Bash-Hook
Another simple method to log user commands but not very sophisticated.  

Append the following code to /etc/profile
```shell
# command line audit logging
function log2syslog
{
   declare COMMAND
   COMMAND=$(fc -ln -0)
   logger -p local1.notice -t bash -i -- "${USER}:${COMMAND}"
}
trap log2syslog DEBUG
```

## Syslog
To send logs to a central syslog server append the line `*.*   @<IP_OF_SYSLOG_SERVER>` to /etc/rsyslog.conf
