$(for r in ${listados_red['LAN']}; do printf "acl usuarios src %s\n" $r; done)

acl Safe_ports port 80 443 8080 20 21
acl CONNECT method CONNECT
acl NONE method NONE

ftp_passive off

http_access deny NONE
http_access deny !Safe_ports
http_access allow usuarios
http_access deny all

$(for r in ${listados['SRV']}; do printf "http_port %s:3128\n" $(echo $r | cut -d '/' -f 1); done)
http_port 8080

cache_mem 469 MB
cache_dir aufs /var/spool/squid 500 16 256

debug_options ALL,2
coredump_dir /var/spool/squid/dump

url_rewrite_program /usr/bin/squidGuard 
url_rewrite_children 5 startup=5 idle=10 concurrency=0

refresh_pattern .       0   20% 4320

relaxed_header_parser warn
connect_timeout 20 seconds
shutdown_lifetime 3 seconds
cache_mgr fws@salud.gob.sv
httpd_suppress_version_string on
visible_hostname $HOSTNAME.$DOMINIO

error_default_language  es-sv
prefer_direct on
check_hostnames on

dns_retransmit_interval 2 seconds
dns_timeout 1 minutes
dns_nameservers 10.10.20.20 10.10.20.21
dns_v4_first on
