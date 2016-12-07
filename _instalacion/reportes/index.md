---
layout: docs
site.author: Alexander Ortiz
author: Alexander Ortiz
title: Otras configuraciones importantes
orden: 6
header: no
---

<div class="panel radius" markdown="1">
**Tabla de contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Otras configuraciones importantes

## Script asistenciales
Crearemos el fichero `/root/fws/tools/cleantmp.sh` 
{% highlight bash %}
cat << "MAFI" > /root/fws/tools/cleantmp.sh
#!/bin/bash
for fichero in `find /var/tmp/ -mindepth 1`; do fuser -s $fichero  || rm $fichero; done
MAFI
{% endhighlight %}

Y lo ponemos en crontab de una forma un poco alterna debido a que somos quisquillosos con la hora:
{% highlight bash %}
crontab -l > horario.cron
if [ 0 -eq `grep cleantmp.sh horario.cron -c` ]; then  echo "  0 0  * * 0 /root/fws/tools/cleantmp.sh" >> horario.cron && crontab horario.cron; fi
rm horario.cron
{% endhighlight %}

Ahora, el script `/root/fws/tools/reinicio.sh`. Usarlo en lugar de reiniciar la red, que puede ser algo engorroso y lento;  a menos que haya agregado la definición de una red en `/etc/network/interfaces`
{% highlight bash %}
cat << "MAFI" > /root/fws/tools/reinicio.sh
#!/bin/bash
# Configuración de la tabla FILTER de IPTABLES. Recuerde que al menos root debe tener permisos de ejecución 
/root/fws/firewall.sh

# Configuración de tabla NAT en IPTABLES, y configuración de rutas
/root/fws/rutas.sh 

# Configura una dmz en caso de tenerla
if [ 1 -eq `egrep '^\s*post-up /root/fws/dmz.sh' /etc/network/interfaces -c` ]; then
    /root/fws/dmz.sh 
fi

# Configuración personalizada de reglas especificas para el establecimiento dado.
/root/fws/establecimiento.sh
MAFI
{% endhighlight %}

## Configuración de Registro de Iptables
En principio, estas configuraciones no parecerían esenciales para el correcto funcionamiento de su firewall. Sin embargo, TODAS son fundamentales para que la experiencia de uso sea verdaderamente profesional tanto para los usuarios como para usted como administrador.  

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
service rsyslog restart
{% endhighlight %}

Configuramos logrotate 
{% highlight bash %}
{% include_relative logrotate_iptables.md %}
{% endhighlight %}

Se estima que estos ficheros de registros pueden ser de hasta 250 MB diarios. En base al espacio del que disponga en disco, puede configurar que guarde menos anecdóticos configurando el valor `rotate`.

## Configuración de Mensaje de Error
**Esta página de error sólo aparece para contenido HTTP, en HTTPS el navegador devuelve como resultado un error 1111**  
En la versión web de esta guía, puede descargar el fichero comprimido [error-html.tgz]({{site.baseurl}}/assets/download/error-html.tgz), que contiene un pequeño sitio que muestra un mensaje de error. En otro caso, debio serle proporcionado junto con la guía.

Envíelo al servidor ejecutando scp desde el equipo remoto que tiene el fichero:
{% highlight bash %}
scp error-html.tgz root@192.168.2.26:/root/fws
{% endhighlight %}

Borre el index.html que Debian coloca por defecto
{% highlight bash %}
rm /var/www/index.html
{% endhighlight %}

Descomprima error-html.tgz en /var/www/ 
{% highlight bash %}
tar -xzvf /root/fws/error-html.tgz -C /var/www/
{% endhighlight %}

Los siguientes comandos configuran la paǵina de error según la información contenida en `/root/fws/infraestructura`
{% highlight bash %}
source /root/fws/infraestructura.sh
unset srv;srv=(${listados[SRV]})
sed -i "s|<<ipaddresslan>>|${srv[0]}|" /var/www/{index.php,script/default.css}
sed -i "s|<<MarcadorInstitucion>>|$INSTITUCION|" /var/www/index.php
{% endhighlight %}

## Prueba de configuración
Compruebe que el directorio `/var/www/` quede de la siguiente forma:
{% highlight bash %}
tree /var/www/ 
├── categorias.php
├── img
│   ├── background.png
│   ├── blank1x1.gif
│   ├── fieldset_center.png
│   ├── fieldset_left.png
│   ├── fieldset_right.png
│   ├── footer_center.png
│   ├── footer_left.png
│   ├── footer_right.png
│   ├── logo.jpg
│   └── warning.png
├── index.php
└── script
    └── default.css 
{% endhighlight %}

Y por último, navegue a un sitio http (http://www.myspace.com es nuestra más sincera recomendación), y verifique que la página de error funcione correctamente.

## Reportes y Backup
Hacemos algunas modificaciones a Sarg para que  genere los reportes
{% highlight bash %}
sed -i -f - /etc/sarg/sarg.conf << MAFI
s_/var/log/squid/access.log_/var/log/squid3/access.log_g
s/Squid User Access Reports/Reportes de Acceso Squid/g
s%^output_dir\s.*%output_dir /var/www/sarg %g
s/charset Latin1/charset UTF-8/g
s/lastlog 0/lastlog 20/g
s/show_successful_message no/show_successful_message yes/g
MAFI
{% endhighlight %}

Creamos el directorio
{% highlight bash %}
mkdir /var/www/sarg
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

Crear el archivo de configuración de Mutt para enviar correo. Disponemos de una cuenta por defecto totalmente funcional
{% highlight bash %}
{% include_relative muttrc.md %}
{% endhighlight %}

Para activar el certificado, envíe un correo de prueba con 
{% highlight bash %}
mutt -nx -s "Probando desde cero el Mutt" fws@empresa.com
{% endhighlight %}

A continuación, aparecerán unos cuantos mensajes donde se le pide confirmar los certificados como válidos: Una vez aceptados, no requerirá intervención alguna nunca más.

Creamos un script que diariamente ejecute un backup de todos los archivos involucrados en la configuración de nuestro firewall. 
{% highlight bash %}
{% include_relative reportes.md %}
{% endhighlight %}

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
