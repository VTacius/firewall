---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title: Configuración sobre el sistema
orden: 2
header: no
---

<div class="panel radius" markdown="1">
**Tabla de contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Configuración sobre el sistema

Tomando en cuenta que ahora tiene una red totalmente funcional, le será posible seguir con las siguientes instrucciones que incluyen la instalación de paquetes, actividad que hace uso de la red.

## /etc/apt/sources.list
Configure los repositorios con los tres siguientes comandos que puede copiar y pegar de una vez
{% highlight bash %}
rm /etc/apt/sources.list

cat << MAFI > /etc/apt/sources.list 
#Inicio del archivo /etc/apt/sources.list para servidores
deb http://debian.salud.gob.sv/debian/ wheezy main contrib non-free
deb-src http://debian.salud.gob.sv/debian/ wheezy main contrib non-free

deb http://debian.salud.gob.sv/debian/ wheezy-updates main contrib non-free
deb-src http://debian.salud.gob.sv/debian/ wheezy-updates main contrib non-free

deb http://debian.salud.gob.sv/debian-security/ wheezy/updates main contrib non-free
deb-src http://debian.salud.gob.sv/debian-security/ wheezy/updates main contrib non-free
#Fin del archivo /etc/apt/sources.list
MAFI
{% endhighlight %}

Y actualice el sistema, tarea que debe realizar cada tanto:
{% highlight bash %}
aptitude upgrade 
{% endhighlight %}


Instale todos los paquetes necesarios. Aptitude se encargará de revolver todas las dependencias necesarias
{% highlight bash %}
aptitude -y install squid3 squidGuard ipset apache2 apache2-mpm-prefork php5 sarg
{% endhighlight %}

Instale los siguientes paquetes para obtener herramientas de administración bastante probadas dentro de nuestro trabajo
{% highlight bash %}
DEBIAN_FRONTEND=noninteractive aptitude -y install vim htop iptraf vnstat lshw nmap pv python3 squidview sudo tcpdump tree tmux tshark bwm-ng
{% endhighlight %}

Configure VIM
Active, respectivamente, el resaltado de sintaxis, numerado de líneas,  identado a 4 espacios y, en el caso que el fondo de su terminal sea oscuro (Algo que recomiendo para la comodidad de sus ojos), configure el patrón de colores para tal efecto.
{% highlight bash %}
sed -i '/\"syntax on/c\syntax on' /etc/vim/vimrc
sed -i '/^syntax /a set number' /etc/vim/vimrc
sed -i '/syntax on/ a set tabstop=4\nset shiftwidth=4\nset expandtab' /etc/vim/vimrc
sed -i '/\"set background=dark/c\set background=dark' /etc/vim/vimrc
{% endhighlight %}

Active los módulos para manejo de sesiones FTP.
{% highlight bash %}
modprobe nf_nat_ftp
modprobe ip_conntrack_ftp
{% endhighlight %}

Agregar los módulos para manejo de sesiones FTP  a la carga de módulos en el arranque del sistema:
Configurar el reenvío de paquetes a través de interfaces, y activarla en caliente:
{% highlight bash %}
sed -i '$a ip_conntrack_ftp\nnf_nat_ftp ' /etc/modules
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
{% endhighlight %}
