---
layout: docs
site.author: Alexander Ortiz
author: Alexander Ortiz
title: Configuración de reporte y otras configuraciones opcionales
orden: 8
header: no
---

<div class="panel radius" markdown="1">
**Tabla de contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Configuración de reporte y otras configuraciones opcionales
Todas lo que sigue no es ni imprescindible ni realmente importante para el funcionamiento de su firewall, pero añadirá características importantes

## Reporte de uso de internet
Configuraremos al ya instalado sarg para que los reportes tengan sentido para nosotros
{% highlight bash %}
sed -i -r -f - /etc/sarg/sarg.conf << MAFI
s/Squid User Access Reports/Reporte de Uso de Internet/
s%^output_dir.+%output_dir /var/www/html/sarg%
s/^resolve_ip.+/resolve_ip no/
s/^date_format.+/date_format e/
s/^charset.+/charset UTF-8/
s/lastlog 0/lastlog 20/g
s/^show_successful_message.+/show_successful_message yes/
s/^\#?show_sarg_info.+/show_sarg_info no/g
s/^\#?show_sarg_logo.+/show_sarg_logo no/g
MAFI

sed -i -f - /etc/sarg/sarg-reports.conf <<MAFI
s%HTMLOUT\=.*%HTMLOUT\=/var/www/html/sarg/%
s/PAGETITLE\=.*/PAGETITLE="Reporte de Uso de Internet"/
MAFI

{% endhighlight %}

Securizamos el acceso a /reportes por medio del servidor web
{% highlight apache %}
cat << "MAFI" > /etc/apache2/sites-available/000-default.conf 
{% include_relative default.md %}
MAFI
{% endhighlight %}

Creamos el fichero `/var/www/html/sarg/.htpassword` al que se hace referencia en el fichero anterior. El último archivos le pide una contraseña a usar en conjunto con el usuarios "administrador" para entrar a ver los reportes
{% highlight bash %}
touch /var/www/html/sarg/.htpassword 
chmod 600 /var/www/html/sarg/.htpassword 
chown -R www-data:www-data /var/www/html/sarg/.htpassword 
htpasswd -B /var/www/html/sarg/.htpassword administrador
{% endhighlight %}

Reiniciamos apache para que toda la configuración tenga efecto:
{% highlight bash %}
systemctl restart apache2.service
{% endhighlight %}

## Reporte de sistema
Este reporte es toda una serie de complicados script que tienen por objetivo último el enviar a su correo un par de gráficas muy bonitas. Esta en una fase bastante avanzada de desarrollo, y hasta ahora parecen que funcionan bien. 

Activamos el registro de datos, aumentamos el número de registros a guardar y reiniciamos a `sysstat` para que los cambios tomen efecto
{% highlight bash %}
sed -i -r 's/^ENABLED.+/ENABLED="true"/' /etc/default/sysstat
sed -i -r 's/^HISTORY.+/HISTORY=28/' /etc/sysstat/sysstat
sed -i -r 's/^SADC_OPTIONS.+/SADC_OPTIONS="-S XDISK"/' /etc/sysstat/sysstat
systemctl restart sysstat.service
{% endhighlight %}

Cambiamos la configuración de cron para sysstat, cambiando el intervalo de recolección de datos a 5 minutos y configurando otras tareas relacionadas. Creamos el directorio donde se han de almacenar los ficheros:
{% highlight bash %}
cat << MAFI > /etc/cron.d/sysstat
{% include_relative sysstat.md %}
MAFI
systemctl restart cron.service
mkdir /var/spool/actividad/
{% endhighlight %}

Creamos el fichero de configuración para los script de reporte de la siguiente forma. Sobre todo, deberá configurar un usuario/contraseña válido y el servidor contra el cual sirva. Luego, su memoria RAM en kilobytes
{% highlight ini %}
cat << MAFI >> ~/.configuracion_reporte.ini
{% include_relative configuracion_reporte.md %}
MAFI
touch /var/spool/actividad/disco.prom
{% endhighlight %}

Y ya por último, configuramos los reportes a ejecutarse como tarea por parte de crontab

{% highlight bash %}
crontab -l > horario.cron
grep reporte.pl horario.cron || echo " 14 7  * * * /root/reporte/reporte.pl"  >> horario.cron
grep diferencias.pl horario.cron || echo " 15 7  * * * /root/reporte/diferencias.pl"  >> horario.cron
crontab horario.cron 
rm horario.cron
{% endhighlight %}

## NTP
Es posible que su servidor tenga ya la hora correctamente configurada, pero si aún con eso quiere evitar los molestos mensajes en syslog, basta con ejecutar
{% highlight bash %}
sed -i -r 's/^#?NTP=/NTP=10.10.20.20/' /etc/systemd/timesyncd.conf
sed -i -r 's/^#?FallbackNTP=.+/FallbackNTP=10.10.20.20/' /etc/systemd/timesyncd.conf
timedatectl set-ntp true
systemctl restart systemd-timesyncd
{% endhighlight %}

## DHCP
La institución que usa esta configuración de firewall cree fervientemente en que la asignación dinámica de IP en los clientes puede ser decisión administrativa eficiente en muchos sentidos. Sin embargo, cierto dispositivo requiere de esta configuración y debido a los problemas que se presentan en Debian Stretch me pareció una buena idea recopilar la configuración mínima necesaria

{% highlight bash %}
source /root/fws/infraestructura.sh
sed -i -r "s/^INTERFACESv4.+/INTERFACESv4=\"$INP\"/" /etc/default/isc-dhcp-server
sed -i -r 's/^INTERFACESv6(.+)/#INTERFACESv6\1/' /etc/default/isc-dhcp-server
{% endhighlight %}

El siguiente es más bien un ejemplo de como podría ir el fichero de configuración. 
{% highlight bash %}
source /root/fws/infraestructura.sh
cat << MAFI > /etc/dhcp/dhcpd.conf  
{% include_relative dhcpd.md %}
MAFI
{% endhighlight %}

Si después de una configuración satisfactoria aún tiene problemas para arrancar el servicio, con un mensaje en los logs como los siguientes:

{% highlight log %}
Jul 20 13:26:47 fw-establecimiento isc-dhcp-server[24369]: Launching IPv4 server only.
Jul 20 13:26:47 fw-establecimiento dhcpd[24378]: Internet Systems Consortium DHCP Server 4.3.5
Jul 20 13:26:47 fw-establecimiento dhcpd[24378]: Copyright 2004-2016 Internet Systems Consortium.
Jul 20 13:26:47 fw-establecimiento dhcpd[24378]: All rights reserved.
Jul 20 13:26:47 fw-establecimiento dhcpd[24378]: For info, please visit https://www.isc.org/software/dhcp/
Jul 20 13:26:47 fw-establecimiento isc-dhcp-server[24369]: Starting ISC DHCPv4 server: dhcpddhcpd service already running (pid file /var/run/dhcpd.pid currenty exists) ... failed!
Jul 20 13:26:47 fw-establecimiento systemd[1]: isc-dhcp-server.service: Control process exited, code=exited status=1
Jul 20 13:26:47 fw-establecimiento systemd[1]: Failed to start LSB: DHCP server.
Jul 20 13:26:47 fw-establecimiento systemd[1]: isc-dhcp-server.service: Unit entered failed state.
Jul 20 13:26:47 fw-establecimiento systemd[1]: isc-dhcp-server.service: Failed with result 'exit-code'.
{% endhighlight %}

Bastará con apagar el servicio, borrar a `dhcpd.pid` e iniciar el servicio
{% highlight bash %}
systemctl stop isc-dhcp-server.service
rm /var/run/dhcpd.pid
systemctl start isc-dhcp-server.service
{% endhighlight %}

