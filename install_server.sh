#!/bin/sh
#VPN_HOST=192.168.2.101
VPN_HOST=$1

apt-get install strongswan strongswan-plugin-af-alg strongswan-plugin-agent strongswan-plugin-certexpire strongswan-plugin-coupling strongswan-plugin-curl strongswan-plugin-dhcp strongswan-plugin-duplicheck strongswan-plugin-eap-aka strongswan-plugin-eap-aka-3gpp2 strongswan-plugin-eap-dynamic strongswan-plugin-eap-gtc strongswan-plugin-eap-mschapv2 strongswan-plugin-eap-peap strongswan-plugin-eap-radius strongswan-plugin-eap-tls strongswan-plugin-eap-ttls strongswan-plugin-error-notify strongswan-plugin-farp strongswan-plugin-fips-prf strongswan-plugin-gcrypt strongswan-plugin-gmp strongswan-plugin-ipseckey strongswan-plugin-kernel-libipsec strongswan-plugin-ldap strongswan-plugin-led strongswan-plugin-load-tester strongswan-plugin-lookip strongswan-plugin-ntru strongswan-plugin-pgp strongswan-plugin-pkcs11 strongswan-plugin-pubkey strongswan-plugin-radattr strongswan-plugin-sshkey strongswan-plugin-systime-fix strongswan-plugin-whitelist strongswan-plugin-xauth-eap strongswan-plugin-xauth-generic strongswan-plugin-xauth-noauth strongswan-plugin-xauth-pam haveged


systemctl enable haveged
systemctl start haveged

cp ipsec.conf /etc
cp ipsec.secrets /etc
cd /etc/ipsec.d/
mkdir -p private ; rm -rf private/*
mkdir -p cacerts ; rm -rf cacerts/*
mkdir -p certs ; rm -rf certs/*
mkdir -p p12 

# creating a self singed root CA private key
ipsec pki --gen --type rsa --size 4096 --outform der > private/strongswanKey.der
chmod 600 private/strongswanKey.der

# Generate a self signed root CA certificate of that private key
ipsec pki --self --ca --lifetime 3650 --in private/strongswanKey.der --type rsa --dn "C=TW, O=Company, CN=strongSwan Root CA" --outform der > cacerts/strongswanCert.der

# Generate private key
ipsec pki --gen --type rsa --size 4096 --outform der > private/vpnHostKey.der
chmod 600 private/vpnHostKey.der

# Generate the public key and use our earlier created root ca to sign the public key
ipsec pki --pub --in private/vpnHostKey.der --type rsa | ipsec pki --issue --lifetime 730 --cacert cacerts/strongswanCert.der --cakey private/strongswanKey.der --dn "C=TW, O=Company, CN=vpn.example.org" --san vpn.example.com --san vpn.example.net --san ${VPN_HOST}  --san @${VPN_HOST} --flag serverAuth --flag ikeIntermediate --outform der > certs/vpnHostCert.der

#
