acl usuarios src {{redlan}}
acl Safe_ports port 80 443 8080
acl manager proto cache_object
acl CONNECT method CONNECT

http_access deny !Safe_ports
http_access allow usuarios
http_access deny all

http_port {{ipaddresslan}}:3128 intercept
cache_mem 469 MB
cache_dir aufs /var/spool/squid3 500 16 256

debug_options ALL,2
coredump_dir /var/spool/squid3/dump

url_rewrite_program /usr/bin/squidGuard 
url_rewrite_children 5 startup=0 idle=1 concurrency=3

refresh_pattern .		0	20%	4320

relaxed_header_parser warn
connect_timeout 20 seconds
shutdown_lifetime 3 seconds
cache_mgr fws@salud.gob.sv
httpd_suppress_version_string on
visible_hostname {{hostname}}

error_default_language  es-sv
prefer_direct on
check_hostnames on

dns_retransmit_interval 2 seconds
dns_timeout 1 minutes
dns_nameservers 10.10.20.20 10.10.20.21
dns_v4_first on
