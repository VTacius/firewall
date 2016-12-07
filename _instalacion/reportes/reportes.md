cat <<"MAFI"> /root/fws/reportes.sh
#!/bin/bash
source /root/fws/infraestructura.sh

# Formará el nombre con la fecha y hora. 
dia=`date '+%d/%m/%Y'`
fecha=`date '+%d-%m-%Y %H:%M:%S'`
timestamp=`date '+%Y%m%d-%H%M%S'`

# Diferentes parametros del rendimiento de nuestros equipos
espacio=`df -h`
service_tag=`dmidecode -s system-serial-number  | tail -n 1`
var_timeon_days=`uptime | awk '{print $3}'`
var_timeon_hours=$(uptime | awk -F "," '{print $2}')
var_memused=$(free -m | awk '/Mem/ {print $3}')
var_memfree=$(free -m | awk '/Mem/ {print $4}')
var_memtotal=$(free -m | awk '/Mem/ {print $2}')
archivos=(establecimiento.sh  firewall.sh  infraestructura.sh  rutas.sh)

# Verificamos el estado actual de las reglas por defecto para las cadenas en FILTER de IPTABLES
estado_input=$(iptables -t filter -nvL INPUT | grep -oP '\(policy\s\K(\w+)')
estado_output=$(iptables -t filter -nvL OUTPUT | grep -oP '\(policy\s\K(\w+)')
estado_forward=$(iptables -t filter -nvL FORWARD | grep -oP '\(policy\s\K(\w+)')

# Verificamos si se han agregado reglas a los ficheros de configuración de reglas
for f in ${archivos[*]};do
    sentencia=`diff -q /root/fws/archivo/$f /root/fws/$f`
    echo ${sentencia:="No existen cambios en $f"} > /root/fws/archivo/$f.diff
    diff /root/fws/archivo/$f /root/fws/$f >> /root/fws/archivo/$f.diff
done

# Guardamos una copia de los actuales ficheros de configuración de reglas para firewall
cp /root/fws/{infraestructura,firewall,rutas,establecimiento}.sh /root/fws/archivo/

echo -e "\n\n###################################\nCreando backup en $fecha\n\n" >> /root/fws/backup.log

# Comprime todos los archivos que hemos modificado a través de la configuración 
tar -czvPf /root/fws/backup-$timestamp.tgz /etc/network/interfaces /etc/{hosts,resolv.conf,host.conf} /root/fws/*sh /etc/squid3/squid.conf /etc/squidguard/squidGuard.conf /var/lib/squidguard/db/custom/* /var/www/ --exclude=/var/www/{sarg,img}/* /etc/sarg/sarg.conf /etc/apache2/sites-enabled/000-default /root/.muttrc &>> /root/fws/backup.log

# Creamos los log en HTML con sarg 
/usr/bin/sarg &>> /root/fws/backup.log

# Creamos un registro con el uso del enlace
vnstat -i $INW -h > /root/fws/vnstat.log

# Envia los paquetes por correo. 
mutt -nx -s "Firewall $INSTITUCION: Reporte y Backup en $dia " fws@salud.gob.sv -a /root/fws/backup-$timestamp.tgz <<MFI
Saludos. 

Se adjunta el backup de los ficheros de configuración para el Firewall en $INSTITUCION
Puede acceder a los reportes de acceso en su navegador en http://$SRW/sarg

-------------------------------------------------------------

Información General Firewall:
==============================================================
Service TAG: ${service_tag:="Información no disponible"}
Fondo Compra: ${FONDO_COMPRA:="Información no disponible"}

--------------------------------------------------------------

Tiempo en funcionamiento: 
==============================================================
$var_timeon_days días, $var_timeon_hours horas

--------------------------------------------------------------

Memoria: 
==============================================================
Total: $var_memtotal MB   Usada: $var_memused MB   Libre: $var_memfree MB

--------------------------------------------------------------

Espacio en Disco
==============================================================
$espacio

--------------------------------------------------------------

Uso de la red (Tráfico en interfaz WAN)
==============================================================
`cat /root/fws/vnstat.log`

--------------------------------------------------------------

Estado actual de Firewall:
==============================================================
INPUT: $estado_input    FORWARD: $estado_forward   OUTPUT: $estado_output

--------------------------------------------------------------

Cambios realizados en las reglas del Firewall:
==============================================================
`cat /root/fws/archivo/infraestructura.sh.diff`

`cat /root/fws/archivo/firewall.sh.diff`

`cat /root/fws/archivo/rutas.sh.diff`

`cat /root/fws/archivo/establecimiento.sh.diff`


MFI
if [ $? = 0 ]; then
    echo "SUCCESS: El archivo de backup se envío con éxito en $fecha" >> /root/fws/backup.log
    rm -rf /root/fws/backup-$timestamp.tgz
else
    echo "ERROR: Fallo en el envío de correo en $fecha" >> /root/fws/backup.log
fi

MAFI
