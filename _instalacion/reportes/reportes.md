
cat <<"MAFI"> /root/fws/reportes.sh
#!/bin/bash
source /root/fws/infraestructura.sh
# Formará el nombre con la fecha y hora. 
fecha=`date '+%d-%m-%Y--%H:%M:%S'`
dia=`date '+%d/%m/%Y'`
echo -e "\n\n###################################\nCreando backup en $fecha\n\n" >> /root/fws/backup.log
# Comprime todos los archivos que hemos modificado a través de la configuración 
tar -czvPf /root/fws/backup-$fecha.tgz /etc/network/interfaces /etc/{hosts,resolv.conf,host.conf} /root/fws/*sh /etc/squid3/squid.conf /etc/squidguard/squidGuard.conf /var/lib/squidguard/db/custom/* /var/www/ --exclude=/var/www/{sarg,img}/* /etc/sarg/sarg.conf /etc/apache2/sites-enabled/000-default /root/.muttrc &>> /root/fws/backup.log
# Creamos los log en HTML con sarg 
/usr/bin/sarg &>> /root/fws/backup.log
# Envia los paquetes por correo. 
mutt -nx -s "Firewall $INSTITUCION: Reporte y Backup en $dia " fws@salud.gob.sv -a /root/fws/backup-$fecha.tgz <<MFI
Saludos. 
Se adjunta el backup de los ficheros de configuración para el Firewall en $INSTITUCION
Puede acceder a los reportes de acceso en su navegador en http://$SRW/sarg
MFI
if [ $? = 0 ]; then
    echo "SUCCESS: El archivo de backup se envío con éxito en $fecha" >> /root/fws/backup.log
    rm -rf /root/fws/backup-$fecha.tgz
else
    echo "ERROR: Fallo en el envío de correo en $fecha" >> /root/fws/backup.log
fi
MAFI
