---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title : "Configuración de red: Filtros de paquetes, rutas y nateo"
orden : 3
header: no
---

<div class="panel radius" markdown="1">
**Tabla de contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Configuración de red: Filtros de paquetes, rutas y nateo

## Configuración de archivo de infraestructura
El siguiente archivo configura la infraestructura de red que ha ideado dentro de su Establecimiento.  
Los demás archivos de configuración leerán desde acá los valores que han de usar para configurarse.  
Los comentarios son bastante ilustrativos sobre como debe configurarse cada opción:
{% highlight bash %}
    {% include_relative infraestructura.md %}
{% endhighlight %}

## Configuración del Filtrado de Paquetes de Red
Cree el fichero de configuración para la tabla Filter de Iptables en `/root/fws/firewall.sh`  
El contenido de dicho fichero de muestra a continuación
{% highlight bash %}
    {% include_relative firewall.md %}
{% endhighlight %}

## Personalizando la configuración: 
Toda regla adicional a la estructura de este fichero debe ser agregada en el fichero `/root/fws/establecimiento.sh`, o en `/root/fws/dmz.sh` si aplica en la infraestructura de red a su cargo; de esta forma podrá seguir recibiendo  actualizaciones de este fichero a futuro sin problemas para sus configuraciones.  
__En suma, esto significa que esta totalmente prohibido modificar este fichero.__

Pese a todo, el fichero pretende ser bastante didáctico, esperando de hecho que pueda llegar a comprender su funcionamiento, lo cual le hará estar mejor preparado frente a posibles eventualidades

## Configuración de Tablas Nat y rutas en general
Cree el archivo de configuración para la tabla Nat de Iptables en `/root/fws/rutas.sh`.  
El contenido de dicho fichero se muestra a continuación
{% highlight bash %}
    {% include_relative rutas.md %}
{% endhighlight %}

## Personalizando la configuración:
Al igual que con el archivo `/root/fws/firewall`, salvos contadas excepciones que debe decidir con el técnico enlace en el Nivel Central, no debería cambiar este fichero.  
Para todo lo demás, desde infraestructura.sh puede agregar modificaciones, tal como en la sección de dicho fichero (Y en el fichero mismo) se observa.

## Configuración de DMZ
**Si usted no tiene una red de servidores como tal, la forma más sencilla es comentarizar su post-up en `/etc/network/interfaces`**  

La DMZ puede ser un trabajo realmente complicado. No hay una formula mágica: Aún con el mejor asistente gráfico de configuración, se requiere que usted realmente entienda la red que esta configurando. 

El presente fichero habilita a una red de servidores web para ser alcanzados desde la LAN. Un ejemplo de la publicación de los mismos puede hallarse hacia el final del fichero establecimiento.sh. 

{% highlight bash %}
    {% include_relative dmz.md %}
{% endhighlight %}

## Personalizando la configuración:
¿Es lícito cambiar dmz.sh? No lo creemos necesario, tiene suficiente para trabajar en establecimiento, pero suponemos que este fichero es menos restrictivo que firewall.sh

## Configuración de reglas específicas para el establecimiento
En el fichero `/root/fws/establecimiento.sh`, se configuran las reglas que desea agregar a las actuales. Ya que el Firewall es restrictivo por defecto, se supone que debiera configurar sólo reglas para aceptar algún servicio en particular, usualmente a usuarios particulares.  
Un ejemplo del fichero `/root/fws/establecimiento.sh` es mostrada a continuación
{% highlight bash %}
    {% include_relative establecimiento.md %}
{% endhighlight %}


__Agregar un servicio para toda la red__
Si bien podría no ser el caso más frecuente, bastaría agregar una regla como la siguiente con sus respectivas modificaciones  
{% highlight bash %}
$FWD_SLAN -d [[destino]] -p tcp -m multiport --dport [[puerto]] -m conntrack --ctstate NEW -j ACCEPT
{% endhighlight %}

Donde:  
[[destino]]
 : Dirección IP del servidor donde se encuentra el servicio que quiere hacer accesible

[[puerto]]
 : Una lista separada por comas de puertos que el servicio (O servicios) necesitan

[[comentario]]
 : Una breve reseña del servicio añadido.

__Agregar un servicio para usuarios especificos:__
Podría ser una práctica más común de lo que cree. De hecho, sugerimos que así sea.  
Primero necesita configurar un grupo de ip en `/root/fws/infraestructura.sh`, siguiendo el ejemplo del grupo `"ejemplo"`, agregando una IP por línea.  
Luego, referencia ese grupo dentro de la regla personalizada de la siguiente forma.

{% highlight bash %}
$FWD_SSET -m set --match-set [[grupo]] src -d [[destino]] -p tcp -m multiport --dport [[puertos]] -j ACCEPT
{% endhighlight %}

Donde:
[[grupo]]
 : Es el nombre del grupo configurado en `/root/fws/infraestructura.sh.`

__Publicación de servicios__ 
Para publicar un servicio, bastaría con hacer uso de la cadena personalizada SERVICIOS en conjunto con las reglas de acceso en FWD_LOCAL 
{% highlight bash %}
iptables -t nat -A SERVICIOS -d 192.168.2.6 -j DNAT --to-destination 10.30.20.5
iptables -t filter -A FWD_LOCAL -d 10.30.20.5 -p tcp -m multiport --dport 80 -j ACCEPT
{% endhighlight %}
En casos muy especificos, podría necesitar que algún dispositivo no pase de ninguna forma por el proxy. La cadena SERVICIOS le sería útil para eliminar la redirección HTTP de dicho dispositivo, ya que ocurre antes de dichas reglas

# Despliegue de la configuración
Habiendo configurado los archivos anteriores, reinicie la red:
{% highlight bash %}
service networking restart
{% endhighlight %}

Existe la extraña posibilidad que aparezca un mensaje de error como el siguiente:
{% highlight bash %}
Reconfiguring network interfaces...RTNETLINK answers: File exists
Failed to bring up eth1.
{% endhighlight %}

Bastará con forzar el apagado de dicha interfaz:
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
