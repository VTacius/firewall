---
layout: docs
site.author: Alexander Ortiz
author: Alexander Ortiz
title: Configuración sobre el sistema
orden: 3
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
{% highlight bash %}
rm /etc/apt/sources.list

cat << MAFI > /etc/apt/sources.list 
#Inicio del archivo /etc/apt/sources.list para servidores
deb http://debian.salud.gob.sv/debian/ stretch main contrib non-free
deb-src http://debian.salud.gob.sv/debian/ stretch main contrib non-free

deb http://debian.salud.gob.sv/debian/ stretch-updates main contrib non-free
deb-src http://debian.salud.gob.sv/debian/ stretch-updates main contrib non-free

deb http://debian.salud.gob.sv/debian-security/ stretch/updates main contrib non-free
deb-src http://debian.salud.gob.sv/debian-security/ stretch/updates main contrib non-free
#Fin del archivo /etc/apt/sources.list
MAFI
{% endhighlight %}

Y actualice el sistema, tarea que debe realizar cada tanto:
{% highlight bash %}
apt update
apt upgrade 
{% endhighlight %}

Los siguientes paquetes son necesarios para las funciones críticas de su firewall.
{% highlight bash %}
apt install -y squid squidguard{,-doc} ipset apache2 libapache2-mod-php7.0 php7.0 vim
{% endhighlight %}

El siguiente paquete va para DHCP
{% highlight bash %}
apt install -y isc-dhcp-server
{% endhighlight %}

Instale los siguientes paquetes para obtener herramientas de monitoreo y administración
{% highlight bash %}
echo -e "wireshark-common\twireshark-common/install-setuid\tboolean\tfalse" | debconf-set-selections
apt -y install nmap tree pv sudo lshw iptraf tcpdump tmux tshark bwm-ng iptstate 
{% endhighlight %}

Los siguientes paquetes son necesarios para los scripts auxiliares, y como estos, son opcionales. Aunque también se verifican en el script de instalación de los mismos, es probable que quiera instalarlos de una vez. 
{% highlight bash %}
apt install -y libtext-diff-perl libconfig-simple-perl libemail-sender-perl libemail-sender-transport-smtps-perl libemail-sender-transport-smtps-perl libemail-mime-perl libio-all-perl
{% endhighlight %}

Configure VIM  
Active, respectivamente y a su gusto, identado a 4 espacios, numerado de líneas y, en el caso que el fondo de su terminal sea oscuro, el patrón de colores para tal efecto.  
Por último, configure el comportamiento más clásico para mouse
{% highlight bash %}
sed -i '/syntax on/ a set tabstop=4\nset shiftwidth=4\nset expandtab' /etc/vim/vimrc
sed -i '/\"set background=dark/c\set background=dark' /etc/vim/vimrc
sed -i -r 's/(set\smouse=)\w/\1r/' /usr/share/vim/vim80/defaults.vim
sed -i '/^syntax /a set number' /etc/vim/vimrc
{% endhighlight %}

Configure alternatives editor  
Este podría considerarse cuestión de gustos, pero nano puede llegar a considerarse engorroso a la hora de modificar ciertos ficheros
{% highlight bash %}
update-alternatives --set editor /usr/bin/vim.basic
{% endhighlight %}

Agregar los módulos para manejo de sesiones FTP  a la carga de módulos en el arranque del sistema:  
Configurar el reenvío de paquetes a través de interfaces, y activarla en caliente:
{% highlight bash %}
sed -i '$a ip_conntrack_ftp\nnf_nat_ftp ' /etc/modules
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
{% endhighlight %}

Si no va reiniciar el sistema antes de hacer prueba, será necesario cargar los módulos anteriores en el sistema con los siguientes comandos:
{% highlight bash %}
modprobe nf_nat_ftp
modprobe ip_conntrack_ftp
{% endhighlight %}

