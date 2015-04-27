---
layout: page
show_meta: false
title: "Primer Vistazo"
permalink: "/primer_vistazo/"
header: no
---

Una forma de entender la infraestructura que se pretende montar es mediante el siguiente gráfico
![Imagen]({{site.url}}/assets/proyecto/Diagrama_de_Red.png)

## Consideraciones sobre las interfaces

El servidor debería contar con cuatro interfaces, con unos cuantos cambios es posible usar hasta un mínimo de dos:  

* Una interfaz para Internet y Acceso a los servidores en la DMZ de otras sucursales  
* Una interfaz para DMZ y LAN. Los problemas de seguridad (Que sea fisícamente la misma interfaz entraña algunos peligros), no es un problema tan grave como el efecto sobre el rendimiento de ambas redes.  
* Por tanto, el mejor escenario es tener al menos tres interfaces: DMZ, LAN y Acceso a Redes externas

## Consideraciones sobre los permisos configurados por defecto

Después del tráfico permitido, todo el tráfico será negado por defecto, y antes de ellos, se registrara en los ficheros correspondientes en `/var/log/iptables`.
Los permisos por defecto pueden describirse de la siguiente forma

### Tráfico permitido desde Red LAN  

* Los usuarios desde LAN pueden usar sus clientes de correo SMTP, POP3 y FTP activo/pasivo hacia internet y Web hacia sucursales.
* No esta permitido el tráfico HTTP/HTTPS hacia internet. El servidor proxy en el firewall es la única forma en que un usuario puede navegar por internet, por tanto, todas sus reglas son ley.
* Los usuarios desde LAN pueden acceder a los puertos por defecto para los servicios SSH (Serían capaces de administrar el servidor o realizar operaciones mediante dicho protocol), 80 (Servidor web que devuelve mensajes de error para squidGuard); 3128 (Servicio de proxy mediante Squid).
* Los usuarios desde LAN pueden acceder a los puertos por defecto para los servicios NTP y DNS
* Los usuarios desde LAN pueden realizar operaciones mediante tráfico ICMP hacia el servidor Firewall.
* Los usuarios pueden acceder a los puertos por defecto para los servicios HTTP, HTTPS y SSH de los servidores en DMZ
* Otros servicios por parte del Servidor Firewall para la red LAN pueden ser agregados en el fichero `establecimiento.sh` mediante la cadena personalizada `SRVADD`.
* Permisos adicionales para acceder a Redes externas pueden ser agregados en el fichero `establecimiento.sh` mediante la cadena personalizada `FWD_LOCAL`. 
* Permisos adicionales para acceder a Red DMZ pueden ser agregados en el fichero `establecimiento.sh` mediante la cadena personalizada `FWD_DMZ`.

### Tráfico permitido desde Red WAN  
Descontando nuestras excepciones, nada en internet puede iniciar tráfico con nuestro servidor firewall o con la red LAN.   

* Las excepciones son aquellos equipos cuya ip se encuentre en la lista `admins` que se configura en `infraestructura.sh`
* Los usuarios `admins` pueden acceder a los puertos por defecto para los servicios SSH (Administración remota en equipos GNU/Linux), RDP (Escritorio remoto para Windows) y VNC (Escritorio Remoto para equipos con GNU/Linux) en los equipos de la red LAN que tengan activos dichos servicios.
* Los usuarios `admins` pueden realizar operaciones mediante tráfico ICMP hacia la red LAN
* Los usuarios `admins` puede acceder los puertos por defecto para servicios SSH (Administración del servidor) y Web (Registro de navegación mediante Sarg)

### Tráfico permitido para servidor Firewall  
Si bien es cierto que el firewall no es una estación de trabajo, hay tráfico específico de sus actividades que ha sido activado.  

* Servidor Firewall es capaz de iniciar tráfico en los puertos por defecto para los servicios SSH (Administración remota en equipos GNU/Linux) en los equipos de la red LAN que así lo hayan activado.
* Servidor Firewall es capaz de iniciar tráfico HTTP (en puerto 80 y 8080) y HTTPS hacia cualquier parte, para funcionar como servidor Proxy de toda la red LAN
* Servidor Firewall es capaz de iniciar tráfico SSH con cualquier servidor
* Servidor Firewall es capaz de iniciar su cliente FTP activo para funcionar como servidor Proxy de las páginas web que tengan enlaces FTP, se recomienda sin embargo no configurarlo en un cliente especializado por cuestiones de rendimiento. 
* El servidor Firewall es capaz de enviar correos eléctronicos con SMTPS para enviar backup y otros correos a los administradores.

### Tráfico permitido desde Red DMZ

* Los servidores en DMZ no son capaces de usar el servicio proxy de nuestro Firewall, su tráfico web debería limitarse al los servidores de la DMZ.
* Los servidores en DMZ son capaces de usar clientes SMTP y POP3. 
* Los servidores en DMZ pueden acceder a servicos DNS y NTP.
* Permisos adicionales pueden ser agregados en el fichero `establecimiento.sh` mediante la cadena personalizada `FWD_DMZ`.
