---
layout: docs
site.author: Alexander Ortiz
author: Alexander Ortiz
title: Configuración de Red
orden: 2
header: no
---

<div class="panel radius" markdown="1">
**Tabla de contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Configuración de Red

## /etc/network/interfaces

Leemos los parametros que hemos configurado en `~/fws/infraestructura.sh`
{% highlight squid %}
source ~/fws/infraestructura.sh
{% endhighlight %}

Copie y pegue en consola el siguiente contenido, gran parte de la red se configura. Por ahora, tendrá que configurar las redes LAN adicionales manualmente
{% highlight squid %}
{% include_relative interfaces.md %}
{% endhighlight %}

## /etc/hosts
{% highlight bash %}
cat << MAFI > /etc/hosts
127.0.0.1         localhost
$( echo ${SRV[0]} | cut -d "/" -f 1)        $NOMBRE.$DOMINIO   $NOMBRE

MAFI
{% endhighlight %}

## /etc/resolv.conf
Revise ahora el archivo `/etc/resolv.conf`, configure los paramétros de búsqueda DNS, debiendo usar sus servidores DNS y su dominio como mejor opción, o usar los nuestros como opción predeterminada
{% highlight bash %}
cat << MAFI > /etc/resolv.conf
search $DOMINIO
nameserver 10.10.20.20 
nameserver 10.10.20.21
MAFI
{% endhighlight %}

## /etc/host.conf
Configure `/etc/host.conf` de forma más explícita que la que trae por defecto.
{% highlight bash %}
cat << MAFI > /etc/host.conf
order hosts,bind 
multi on 
MAFI
{% endhighlight %}

# Despliegue de la configuración
Reinicie la red para que la anterior configuración tome efecto.
{% highlight bash %}
systemctl restart networking.service
{% endhighlight %}

En este punto, pudo haber perdido la sesión ssh por no fijarse de la ubicación de las interfaces. Esa es la única razón ya que aún no se han configurado permisos

# Prueba de configuración
Ejecutar `ip addr show` debería devolver todas físicas como activas y configuradas. 
{% highlight bash %}
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:3e:a0:8e brd ff:ff:ff:ff:ff:ff
    inet 192.168.2.24/27 brd 192.168.2.31 scope global ens2
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fe3e:a08e/64 scope link 
       valid_lft forever preferred_lft forever
3: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:a9:1c:ea brd ff:ff:ff:ff:ff:ff
    inet 10.168.4.1/24 brd 10.168.4.255 scope global ens3
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fea9:1cea/64 scope link 
       valid_lft forever preferred_lft forever
4: ens4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:35:80:e3 brd ff:ff:ff:ff:ff:ff
    inet 10.20.40.0/24 brd 10.20.40.255 scope global ens4
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:fe35:80e3/64 scope link 
       valid_lft forever preferred_lft forever
{% endhighlight %}

Pese a lo que puedan decir al respecto, ping es una herramienta muy útil. Por ejemplo, podemos usarla para verificar tanto la resolución correcta del nombre de host como que lo alcanzamos por medio de ICMP.
{% highlight bash %}
$ ping `hostname`

PING firewall.salud.gob.sv (10.20.20.1) 56(84) bytes of data.
64 bytes from firewall.salud.gob.sv (10.20.20.1): icmp_req=1 ttl=64 time=0.017 ms
64 bytes from firewall.salud.gob.sv (10.20.20.1): icmp_req=2 ttl=64 time=0.013 ms

# El host debian.salud.gob.sv debe resolverse con la IP del servidor en la DMZ del MINSAL:
$ ping debian.salud.gob.sv

PING mail.salud.gob.sv (10.10.20.7) 56(84) bytes of data. 
64 bytes from 10.10.20.7: icmp_req=1 ttl=63 time=1.34 ms
{% endhighlight %}

¿Ha fallado el último ping? Es posible entonces que su gateway sea el de un proveedor externo que aún no ha configurado una ruta estática hacia la DMZ de Minsal. Añada esta ruta temporalmente, hasta que sea configurada después en los ficheros correspondientes. Recuerde contactar con su proveedor para resolver este problema en cuento antes.
{% highlight bash %}
ip route add 10.10.20.0/24 via 192.168.17.1 
{% endhighlight %}
Haga ping hacia el gateway del proveedor y hacia un host de la red LAN. Por su bien , no se salte esta comprobación tan simple
