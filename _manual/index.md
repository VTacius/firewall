---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title: Directivas para mantenimiento del Firewall
orden: 0
header: no
---
# Directivas para mantenimiento del Firewall
El siguiente proyecto tiene por finalidad sugerir una serie de pautas para darle mantenimiento al firewall anterior, que si bien recuerda, también era solo un número de pautas

## Comprobación rápida de la configuración de su Firewall

* Conéctese al servidor por SSH. Debe haber configurado la IP del equipo desde el cual se conecta en la lista `admins` en `/root/fws/infraestructura.sh`
* Revise el log de squidGuard. SquidGuard está tan alto en la configuración que sus registros sirven por si sólo para confirmar gran parte de toda la infraestructura.  
Este es el mensaje que squid debería mostrarle en la última línea
{% highlight squid %}
2013-06-24 14:21:07 [2868] INFO: squidGuard ready for requests (1372105267.827)
{% endhighlight %}
* Desde el navegador de un cliente, ingrese a www.sucursal.com y revise en los log de squidGuard que se accede a tráves de la intranet:  
{% highlight squid %}
1372105595.277     17 10.10.40.12 TCP_MISS/200 523 GET http://www.sucursal.com/ - DIRECT/192.168.83.34 text/html
{% endhighlight %}
* Acceda con su cliente FTP favorito (Por favor, que este no sea el navegador) al FTP en la DMZ de sucursal en ftp://192.168.87.2/

Estas acciones deberían ser suficientes para afirmar que la configuración de su proxy esta funcionando como se debe.  
Y no, no hay error alguno en llamarlas "Comprobaciones rápidas". El correcto funcionamiento de un Firewall puede ser un poco más complicado, tal como lo verá en las siguientes páginas
