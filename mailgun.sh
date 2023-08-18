#!/bin/bash

# Send mails via telnet over mailgun.com mail service.

# SMTP credentials
username="SMTP_USERNAME"
password="SMTP_PASSWORD"

# Base64 encoded credentials
export base64_user=$(echo -n $username | base64 -w 0)
export base64_pass=$(echo -n $password | base64 -w 0)

# Ask user for recipient address
echo -n "Rcpt-To: "
read rcpt_to

# Ask user for message headers and body
echo "Data: "
while true; do
    read line
    if [[ $line == "." ]]; then
        data+="$line"
        break
    fi
    data+="$line"$'\n'
done

# expect script in heredoc
expect <<- EOF
spawn telnet smtp.mailgun.org 25
set timeout 10
expect -re {[2]{2,}[0]{1,}}
sleep 0.5
send -- "HELO postmaster@foo.bar\r"
expect -re {[2]{1,}[5]{1,}[0]{1,}}
sleep 0.5
send -- "AUTH LOGIN\r"
expect -re {[3]{2,}[4]{1,}}
sleep 0.5
send -- "$base64_user\r"
expect -re {[3]{2,}[4]{1,}}
sleep 0.5
send -- "$base64_pass\r"
expect -re {[2]{1,}[3]{1,}[5]{1,}}
sleep 0.5
send -- "mail from: john@mailgun.org\r"
expect -re {[2]{1,}[5]{1,}[0]{1,}}
sleep 0.5
send -- "rcpt to: $rcpt_to\r"
expect -re {[2]{1,}[5]{1,}[0]{1,}}
sleep 0.5
send -- "data\r"
expect -re {[3]{1,}[5]{1,}[4]{1,}}
sleep 0.5
send -- "$data\r"
sleep 0.5
expect -re {[2]{1,}[5]{1,}[0]{1,}}
send -- "quit\r"
expect eof
EOF
