cat << MAFI >/etc/logrotate.d/iptables
    /var/log/iptables/*.log {
    daily
    missingok
    rotate 25
    compress
    delaycompress   
    notifempty
    create 770 root proxy
    sharedscripts
}
MAFI
