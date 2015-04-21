---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title: Configuración de squidGuard
orden: 5
---

# Configuración de squidGuard
Borre el contenido del archivo original de configuración de SquidGuard y copie el siguiente.
Si va a cambiar su contenido, tenga especial cuidado con los comentarios: No comente el contenido entre corchetes.

{% highlight squid %}
    {% include_relative squidguard.md %}
{% endhighlight %}

# Personalizando la configuración: 
Los siguientes comandos son la primera configuración que debe hacerse, automáticamente y en base a lo establecido en `/root/fws/infraestructura.sh`
{% highlight bash %}
sed -i "s_{{redlan}}_`perl -ne 'print $_=~m/^LAN=(.*)/' /root/fws/infraestructura.sh`_g" /etc/squidguard/squidGuard.conf 
sed -i "s_{{ipaddresslan}}_`perl -ne 'print $_=~m/^SRV=(.*)/' /root/fws/infraestructura.sh`_g" /etc/squidguard/squidGuard.conf
{% endhighlight %}

Las siguientes acciones configuran todos los archivos referenciados en squidguard y que permiten otra serie de personalizaciones básicas a squidGuard.
El siguiente nivel de personalización requeriría entonces cambiar el fichero `squidguard.conf`

Obtener las listas negras a las que se refiere el archivo anterior. Si la descarga tarda mucho, cancele y vuelva a iniciar
{% highlight bash %}
cd /var/lib/squidguard/db/
wget http://www.shallalist.de/Downloads/shallalist.tar.gz 
{% endhighlight %}

Descomprima y normalice permisos. 
{% highlight bash %}
tar -xzvf shallalist.tar.gz
{% endhighlight %}

Ejecute lo siguientes comandos para crear ficheros donde guardar personalizaciones básicas.
{% highlight bash %}
mkdir /var/lib/squidguard/db/custom
touch /var/lib/squidguard/db/custom/irrestrictos.lst
touch /var/lib/squidguard/db/custom/restrictos.lst
cat << MAFI > /var/lib/squidguard/db/custom/sitios.lst
$(perl -ne 'print $_=~m/^SRV=(.*)/' /root/fws/infraestructura.sh)
gob.sv
typepad.com
blogspot.com
wordpress.com
MAFI
echo ".\.(com|exe|pif|scr|vbe|vbs|wsf|bat|inf|reg|lnk|url|iso|chm|hlp|avi|wma|wmf|mp3|drv|ovr|dll|torrent)$" > /var/lib/squidguard/db/custom/extensiones.lst
{% endhighlight %}

A continuación, se explica la función de todos estos ficheros antes creados.

`/var/lib/squidguard/db/custom/irrestrictos.lst:`
 : IP de usuarios que pasen el filtro de contenido sin mayor restricción.  

`/var/lib/squidguard/db/custom/extensiones.lst:` 
 : Extensiones de archivos cuya descarga se va a prohibir. Entre otro par de barras, incluya otras extensiones que necesite:  

`/var/lib/squidguard/db/custom/sitios.lst` 
 : Sitios cuyo en cuyo contenido se confía, y que por tanto no se necesite mayor bloquear su contenido. El mejor ejemplo es la descarga de actualizaciones de su antivirus.  

Normalice permisos a todos los archivos que ha creado:
{% highlight bash %}
chown -R proxy:proxy BL custom
{% endhighlight %}

## Despliegue de configuración
Reinicie squid3, quién se encarga de iniciar/apagar a squidGuard
{% highlight bash %}
service squid3 restart
{% endhighlight %}
Ahora debe revisar los log de squidGuard, (`tail -f /var/log/squidguard/squidGuard.log`).
Es posible que vea la siguiente línea por un tiempo considerable.
{% highlight bash %}
service squid3 restart
2015-03-07 12:46:40 [7651] init domainlist /var/lib/squidguard/db/BL/porn/domains 
{% endhighlight %}
Es normal porque squidGuard debe crear la base de datos para la lista de dominios `/var/lib/squidguard/db/BL/porn/domains`, la cual por alguna razón que no entiendo es considerablemente extensa.
La siguiente linea marca el momento en que el proxy es capaz de recibir peticiones. No acepte nada menos que esto, otro mensaje indica algún error que debe ser revisado.
{% highlight bash %}
2013-06-04 09:12:15 [3348] INFO: squidGuard ready for requests (1370358735.429)
{% endhighlight %}
Pese a lo anteriormente dicho, podría aceptar también esta línea (Muchas, de hecho) si ha tardado mucho en revisar los log.
{% highlight bash %}
2015-03-26 12:29:31 [14125] INFO: recalculating alarm in 30 seconds
{% endhighlight %}

## Prueba de configuración
La prueba más convincente de la configuración de filtro de contenido es ver a los usuarios navegando correctamente.  
En ese caso, necesita avanzar en Otras configuraciones importantes hasta Configuración de Mensajes de Error

Sin embargo, es posible cerciorarse desde consola que todo funcione. Ejecute desde consola el siguiente comando, cambiando `10.20.20.5` por una ip válida en su red, sin importar si algún equipo la tiene configurada
{% highlight bash %}
echo "hola.org/- 10.20.20.5 - GET -" | squidGuard -c /etc/squidguard/squidGuard.conf -d
{% endhighlight %}

Las últimas lineas debe ser de esta forma:
{% highlight bash %}
2015-03-26 12:37:30 [14193] INFO: squidGuard ready for requests (1427387850.016)
2015-03-26 12:37:30 [14193] Request(usuarios_almuerzo/web-proxy/-) hola.org/- 10.20.20.5/- - GET REDIRECT
http://10.20.20.1/index.php?purl=hola.org/-&razon=web-proxy 10.20.20.5/- - GET
2015-03-26 12:37:30 [14193] INFO: squidGuard stopped (1427387850.184)
{% endhighlight %}

Por otro lado, navegar hacia www.google.com.sv no debería causar mayores problemas
{% highlight bash %}
echo "www.google.com.sv/- 10.20.20.5 - GET -" | squidGuard -c /etc/squidguard/squidGuard.conf -d
2015-03-26 12:39:27 [14206] INFO: recalculating alarm in 2073 seconds
2015-03-26 12:39:27 [14206] INFO: squidGuard ready for requests (1427387967.027)
{{esta línea esta en blanco en la consola}}
2015-03-26 12:39:27 [14206] INFO: squidGuard stopped (1427387967.028)
{% endhighlight %}

En base a ello, puede seguir probando las configuraciones personalizadas que haya estado haciendo con usuarios específicos
