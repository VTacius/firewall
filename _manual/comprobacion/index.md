---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title: Comprobación exhaustiva de la configuración de su Firewall
orden: 1
header: no
---
<div class="panel radius" markdown="1">
**Tabla de Contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Comprobación exhaustiva de la configuración de su Firewall
Las siguiente pautas pretenden estar en el orden que se recomienda para ejecutar, siéntase a gusto de ejecutarlas en el orden que más le parezca.  
Se espera que pueda memorizar todos estos puntos. No se preocupe, que con el tiempo verá que es más sencillo de lo que cree.   
Se recomienda que revise que estos datos la primera vez, más que para comprobar la funcionalidad del Firewall, para que pueda acostumbrarse al correcto comportamiento del Firewall.  

## ¿Esta la red correctamente conectada?
Revise, memorice y tenga siempre bien señalado la correcta conexión de los cables hacia los puertos del equipo. Recuerde que cada interfaz del firewall tiene una función diferente, y es implica que no deberían estar conectadas en el mismo segmento de red.
Respete el esquema de conexión según lo ha planeado desde el principio. Le evitará sendos dolores de cabeza

## Ping. La herramienta más útil en el mundo del networking
Revise que que el cliente desde el cual esta probando y que pertenece a la red LAN pueda hacer ping al Firewall. Toda la red LAN tiene este y otros permisos asociados, su falla debería ser motivo de alarma.
{% highlight bash %}
ping [[ip-firewall]]
{% endhighlight %}

## Traceroute: ¿Hasta donde llega la traza?
Desde el servidor Firewall, puede revisar el camino que los paquetes toman hasta un punto conocido.
{% highlight bash %}
traceroute 8.8.8.8
{% endhighlight %}

Un verdadero diagnóstico basado en una traza de traceroute requiere que usted ya conozca un poco de los nodos dentro de la red de su proveedor por los cuales pasa.

## Telnet: Revisando puertos abiertos.
Como usted ya sabrá por haber revisado toda la documentación, su servidor tiene abierto al menos los puertos 22, 80 y 3128 para la red LAN.
Telnet es una herramienta tan arcaica que resulta fascinante para revisar este punto en específico:
{% highlight bash %}
telnet [[ip-firewall]] [[puerto]]
{% endhighlight %}

Trás una conexión exitosa, telnet devuelve un prompt de la siguiente forma:
{% highlight bash %}
Trying 10.20.20.1...
Connected to 10.20.20.1.
Escape character is '^]'.
[[espacio en blanco listo para recibir órdenes]]
{% endhighlight %}
