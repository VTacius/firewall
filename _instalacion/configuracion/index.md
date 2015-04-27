---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title: Configuración Primaria de Red
orden: 1
header: no
---
<div class="panel radius" markdown="1">
**Table of Contents**
{: #toc }
*  TOC
{:toc}
</div>

# Configuración Primaria de Red

## /etc/network/interfaces
Para el ejemplo, eth0 es la interfaz WAN, mientras que la interfaz eth1 es la interfaz LAN. Verifique estos valores con la forma en que ha organizado la infraestructura de su red, y como ha conectado los los puertos ethernet.

{% highlight squid %}
{% include_relative interfaces.md %}
{% endhighlight %}

Creamos los ficheros de configuración a los que se hace referencia.  
{% highlight bash %}
mkdir ~/fws
cd ~/fws 
touch firewall.sh rutas.sh infraestructura.sh establecimiento.sh dmz.sh
chmod 744 firewall.sh rutas.sh infraestructura.sh establecimiento.sh dmz.sh
{% endhighlight %}

## /etc/hosts
Configure el archivo /etc/hosts para que el hostname resuelva hacia la IP de la interfaz de red LAN. 
Cambie firewall por el nombre de host que haya configurado en su firewall.
{% highlight bash %}
127.0.0.1   localhost
10.20.20.1  firewall.salud.gob.sv   firewall
{% endhighlight %}

## /etc/resolv.conf
Revise ahora el archivo /etc/resolv.conf, configure los paramétros de búsqueda DNS, debiendo usar sus servidores DNS y su dominio como mejor opción, o usar los nuestros como opción predeterminada
{% highlight bash %}
/etc/resolv.conf
search salud.gob.sv 
nameserver 10.10.20.20 
nameserver 10.10.20.21
{% endhighlight %}

## /etc/host.conf
Configure /etc/host.conf de forma más explícita que la que trae por defecto.
{% highlight bash %}
cat << MAFI > /etc/host.conf
order hosts,bind 
multi on 
MAFI
{% endhighlight %}

# Despliegue de la configuración
Reinicie la red para que la anterior configuración tome efecto.
{% highlight bash %}
service networking restart
{% endhighlight %}

En este punto, pudo haber perdido la sesión ssh por no fijarse de la ubicación de las interfaces. Esa es la única razón ya que aún no se han configurado permisos

# Prueba de configuración
Ejecutar `ip addr show` debería devolver todas físicas como activas y configuradas. 
{% highlight bash %}
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:cb:c9:e2 brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.26/27 brd 192.168.17.31 scope global eth0
    inet6 fe80::5054:ff:fecb:c9e2/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:0f:57:c2 brd ff:ff:ff:ff:ff:ff
    inet 10.20.20.1/24 brd 10.20.20.255 scope global eth1
    inet6 fe80::5054:ff:fe0f:57c2/64 scope link 
       valid_lft forever preferred_lft forever
4: eth2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 52:54:00:32:bc:3c brd ff:ff:ff:ff:ff:ff
    inet 10.30.20.1/24 brd 10.30.20.255 scope global eth2
    inet6 fe80::5054:ff:fe32:bc3c/64 scope link 
       valid_lft forever preferred_lft forever
{% endhighlight %}

De un ping hacia el nombre de host. La salida se presenta a continuación.
{% highlight bash %}
ping `hostname`

PING firewall.salud.gob.sv (10.20.20.1) 56(84) bytes of data.
64 bytes from firewall.salud.gob.sv (10.20.20.1): icmp_req=1 ttl=64 time=0.017 ms
64 bytes from firewall.salud.gob.sv (10.20.20.1): icmp_req=2 ttl=64 time=0.013 ms
El host debian.salud.gob.sv debe resolverse con la IP del servidor en la DMZ del MINSAL:
ping debian.salud.gob.sv
PING mail.salud.gob.sv (10.10.20.7) 56(84) bytes of data. 
64 bytes from 10.10.20.7: icmp_req=1 ttl=63 time=1.34 ms
{% endhighlight %}

¿Ha fallado el último ping? Significa que su gateway es hacia un proveedor propio, y que el equipo no conoce por ahora la ruta hacia la DMZ de Minsal. Añada esta ruta temporalmente, hasta que sea configurada después en los ficheros correspondientes:1
{% highlight bash %}
route add -net 10.10.20.0/24 gw 192.168.17.1 
{% endhighlight %}
Haga ping hacia el gateway del proveedor y hacia un host de la red LAN. Por su bien , no se salte esta comprobación tan simple
