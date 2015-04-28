---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title: Otras tareas habituales
orden: 6
header: no
---
<div class="panel radius" markdown="1">
**Tabla de Contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Otras tareas habituales
Siendo este prácticamente el final del camino, es posible que haya llegado a él con un profundo cariño por la consola. Si es el caso, seguramente quiera manipular algunos datos 
desde la consola.

* Muestra todos los sitios bloqueados
{% highlight bash %}
awk '$10~/^DIRECT\/-|10\.20\.20\.1$/ && $4~/[^[1-9]*\./ {print  $8}' /var/log/squid3/access.log | awk -F '/' '{print $1 "" $3}' | sort | uniq -c | sort -gr
{% endhighlight %}
* Muestra el top-ten de los sitios bloqueados
{% highlight bash %}
awk '$10~/^DIRECT\/-|10\.20\.20\.1$/ && $4~/[^[1-9]*\./ {print  $8}' /var/log/squid3/access.log | awk -F '/' '{print $1 "" $3}' | sort | uniq -c | sort -gr | head -n 10
{% endhighlight %}
* Acceso de navegación por IP
{% highlight bash %}
awk '$10!~/DIRECT\/\-/ && $4~/[^[1-9]*\./ {print $4}' /var/log/squid3/access.log | sort | uniq -c | sort -gr 
{% endhighlight %}
* Top ten de IP
{% highlight bash %}
awk '$10!~/DIRECT\/\-/ && $4~/[^[1-9]*\./ {print $4}' /var/log/squid3/access.log | sort | uniq -c | sort -gr | head -n 10
{% endhighlight %}
* Estos son los sitios más accesados, pero incluye a los prohibidos
{% highlight bash %}
awk '$10~/^DIRECT\/-|([1-9]+\.*)+$/ && $4~/[^[1-9]*\./ {print  $8}' /var/log/squid3/access.log | awk -F '/' '{print $1 "" $3}' | sort | uniq -c | sort -gr
{% endhighlight %}
* Top Ten
{% highlight bash %}
awk '$10~/^DIRECT\/-|([1-9]+\.*)+$/ && $4~/[^[1-9]*\./ {print  $8}' /var/log/squid3/access.log | awk -F '/' '{print $1 "" $3}' | sort | uniq -c | sort -gr | head -n 10
{% endhighlight %}
