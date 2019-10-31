user_ip=10.10.10.0/24
#user_ip=$1
echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -t nat -X
iptables -t nat -Z
iptables -t mangle -F
iptables -t mangle -X
iptables -t mangle -Z


# keep connect , accept 22 for ssh
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# accept local 
iptables -A INPUT -i lo -j ACCEPT

# accept ipsec 
iptables -A INPUT -p udp --dport 500 --j ACCEPT
iptables -A INPUT -p udp --dport 4500 --j ACCEPT
iptables -A INPUT -p esp -j ACCEPT

iptables -A FORWARD --match policy --pol ipsec --dir in  --proto esp -s ${user_ip} -j ACCEPT
iptables -A FORWARD --match policy --pol ipsec --dir out --proto esp -d ${user_ip} -j ACCEPT

iptables -t nat -A POSTROUTING -s ${user_ip} -o eth0 -m policy --pol ipsec --dir out -j ACCEPT
iptables -t nat -A POSTROUTING -s ${user_ip} -o eth0 -j MASQUERADE

iptables -t mangle -A FORWARD --match policy --pol ipsec --dir in -s ${user_ip} -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360


#iptables -A INPUT -j DROP
#iptables -A FORWARD -j DROP
