cat << MAFI > /etc/rsyslog.d/iptables.conf
:msg, contains, "IPTABLES IN" -/var/log/iptables/input.log
& ~
:msg, contains, "IPTABLES OUT" -/var/log/iptables/output.log
& ~
:msg, contains, "IPTABLES FWD" -/var/log/iptables/forward.log
& ~
MAFI
