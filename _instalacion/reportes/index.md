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
Acá usamos Filebeat + Elasticsearch + Grafana, lo que realmente significa un gran salto de calidad.

## Reporte de sistema
Acá usamos Telegraf + InfluxDB + Grafana, otro enorme salto en la calidad.

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

