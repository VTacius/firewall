---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title: Configuración de Squid
orden: 4
header: no
---

<div class="panel radius" markdown="1">
**Tabla de contenido**
{: #toc }
*  TOC
{:toc}
</div>

## Configuración de Squid
Borre el contenido del fichero de configuración de Squid, y copie el contenido siguiente.
Asegúrese de hacer una copia del contenido limpia, cuide los saltos de línea y tabulaciones.

{% highlight squid %}
{% include_relative squid3.md %}
{% endhighlight %}

## Personalizando la configuración: 
Los siguientes comandos configuran Squid de acuerdo a los parámetros en `/root/fws/infraestructura.sh`

{% highlight bash %}
sed -i "s_<<redlan>>_`perl -ne 'print $_=~m/^LAN=(.*)/' /root/fws/infraestructura.sh`_g" /etc/squid3/squid.conf
sed -i "s_<<ipaddresslan>>_`perl -ne 'print $_=~m/^SRV=(.*)/' /root/fws/infraestructura.sh`_g" /etc/squid3/squid.conf
sed -i "s/<<hostname>>/`hostname -f`/g" /etc/squid3/squid.conf
{% endhighlight %}

Luego, puede cambiar los valores por defecto para url_rewrite_children:

{% highlight bash %}
url_rewrite_children 5 startup=0 idle=1 concurrency=3
{% endhighlight %}

Puede ir probando a subir los valores hasta un máximo conocido de `url_rewrite_children 15 startup=0 idle=1 concurrency=5`, que sin embargo es fácilmente superable por algunos servidores

## Despliegue de configuración
Ni siquiera reinicie Squid3 aún, realizaremos el despliegue y pruebas de configuración se llevarán a cabo hasta que hayamos configurado squidGuard.

## Configuración avanzada
La experiencia dice que si su enlace no es de al menos 5 Mbps, es conveniente poner un límite global a squid.  
Puede calcular el valor a usar con  la formula `(x * 1000) / 8`, donde `x` es la velocidad de su enlace en Kbps.  
Tenga cuidado al convertir desde Mbps; en general, cerciórese bien de los datos de su enlace.

La ubicación de esta configuración es inmediatamente antes de las directivas http_access.

{% highlight squid %}
delay_pools 1
delay_class 1 1
delay_access 1 allow all
delay_parameters 1 64000/64000

http_access deny !Safe_ports
[...]
{% endhighlight %}
