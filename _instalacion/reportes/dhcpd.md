# Server will not attempt to do a DNS update when a lease is confirmed.
ddns-update-style none;

# option definitions common to all supported networks...
option domain-name "$DOMINIO";
option domain-name-servers 10.10.20.20, 10.10.20.21;

default-lease-time 600;
max-lease-time 7200;

# This DHCP server is the official DHCP server 
authoritative;

# Use this to send dhcp log messages to a different log file 
log-facility local7;

# Servicio
subnet 10.168.28.128 netmask 255.255.255.192 {
    range 10.168.28.130 10.168.28.134;
    option domain-name-servers 10.10.20.20, 10.10.20.21;
    option domain-name "$DOMINIO";
    option routers 10.168.28.129;
    option broadcast-address 10.168.28.191;
    default-lease-time 600;
    max-lease-time 7200;
}
