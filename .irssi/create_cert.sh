#!/bin/bash
openssl req -newkey rsa:2048 -days 730 -x509 -keyout irssi.key -out irssi.crt -nodes
cat irssi.crt irssi.key > ~/.irssi/irssi.pem
chmod 600 ~/.irssi/irssi.pem
rm irssi.crt irssi.key
openssl x509 -sha1 -fingerprint -noout -in ~/.irssi/irssi.pem | sed -e 's/^.*=//;s/://g;y/ABCDEF/abcdef/'

# /server add -ssl_cert ~/.irssi/irssi.pem  -ssl_pass <irssi.pem_password> -network freenode chat.freenode.net 6697
# /msg NickServ identify YOUR_PASSWORD
# /msg NickServ cert add YOUR_FINGERPRINT

