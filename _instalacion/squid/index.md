---
layout: docs
site.author: Alexander Ortiz
author: Alexander Ortiz
title: Configuración de Squid
orden: 5
header: no
---

<div class="panel radius" markdown="1">
**Tabla de contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Configuración de Squid
Copiar y ejecutar los siguientes comandos desde consola creará un fichero de configuración para Squid en su mínima forma

{% highlight bash %}
chown proxy:proxy /var/spool/squid/dump
mkdir /var/spool/squid/dump
source ~/fws/infraestructura.sh
cat <<MAFI > /etc/squid/squid.conf
{% include_relative squid.md %}
MAFI
{% endhighlight %}

# Personalizando la configuración: 
Puede cambiar los valores por defecto para `url_rewrite_children`.  
**Es importante, sin embargo, que siempre use `concurrency=0`**, [squidGuard no es capaz de procesar adecuadamente las peticiones formadas con esta configuración por parte de Squid](http://apuntestuxianos.blogspot.com/2017/06/apuntes-sobre-el-error-de-squid.html)

{% highlight bash %}
url_rewrite_children 15 startup=15 idle=15 concurrency=0
{% endhighlight %}

En realidad, es altamente recomendable iniciar squid con todos los hilos que planeé  hacer disponibles, y que estos no mueran el estar ocioso.  
El problema es que estos hilos tienen una inicialización muy costosa, así que si la petición de un usuario necesita de la creación de uno, este termina esperando un tiempo espantoso en su navegador 

## Marcas conocidas
`url_rewrite_children 25 startup=25 idle=25 concurrency=0`, AMD Opteron(tm) Processor 4332 HE 4 GB de RAM
`url_rewrite_children 30 startup=30 idle=30 concurrency=0`, AMD Opteron(tm) Processor 4332 HE  16 GB de RAM (Este podría mucho más)

# Despliegue de configuración
No reinicie Squid aún, el despliegue y pruebas de configuración se llevarán a cabo hasta que hayamos configurado squidGuard.

# Configuración avanzada  

## Limite global al ancho de banda usado por squid
La experiencia dice que si su enlace no es de al menos 5 Mbps, es conveniente poner un límite global a squid.  

Puede calcular el valor a usar con  la formula `(x * 1000) / 8`, donde `x` es la restricción en kbps que quiere hacer al uso de ancho de banda.

Hasta 2 Mb, considere usar el 75%: (2048 / 4) * 3 
Luego, hasta 5 Mb, puede considerar 80%: (5120 / 5) * 4

La ubicación de esta configuración es inmediatamente antes de las directivas `http_access`. El siguiente ejemplo limitara a 1536 Kb:

{% highlight squid %}
[...]
ftp_passive off

delay_pools 1
delay_class 1 1
delay_access 1 allow all
delay_parameters 1 192000/192000

http_access deny NONE
[...]
{% endhighlight %}

Es posible que quiera considerar una configuración para tráfico de conocidad voracidad por su ancho de banda:

{% highlight squid %}
[...]
ftp_passive off

delay_pools 3

#640 kbps. 1/8 del total
acl STREAMING dstdomain .yimg.com
acl STREAMING dstdomain .fbcdn.net
acl STREAMING dstdomain .twimg.com
acl STREAMING dstdomain .mega.co.nz
acl STREAMING dstdomain .nflxso.net
acl STREAMING dstdomain .cloudup.com
acl STREAMING dstdomain .openload.co
acl STREAMING dstdomain .akamaihd.net
acl STREAMING dstdomain .akamaized.net
acl STREAMING dstdomain .angelcam.com
acl STREAMING dstdomain .gfrvideo.com
acl STREAMING dstdomain .oloadcdn.net
acl STREAMING dstdomain .nflxvideo.net
acl STREAMING dstdomain .flowplayer.org
acl STREAMING dstdomain .vkuserlive.com
acl STREAMING dstdomain .googlevideo.com
acl STREAMING dstdomain .dailymotion.com
acl STREAMING dstdomain .drive.amazonaws.com
acl STREAMING dstdomain .whatsapp.com
delay_class 1 2
delay_access 1 allow STREAMING
delay_parameters 1 80000/80000 160000/160000

#1280 kbps. 2/8 del total
acl DISPENSA dstdomain .muug.ca
acl DISPENSA dstdomain .office365
acl DISPENSA dstdomain .microsoft.com
acl DISPENSA dstdomain .dropbox.com
acl DISPENSA dstdomain .360safe.com
acl DISPENSA dstdomain .ff.avast.com
acl DISPENSA dstdomain .cdn.livefyre.com
acl DISPENSA dstdomain .drive.google.com
acl DISPENSA dstdomain .windowsupdate.com
acl DISPENSA dstdomain .geo.kaspersky.com
acl DISPENSA dstdomain .mirror.steadfast.net
acl DISPENSA dstdomain .googleusercontent.com
delay_class 2 2
delay_access 2 allow DISPENSA
delay_parameters 2 80000/80000 160000/160000

# 3200 kbps. 5/8 del total
delay_class 3 1
delay_access 3 allow all
delay_parameters 3 400000/400000

http_access deny NONE
[...]

{% endhighlight %}

Los tres pool definen el siguiente comportamiento:

+ Al acceder a los sitios en la ACL STREAMING, se puede hacer uso de hasta 640 kbps en total, y cada usuario que caiga en dicho bucket no puede usar más de 512 kbps
+ Al acceder a los sitios en la ACL DISPENSA, se puede hacer uso de hasta 640 kbps en total, y cada usuario que caiga en dicho bucket no puede usar más de 512 kbps. Cabe destacar que ambos son bucket totalmente diferentes
+ Para todo el tráfico restante, squid tratará de usar no más de 1536 Kbps.

Si necesita agregar una bucket adicional, debe configurarse antes del bucket por defecto, el último en el ejemplo

## Autenticación de usuarios mediante LDAP
En nuestra configuración, tres cosas son necesarias  

+ Agregar la configuración mediante las directivas `auth_param` al principio del fichero
+ Cambiar nuestra ACL `usuarios`
+ Eliminar `intercept` de la directiva `http_port`

{% highlight squid %}
auth_param basic program /usr/lib/squid3/squid_ldap_auth -v 3 -b "ou=Users,dc=empresa,dc=com" -f "(uid=%s)" -u "uid" -H ldap://ldap.empresa.com 
auth_param basic children 50 
auth_param basic realm Servidor Proxy para INSTITUCION
[...]

acl usuarios proxy_auth REQUIRED 
acl [...]
[...]

http_port 10.20.20.1:3128
http_port [...]
[...]
{% endhighlight %}

Desde este punto, puede seguir usando las ACL de squidGuard basadas en direcciones IP, lo que sería un verdadero desperdicio. Por tanto, busque en las configuraciones avanzadas de squidGuardla configuración necesaria para que también use LDAP
