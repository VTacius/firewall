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

## Reportes y Backup
Hacemos algunas modificaciones en el reporte que hace Sarg
{% highlight bash %}
sed -i -r -f - /etc/sarg/sarg.conf << MAFI
s/Squid User Access Reports/Reporte de Uso de Internet/
s%^output_dir.*%output_dir /var/www/html/sarg%
s/^resolve_ip.*/resolve_ip no/
s/^date_format.*/date_format e/
s/^charset.*/charset UTF-8/
s/lastlog 0/lastlog 20/g
s/^show_successful_message.*/show_successful_message yes/
s/^\#?show_sarg_info.*/show_sarg_info no/g
s/^\#?show_sarg_logo.*/show_sarg_logo no/g
MAFI

sed -i -f - /etc/sarg/sarg-reports.conf <<MAFI
s%HTMLOUT\=.*%HTMLOUT\=/var/www/html/sarg/%
s/PAGETITLE\=.*/PAGETITLE="Reporte de Uso de Internet"/
MAFI

{% endhighlight %}


Restringimos el acceso (Cuidado con el momento en que piden la nueva contraseña):
{% highlight bash %}
touch /var/www/sarg/.htpassword
chmod 600 /var/www/sarg/.htpassword
chown -R www-data:www-data /var/www/sarg
htpasswd /var/www/sarg/.htpassword administrador 
{% endhighlight %}

Configure el servidor web.
{% highlight bash %}
{% include_relative default.md %}
{% endhighlight %}

Hacemos un par de configuraciones que nos parecen necesarias para hacer un poco más discreto a Apache:
{% highlight bash %}
sed -i 's/^ServerTokens.*/ServerTokens Prod/g' /etc/apache2/conf.d/security
sed -i 's/^expose_php.*/expose_php = Off/g' /etc/php5/apache2/php.ini
a2dismod cgi autoindex
{% endhighlight %}

Y reinicie apache:
{% highlight bash %}
service apache2 restart
{% endhighlight %}


Para activar el certificado, envíe un correo de prueba con 
{% highlight bash %}
mutt -nx -s "Probando desde cero el Mutt" fws@empresa.com
{% endhighlight %}

A continuación, aparecerán unos cuantos mensajes donde se le pide confirmar los certificados como válidos: Una vez aceptados, no requerirá intervención alguna nunca más.

Configuramos la rotación de los log de Squid3 para que guarde un registro diariamente por 10 días, y para que cada vez que rote el registro, ejecute el archivo de para backup y reporte.
{% highlight bash %}
sed -i '/\trotate/c\\trotate 10' /etc/logrotate.d/squid3
sed -i '/postrotate/i\\tprerotate\n\t\tbash /root/fws/reportes.sh \n\tendscript' /etc/logrotate.d/squid3
{% endhighlight %}

# Prueba de configuración
Envie un correo de prueba
{% highlight bash %}
mutt -nx -s "Probando desde cero el Mutt" fws@salud.gob.sv <<MAFI
Este correo es la prueba final en Firewall
MAFI
{% endhighlight %}

Una vez configurada, tendrá que esperar cosa de un día para que al acceder a sitio pueda encontrar las estadísticas
