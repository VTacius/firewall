#!/bin/bash

apt install -y libconfig-simple-perl libemail-sender-perl libemail-sender-transport-smtps-perl libemail-sender-transport-smtps-perl libemail-mime-perl 

cp backup.pl diferencias.pl firewall.sh informacion.pl /usr/local/bin/
chown root:MinsalAdminFirewall {*pl,firewall.sh}
chmod 750 {*pl,firewall.sh}
[ -d /usr/local/lib/site_perl ] || mkdir /usr/local/lib/site_perl
cp -r Minsal/ /usr/local/lib/site_perl/

mkdir /var/backups/fws
cp /etc/fws/* /var/backups/fws/

cp iptables.service /etc/systemd/system/
systemctl enable iptables.service

cp ruth /etc/sudoers.d/iptables

crontab -l > horario.cron
grep backup.pl horario.cron || echo "15 7 * * * /usr/local/bin/backup.pl"  >> horario.cron
crontab horario.cron
rm horario.cron

