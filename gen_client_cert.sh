#!/bin/sh

user=$1
#user=Jesse

cd /etc/ipsec.d

# private key
ipsec pki --gen --type rsa --size 2048 --outform der > private/${user}Key.der
chmod 600 private/${user}Key.der

# public key
ipsec pki --pub --in private/${user}Key.der --type rsa | ipsec pki --issue --lifetime 730 --cacert cacerts/strongswanCert.der --cakey private/strongswanKey.der --dn "C=TW, O=Company, CN=${user}@example.org" --san "${user}@example.org" --san "${user}@example.net"  --outform der > certs/${user}Cert.der

# construct p12
openssl rsa -inform DER -in private/${user}Key.der -out private/${user}Key.pem -outform PEM

openssl x509 -inform DER -in certs/${user}Cert.der -out certs/${user}Cert.pem -outform PEM

openssl x509 -inform DER -in cacerts/strongswanCert.der -out cacerts/strongswanCert.pem -outform PEM

openssl pkcs12 -export -inkey private/${user}Key.pem -in certs/${user}Cert.pem -name "${user}'s VPN Certificate" -certfile cacerts/strongswanCert.pem -caname "strongSwan Root CA" -out p12/${user}.p12
