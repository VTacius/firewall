#!/bin/bash

apt install -y libtext-diff-perl libconfig-simple-perl libemail-sender-perl libemail-sender-transport-smtps-perl libemail-sender-transport-smtps-perl libemail-mime-perl libio-all-perl

cp diferencias.pl firewall.sh informacion.pl /usr/local/bin/
chown root:MinsalAdminFirewall {*pl,firewall.sh}
chmod 750 {*pl,firewall.sh}

cp backup.pl /usr/local/sbin/
chmod u+x /usr/local/sbin/backup.pl

[ -d /usr/local/lib/site_perl ] || mkdir /usr/local/lib/site_perl
cp -r Minsal/ /usr/local/lib/site_perl/

mkdir /var/backups/fws
cp /etc/fws/* /var/backups/fws/

cp iptables.service /etc/systemd/system/
systemctl enable iptables.service

cp ruth /etc/sudoers.d/iptables

crontab -l > horario.cron
grep backup.pl horario.cron || echo "15 7 * * * /usr/local/sbin/backup.pl"  >> horario.cron
crontab horario.cron
rm horario.cron

<<<<<<< HEAD
cat <<MAFI > ~/.configuracion_reporte.ini
=======
cat << MAFI > ~/.configuracion_reporte.ini
>>>>>>> c6aa83f3cf5648c8573407875e49859d110be247
[correo]
servidor = mail.salud.gob.sv
usuario = envio@organizacion.org
password = pass_enviante

[envio]
receptor = receptor@organizacion.org

MAFI
