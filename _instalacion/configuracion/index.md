---
layout: docs
site.author: Alexander Ortiz
author: Alexander Ortiz
title: Configuración Primaria de Sistema
orden: 1
header: no
---

<div class="panel radius" markdown="1">
**Tabla de contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Configuración Primaria del Sistema

## Fichero de configuración fws/infraestructura.sh
Empezamos creando fichero de configuración en `/etc/fws/infraestructura.sh` de la siguiente forma:

{% highlight bash %}
mkdir /etc/fws
cat << "MAFI" > /etc/fws/infraestructura.sh
{% include_relative infraestructura.md %}
MAFI
{% endhighlight bash %}

Gran parte de todo el procedimiento se basa en la información contenida en este fichero. Por tanto, sea cuidadoso de revisar cada aspecto y personalizarlo de acuerdo a sus necesidades

Creamos los demás ficheros que configuran Iptables:
{% highlight bash %}
touch /etc/fws/{firewall.sh,rutas.sh,infraestructura.sh,establecimiento.sh,dmz.sh,grupos_ipset.sh}
chmod 744 /etc/fws/{firewall.sh,rutas.sh,infraestructura.sh,establecimiento.sh,dmz.sh,grupos_ipset.sh}
{% endhighlight %}

## Consideraciones sobre la configuración de /etc/fws/infraestructura.sh
* Leálo. Hay suficientes comentarios allí para saber lo que tiene que hacer
* Para saber que interfaces de red tiene disponibles en el sistema, ejecute desde consola el comando `ip link show`. El nuevo sistema para [nombrado predictivo de interfaces de red](https://wiki.debian.org/NetworkConfiguration#Predictable_Network_Interface_Names) es diferente a lo que Debian nos tenía acostumbrados, pero no es nada del otro mundo. 
* Las redes no se escogen de forma caprichosa. Si este firewall es parte de una infraestructura más grande, será necesaria más configuración de parte de otros equipos, por lo que estas deben planificarse cuidadosamente 
