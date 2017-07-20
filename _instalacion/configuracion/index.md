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
Empezamos creando fichero de configuración en `/root/fws/infraestructura.sh` de la siguiente forma:

{% highlight bash %}
mkdir ~/fws
cat << "MAFI" > /root/fws/infraestructura.sh
{% include_relative infraestructura.md %}
MAFI
{% endhighlight bash %}

Gran parte de todo el procedimiento se basa en la información contenida en este fichero. Por tanto, sea cuidadoso de revisar cada aspecto y personalizarlo de acuerdo a sus necesidades

Creamos parte de los demás ficheros que componen el proyecto:
{% highlight bash %}
mkdir ~/fws/{tools,archivo}
touch ~/fws/{,archivo/}{firewall.sh,rutas.sh,infraestructura.sh,establecimiento.sh,dmz.sh,grupos_ipset.sh}
chmod 744 ~/fws/{,archivo/}{firewall.sh,rutas.sh,infraestructura.sh,establecimiento.sh,dmz.sh,grupos_ipset.sh}
{% endhighlight %}

## Consideraciones sobre la configuración de fws/infraetructura.sh
* Leálo. Hay suficientes comentarios allí para saber lo que tiene que hacer
* Para saber que interfaces de red tiene disponibles en el sistema, ejecute desde consola el comando `ip link show`. El nuevo sistema para [nombrado predictivo de interfaces de red](https://wiki.debian.org/NetworkConfiguration#Predictable_Network_Interface_Names) es diferente a lo que Debian nos tenía acostubrado, pero no es nada del otro mundo. (Sus ventajas son discutibles según mi experiencia, por otra parte, siempre estaré de lado de subir la complejidad en cualquier sistema)
* Un encargado en nivel superior ha de especificarle que redes debe usar. 
