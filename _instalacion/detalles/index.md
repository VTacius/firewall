---
layout: docs
site.author: Alexander Ortiz
author: Alexander Ortiz
title: Otras configuraciones importantes
orden: 7
header: no
---

<div class="panel radius" markdown="1">
**Tabla de contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Otras configuraciones importantes
Hasta este punto, los usuarios en su red ya son capaces de navegar. Esta parte de la guía bien podría esperar un día si fuera necesario.

Lo primero es descargarnos una copia de la rama master del repositorio `vtacius/firewall`, descomprimirlo y moverlo a una ubicación más accesible con los siguientes comandos:
{% highlight bash %}
cd ~/
wget https://github.com/vtacius/firewall/archive/master.tar.gz
tar xzvf master.tar.gz --strip-components=1 --exclude=README.md --exclude=LICENSE
rm master.tar.gz
{% endhighlight %}

## Configuración de Mensaje de Error
**Esta página de error sólo aparece cuando se intenta navegar hacia sitios HTTP. En HTTPS el navegador devuelve como resultado un error 1111**  

Reemplazamos el contenido en `/var/www/html` con el que obtuvimos en el paso anterior:
{% highlight bash %}
rm -rf /var/www/html/
mv html/ /var/www/
{% endhighlight %}

Los siguientes comandos configuran la página de error según la información contenida en `/root/fws/infraestructura`
{% highlight bash %}
source /root/fws/infraestructura.sh
IPADD=$(echo ${listados['SRV']} | cut -d '/' -f 1)
sed -i "s|<<ipaddresslan>>|$IPADD|" /var/www/html/{index.php,script/default.css}
sed -i "s|<<MarcadorInstitucion>>|$INSTITUCION|" /var/www/html/index.php
{% endhighlight %}

### Prueba de configuración
Desde el navegador de un cliente, intente acceder a un sitio http que esté en alguna categoría restringida (`http://www.myspace.com` por ejemplo), y verifique que la página de error funcione correctamente.

## Securizando Apache
Hacemos un par de configuraciones que nos parecen necesarias para hacer un poco más discreto a Apache:
{% highlight bash %}
sed -i /etc/apache2/conf-available/security.conf -f - << MAFI
s/^ServerTokens.*/ServerTokens Prod/
s/^ServerSignature.*/ServerSignature Off/
MAFI

sed -i /etc/php/7.0/apache2/php.ini -f - << MAFI
s/^file_uploads.*/file_uploads = Off/
s/^allow_url_fopen.*/allow_url_fopen = Off/
MAFI

a2disconf javascript-common
a2dismod -f alias cgi autoindex
{% endhighlight %}

Reiniciamos apache para que toda la configuración tenga efecto:
{% highlight bash %}
systemctl restart apache2.service
{% endhighlight %}

## Configuración de Registro de Iptables
Los siguientes comandos crearán el fichero de configuración `/etc/rsyslog.d/iptables.conf` para que rsyslog envíe los registros asociados a IPTABLES a una serie de ficheros.
{% highlight bash %}
{% include_relative rsyslog_iptables.md %}
{% endhighlight %}

Crear los ficheros referenciados
{% highlight bash %}
mkdir /var/log/iptables
touch /var/log/iptables/{input,output,forward}.log
chmod 770 /var/log/iptables/*.log
{% endhighlight %}

Y luego reinicia el servicio de rsyslog
{% highlight bash %}
systemctl restart rsyslog.service
{% endhighlight %}

Configuramos logrotate 
{% highlight bash %}
{% include_relative logrotate_iptables.md %}
{% endhighlight %}

Se estima que estos ficheros de registros pueden ser de hasta 250 MB diarios. En base al espacio del que disponga en disco, puede configurar que guarde menos anecdóticos configurando el valor `rotate`.

## Configuración de los Registros de Squid
Configuramos la rotación de los log de Squid para que guarde un registro diariamente por 20 días
{% highlight bash %}
sed -i -r 's/rotate.+/rotate 10/' /etc/logrotate.d/squid
{% endhighlight %}

