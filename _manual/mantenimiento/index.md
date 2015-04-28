---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title: Tareas de mantenimiento
orden: 4
header: no
---
<div class="panel radius" markdown="1">
**Tabla de Contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Tareas de mantenimiento

## Las listas negras deben ser actualizadas una vez al mes.
Las listas negras no se actualizan tanto como quisiéramos. Por ahora, acordamos que una vez al mes es un buen periodo para buscar nuevas actualizaciones.
{% highlight bash %}
cd /var/lib/squidguard/db/ 
wget 'http://www.shallalist.de/Downloads/shallalist.tar.gz' 
tar -xzvf shallalist.tar.gz 
chown -R  proxy:proxy BL/ 
service squid3 restart 
{% endhighlight %}

Compruebe que todo este funcionando. Por si aún no recuerda como hacer eso, le comento que el siguiente fichero puede ser bastante definitivo sobre si un firewall esta funcionando correctamente
{% highlight bash %}
tail -f /var/log/squidguard/squidGuard.log 
{% endhighlight %}

## Las bases de datos deben ser borradas regularmente
Revise el espacio en disco disponible. Recordamos haberle pedido que hiciera un particionado más separado de lo común, siguiendo el esquema propuesto por el instalador de Debian.
{% highlight bash %}
df -h /var/
/dev/mapper/fwch-var   2,8G   643M  2,0G  25% /var 
{% endhighlight %}

Borre los archivos de base de datos que squidGuard ha estado creando y que se ha olvidado borrar.  
Luego, debe volver a crearlos.
{% highlight bash %}
rm -rf  /var/tmp/*
squidGuard -b -C /etc/squidguard/squidGuard.conf
{% endhighlight %}

Compruebe que todo este funcionando. Por si aún no recuerda como hacer eso, el registro de squidGuard puede indicar problemas finales, o el hecho que todo parezca estar funcionando bien a ese nivel.
{% highlight bash %}
tail -f /var/log/squidguard/squidGuard.log 
{% endhighlight %}
