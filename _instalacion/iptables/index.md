---
layout: docs
site.author: Alexander Ortiz
author: Alexander Ortiz
title: Configuración de red. Filtros de paquetes, rutas y nateo
orden: 4
header: no
---

<div class="panel radius" markdown="1">
**Tabla de contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Configuración de red: Filtros de paquetes, rutas y nateo
Los siguientes ficheros configuran el manejo que este firewall hace del tráfico de red. Por ahora, se trata sobre todo del filtro de paquetes y nateo

## Creación de Grupos IPSET
Este fichero no necesita configuración alguna. Se limita a crear los grupos que usted ha configurado en `/root/fws/infraestructura.sh`
{% highlight bash %}
cat << "MAFI" > /root/fws/grupos_ipset.sh
{% include_relative grupos_ipset.md %}
MAFI
{% endhighlight %}

## Configuración del Filtrado de Paquetes de Red
Las reglas que se configuran en este script pretenden ser didácticas; su intención es que pueda llegar a comprender su funcionamiento, lo cual le hará estar mejor preparado frente a posibles eventualidades.
No modifique su contenido. El fichero podría ser sustituido por un administrador de forma remota. Para agregar reglas, eche mano del script `~/fws/establecimiento.sh`
{% highlight bash %}
cat << "MAFI" > /root/fws/firewall.sh
{% include_relative firewall.md %}
MAFI
{% endhighlight %}

## Configuración de Tablas Nat y rutas en general
El siguiente script tampoco necesita configuración, y es poco probable que tenga que cambiarlo ya que siempre puede hechar mano del script `~/fws/establecimiento.sh`.
{% highlight bash %}
cat << "MAFI" > /root/fws/rutas.sh 
{% include_relative rutas.md %}
MAFI
{% endhighlight %}

## Configuración de DMZ
**Si usted no tiene una red de servidores como tal, la forma más sencilla es comentarizar su post-up en `/etc/network/interfaces`**  

La DMZ puede ser un trabajo realmente complicado. No hay una formula mágica: Aún con el mejor asistente gráfico de configuración, se requiere que usted realmente entienda la red que esta configurando. 

El presente fichero habilita a una red de servidores web para ser alcanzados desde la LAN. Un ejemplo de la publicación de los mismos puede hallarse hacia el final del script `~/fws/establecimiento.sh`.
{% highlight bash %}
cat << "MAFI" > /root/fws/dmz.sh
{% include_relative dmz.md %}
MAFI
{% endhighlight %}

## Configuración de reglas específicas para el establecimiento
En el fichero `/root/fws/establecimiento.sh`, se configuran las reglas que desea agregar a las que ya han sido configuradas en los ficheros anteriores. Ya que el Firewall es restrictivo por defecto, se supone que debiera configurar sólo reglas para aceptar algún servicio en particular, usualmente a usuarios particulares.  
Un ejemplo del fichero `/root/fws/establecimiento.sh`, con algunos ejemplos listos para usar y útiles para muchos establecimientos, es mostrada a continuación
{% highlight bash %}
cat << "MAFI" > /root/fws/establecimiento.sh
{% include_relative establecimiento.md %}
MAFI
{% endhighlight %}

# Personalización de la configuración
En definitiva, la mayoría de estos ficheros pueden recibir actualizaciones, por lo que es conveniente que se limite a usar el fichero `/root/fws/establecimiento.sh` para las reglas propias de sus establecimiento.

Si usted tiene alguna sugerencia para el cambio de estos ficheros, comuníquese con el nivel central, que estará agradecido por sus sugerencias.

`/root/fws/firewall.sh`
 : Esta prohibido de forma terminante modificar este fichero. Todas las reglas adicionales que usted deba crear deben ser agregada en el fichero `/root/fws/establecimiento.sh`, o en `/root/fws/dmz.sh` si aplica en la infraestructura de red a su cargo 

`/root/fws/rutas.sh`
 : Al igual que con el archivo `/root/fws/firewall.sh`, salvos contadas excepciones que debe decidir con el técnico enlace en el Nivel Central, no debería cambiar este fichero.  
Para todo lo demás, desde infraestructura.sh puede agregar modificaciones, tal como en la sección de dicho fichero (Y en el fichero mismo) se observa.

`/root/fws/dmz.sh`
 : Tampoco lo vaya a cambiar. Parece que ya hemos explicado nuestras razones, `establecimiento.sh` tiene lo suficiente para poder modificar los permisos relacionados con su red DMZ

`/root/fws/establecimiento.sh`
 : Hay algunos ejemplos dentro del fichero Este lo puede cambiar todo lo que quiera. Lea en el manual [Extendiendo las ACL de red para su Firewall]({{site.baseurl}}/manual/iptables/) y vea las opciones que tiene para cambiar este fichero.

# Despliegue de la configuración
Habiendo configurado los archivos anteriores, reinicie la red:
{% highlight bash %}
systemctl restart networking.service
{% endhighlight %}

Existe la extraña posibilidad que aparezca un mensaje de error como el siguiente:
{% highlight bash %}
Job for networking.service failed because the control process exited with error code.
See "systemctl status networking.service" and "journalctl -xe" for details.
{% endhighlight %}

Sería buena idea en realidad correr el comando `journalctl -xe`, pero es posible que haya habido un problema previo con la configuración de alguna de las interfaces. Para eso, bastará con forzar el apagado de dicha interfaz:
{% highlight bash %}
ifdown --force eth1
{% endhighlight %}

Y podrá reiniciar la red sin ningún problema

# Prueba de configuración
Desde alguno de los cliente en la red interna debe acceder a los servicios del MINSAL, y los servidores de HACIENDA. Algunos ejemplos que puede hacer:
{% highlight bash %}
nslookup debian.salud.gob.sv
Server:     10.10.20.20
Address:    10.10.20.20#53
debian.salud.gob.sv canonical name = mirror.salud.gob.sv.
Name:   mirror.salud.gob.sv
Address: 10.10.20.7

ftp -n <<MAFI
open 192.168.87.2
user anonymous anonymous
cd pub
ls
bye
MAFI
drwxrwxr-x    3 0        503          4096 Jan 29 17:48 DESAREPO
drwxrwsr-x    3 0        503          4096 Jul 14  2014 GD_PRUEBAS
drwxrwsr-x    3 0        503          4096 Dec 22  2006 GOBAID
drwxrwsr-x    3 0        503          4096 Nov 13  2013 GOBC
drwxrwsr-x    3 0        503          4096 Aug 25  2004 GOBD
drwxrwsr-x    3 0        503          4096 Jan 09  2008 GOBSAFIC
drwxrwsr-x    3 0        503          4096 Nov 13  2013 GOBSAFICUTNORCL
drwxrwsr-x    3 0        503          4096 Jun 29  2009 GOBSAFIC_OLD
drwxrwsr-x    3 0        503          4096 Nov 13  2013 GOBSAFII
[...]
{% endhighlight %}

Desde el Firewall, comprueba la conectividad en general. Note como este par de pruebas implican la mayoría de permisos con los que el Firewall cuenta:
{% highlight bash %}
ping www.google.com.sv
PING www.google.com.sv (74.125.137.94) 56(84) bytes of data.
64 bytes from yh-in-f94.1e100.net (74.125.137.94): icmp_req=1 ttl=43 time=74.5 ms
64 bytes from yh-in-f94.1e100.net (74.125.137.94): icmp_req=2 ttl=43 time=74.7 ms

telnet www.google.com.sv 443
Trying 74.125.137.94...
Connected to www.google.com.sv.
Escape character is '^]'.
{% endhighlight %}
