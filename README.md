# firewall

Configuración de Iptables + Squid + SquidGuard como Firewall/Proxy para pequeñas organizaciones

## Introducción
El presente es una recopilación de un poco más de seis meses de investigación y pruebas sobre la configuración de un Firewall en Linux desde cero.
Considerése una guía que es posible usar con su distribución favorita luego de un par de ajustes.

## ¿Que incluye?
El núcleo del proyecto es información sobre los siguientes aspectos de un Firewall:
* Configuración de Iptables
* Configuración de Squid
* Configuración de SquidGuard
Todo ello esta organizado en [firewall](http://vtacius.github.io/firewall/)

## Script auxiliares.
Hacen muchas cosas. Aparte de la función de backup.pl, la idea con los scripts es ayuden a que varios usuarios puedan acceder al firewall para realizar algunas tareas de mantenimiento con permisos reducidos.
Por ahora, los usuarios en MinsalAdminFirewall son capaces de:
* Modificar y aplicar las reglas de iptables. Los cambios realizados se envían por correo
* Revisar los logs para Iptables, Squid y SquidGuard
* Modificar y aplicar cambios para Squid/SquidGuard
* Obtener cierta información del sistema en formato influx. 

La instalación debería realizarse por medio de `instalacion.sh`. Luego, debe cambiarse la configuración en ~/.configuracion_reporte.ini 
## Instalación y configuración
La instalación debería realizarse por medio de `instalacion.sh`. 
Es necesario cambiar la configuración en el fichero ~/.configuracion_reporte

## Sobre como modificar esta guía. 
Pues que me tomé 
