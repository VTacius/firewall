---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title : "Configuración de red: Filtros de paquetes, rutas y nateo"
orden : 3
---

# Configuración de red: Filtros de paquetes, rutas y nateo

## Configuración de archivo de infraestructura
El siguiente archivo configura la infraestructura de red que ha ideado dentro de su Establecimiento.  
Los demás archivos de configuración leerán desde acá los valores que han de usar para configurarse.  
Los comentarios son bastante ilustrativos sobre como debe configurarse cada opción:
{% highlight bash %}
    {% include_relative infraestructura.md %}
{% endhighlight %}

## Configuración del Filtrado de Paquetes de Red
Cree el fichero de configuración para la tabla Filter de Iptables en `/root/fws/firewall.sh`  
El contenido de dicho fichero de muestra a continuación

__Personalizando la configuración:__ Toda regla adicional a la estructura de este fichero debe ser agregada en el fichero `/root/fws/establecimiento.sh`, o en `/root/fws/dmz.sh` si aplica en la infraestructura de red a su cargo; de esta forma podrá seguir recibiendo  actualizaciones de este fichero a futuro sin problemas para sus configuraciones.  
__En suma, esto significa que esta totalmente prohibido modificar este fichero.__

Pese a todo, el fichero pretende ser bastante didáctico, esperando de hecho que pueda llegar a comprender su funcionamiento, lo cual le hará estar mejor preparado frente a posibles eventualidades
{% highlight bash %}
    {% include_relative firewall.md %}
{% endhighlight %}

## Configuración de reglas específicas para el establecimiento
En el fichero `/root/fws/establecimiento.sh`, se configuran las reglas que desea agregar a las actuales. Ya que el Firewall es restrictivo por defecto, se supone que debiera configurar sólo reglas para aceptar algún servicio en particular, usualmente a usuarios particulares.

__Agregar un servicio para toda la red__
Si bien podría no ser el caso más frecuente, bastaría agregar una regla como la siguiente con sus respectivas modificaciones  
{% highlight bash %}
$FWDB -p tcp -m multiport --dport [[puertos]] -m conntrack --ctstate NEW -m comment --comment [[comentario]] -j ACCEPT 
{% endhighlight %}

Donde:  
[[puerto]]
 : Una lista separada por comas de puertos que el servicio (O servicios) necesitan

[[comentario]]
 : Una breve reseña del servicio añadido.

__Agregar un servicio para usuarios especificos:__
Podría ser una práctica más común de lo que cree.  
Primero necesita configurar un grupo de ip en `/root/fws/infraestructura.sh`, siguiendo el ejemplo del grupo `"ejemplo"`, agregando una IP por línea.  
Luego, referencia ese grupo dentro de la regla personalizada de la siguiente forma.

{% highlight bash %}
iptables -t filter -A FORWARD -o $WAN 
-m set --match-set [[grupo]] src -o $INL -p tcp -m multiport --dport [[puertos]] -m conntrack --ctstate NEW -m comment --comment [[comentario]] -j ACCEPT
{% endhighlight %}

Donde:
[[grupo]]
 : Es el nombre del grupo configurado en `/root/fws/infraestructura.sh.`


