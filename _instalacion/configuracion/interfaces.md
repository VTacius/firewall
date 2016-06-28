# Configuración de la interfaz Loopback. 
auto lo 
iface lo inet loopback 

# RED WAN. Acá debe configurarse Gateway y DNS. 
# Con esta interfaz accede hacia su enlace a internet. 
# Revise las conexiones físicas de los puertos de red 
auto eth0 
iface eth0 inet static 
    address 192.168.2.26
    netmask 255.255.255.224 
    network 192.168.2.0 
    broadcast 192.168.17.31 
    gateway 192.168.2.1 

# RED LAN. Basta con hacer accesible la red hacia la red Local 
# Revise las conexiones físicas de los puertos de red 
auto eth1 
iface eth1 inet static 
    address 10.20.20.1
    netmask 255.255.255.0 
    network 10.20.20.0 
    broadcast 10.20.20.255 

# RED LAN Adicional. Cree una subinterfaz en la interfaz LAN para agregar redes adicionales
# Si no son necesarias, bastará con comentar la siguiente configuración
auto eth1:0
iface eth1:0 inet static 
    address 10.40.20.1
    netmask 255.255.255.0 
    network 10.40.20.0 
    broadcast 10.40.20.255 
 
# RED DMZ. En esta interfaz colocará los servidores
# Lo mejor será que esta interfaz sea física, pero no dude en configurarla en /root/fws/rutas.sh si no es posible
auto eth2 
iface eth2 inet static 
    address 10.30.20.1 
    netmask 255.255.255.0 
    network 10.30.20.0 
    broadcast 10.30.20.255

# RED MH. Se accede a los servicios del Ministerio de Hacienda 
# La interfaz hacia la red de HACIENDA y MINSAL será virtual, configurada en /root/fws/rutas.sh 
# En caso de tener una intefaz física disponible, tome de ejemplo la configuración de red LAN,
# exceptuando el gateway, y configure a continuación

# Configuración de la tabla FILTER de IPTABLES. Recuerde que al menos root debe tener permisos de ejecución 
post-up /root/fws/firewall.sh

# Configuración de tabla NAT en IPTABLES, y configuración de rutas
post-up /root/fws/rutas.sh 

# Configura una dmz en caso de tenerla
post-up /root/fws/dmz.sh 

# Configuración personalizada de reglas especificas para el establecimiento dado.
post-up /root/fws/establecimiento.sh
