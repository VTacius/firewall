cat <<"MAFI"> /root/fws/reportes.sh
#!/bin/bash
source /root/fws/infraestructura.sh
# Formará el nombre con la fecha y hora. 
fecha=`date '+%d-%m-%Y %H:%M:%S'`
timestamp=`date '+%Y%m%d-%H%M%S'`
dia=`date '+%d/%m/%Y'`

# Diferentes parametros del rendimiento de nuestros equipos
espacio=`df -h`
var_timeon_days=`uptime | awk '{print $3}'`
var_timeon_hours=`uptime | awk '{print $5}' | cut -d "," -f1`
var_memtotal=`free -m | awk '/Mem/ {print $0}' | awk '{print $2}'`
var_memused=`free -m | awk '/Mem/ {print $0}' | awk '{print $3}'`
var_memfree=`free -m | awk '/Mem/ {print $0}' | awk '{print $4}'`
echo -e "\n\n###################################\nCreando backup en $fecha\n\n" >> /root/fws/backup.log

# Comprime todos los archivos que hemos modificado a través de la configuración 
tar -czvPf /root/fws/backup-$timestamp.tgz /etc/network/interfaces /etc/{hosts,resolv.conf,host.conf} /root/fws/*sh /etc/squid3/squid.conf /etc/squidguard/squidGuard.conf /var/lib/squidguard/db/custom/* /var/www/ --exclude=/var/www/{sarg,img}/* /etc/sarg/sarg.conf /etc/apache2/sites-enabled/000-default /root/.muttrc &>> /root/fws/backup.log

# Creamos los log en HTML con sarg 
/usr/bin/sarg &>> /root/fws/backup.log

# Creamos un registro sobre el uso del enlace. Es muy quisquilloso sobre la forma en que lo muestra, así que lo haremos en dos paso
vnstat -i $INW -d > vnstat.log
echo -e "\n\n########################################################################\n" >> vnstat.log
vnstat -i $INW -h >> vnstat.log

# Envia los paquetes por correo. 
mutt -nx -s "Firewall $INSTITUCION: Reporte y Backup en $dia " alortiz@salud.gob.sv -a /root/fws/backup-$timestamp.tgz <<MFI
Saludos. 
Se adjunta el backup de los ficheros de configuración para el Firewall en $INSTITUCION
Puede acceder a los reportes de acceso en su navegador en http://$SRW/sarg
-------------------------------------------------------------

Tiempo en funcionamiento: 
$var_timeon_days días, $var_timeon_hours horas
--------------------------------------------------------------

Memoria: 
Total: $var_memtotal MB   Usada: $var_memused MB   Libre: $var_memfree MB

--------------------------------------------------------------

Espacio en Disco
==============================================================
$espacio

--------------------------------------------------------------

Uso de la red (Tráfico en interfaz WAN)
==============================================================
`cat /root/fws/vnstat.log`
MFI
if [ $? = 0 ]; then
    echo "SUCCESS: El archivo de backup se envío con éxito en $fecha" >> /root/fws/backup.log
    rm -rf /root/fws/backup-$timestamp.tgz
else
    echo "ERROR: Fallo en el envío de correo en $fecha" >> /root/fws/backup.log
fi

MAFI
