---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title: Extendiendo las ACL de red para su Firewall
orden: 2
header: no
---
<div class="panel radius" markdown="1">
**Tabla de Contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Extendiendo las ACL de red para su Firewall

## Agregar un servicio para toda la red
Si bien podría no ser el caso más frecuente, bastaría agregar una regla como la siguiente con sus respectivas modificaciones  
{% highlight bash %}
$FWD_SLAN -d <<destino>> -p tcp -m multiport --dport <<puerto>> -m conntrack --ctstate NEW -j ACCEPT
{% endhighlight %}

Donde:  
<<destino>>
 : Dirección IP del servidor donde se encuentra el servicio que quiere hacer accesible

<<puerto>>
 : Una lista separada por comas de puertos que el servicio (O servicios) necesitan

<<comentario>>
 : Una breve reseña del servicio añadido.

## Agregar un servicio para usuarios especificos:
Podría ser una práctica más común de lo que cree. De hecho, sugerimos que así sea.  
Primero necesita configurar un grupo de ip en `/root/fws/infraestructura.sh`, siguiendo el ejemplo del grupo `"ejemplo"`, agregando una IP por línea.  
Luego, referencia ese grupo dentro de la regla personalizada de la siguiente forma.

{% highlight bash %}
$FWD_SSET -m set --match-set <<grupo>> src -d <<destino>> -p tcp -m multiport --dport <<puertos>> -j ACCEPT
{% endhighlight %}

Donde:
<<grupo>>
 : Es el nombre del grupo configurado en `/root/fws/infraestructura.sh.`

## Publicación de servicios
Para publicar un servicio, bastaría con hacer uso de la cadena personalizada SERVICIOS en conjunto con las reglas de acceso en FWD_LOCAL 
{% highlight bash %}
iptables -t nat -A SERVICIOS -d 192.168.2.6 -j DNAT --to-destination 10.30.20.5
iptables -t filter -A FWD_LOCAL -d 10.30.20.5 -p tcp -m multiport --dport 80 -j ACCEPT
{% endhighlight %}
En casos muy especificos, podría necesitar que algún dispositivo no pase de ninguna forma por el proxy. La cadena SERVICIOS le sería útil para eliminar la redirección HTTP de dicho dispositivo, ya que ocurre antes de dichas reglas
