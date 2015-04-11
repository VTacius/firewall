---
layout: base
site.author : "Alexander Ortiz"
author : "Alexander Ortiz"
title: Configuración de squidGuard
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
