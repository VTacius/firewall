# Configuración de la interfaz Loopback. 
auto lo 
iface lo inet loopback 

# RED WAN. Acá debe configurarse Gateway y DNS. 
# Con esta interfaz accede hacia su enlace a internet. 
# Revise las conexiones físicas de los puertos de red 
auto eth0 
iface eth0 inet static 
    address 192.168.2.6
    netmask 255.255.255.224 
    network 192.168.2.0 
    broadcast 192.168.2.31 
    gateway 192.168.2.1 

# RED LAN. Basta con hacer accesible la red hacia la red Local 
# Revise las conexiones físicas de los puertos de red 
auto eth1 
iface eth1 inet static 
    address 10.168.2.1
    netmask 255.255.255.0 
    network 10.168.2.0 
    broadcast 10.168.2.255 

# RED LAN Adicional. Cree una subinterfaz en la interfaz LAN para agregar redes adicionales
# La siguiente es la forma recomendada para agregar interfaces.
# Descomente en caso de ser necesario. No olvide agregar en /root/fws/infraestructura.sh
#auto eth1:0
#iface eth1:0 inet static 
#    address 10.168.3.1
#    netmask 255.255.255.0 
#    network 10.168.3.0 
#    broadcast 10.168.3.255 
 
# RED DMZ. En esta interfaz colocará los servidores
# Lo mejor será que esta interfaz sea física, pero no dude en configurarla en /root/fws/rutas.sh si no es posible
auto eth2 
iface eth2 inet static 
    address 10.20.20.1 
    netmask 255.255.255.0 
    network 10.20.20.0 
    broadcast 10.20.20.255

# Configuración de los grupos IPSET a usar en IPTABLES.
post-up /root/fws/grupos_ipset.sh 

# Configuración de la tabla FILTER de IPTABLES. Recuerde que al menos root debe tener permisos de ejecución 
post-up /root/fws/firewall.sh

# Configuración de tabla NAT en IPTABLES, y configuración de rutas
post-up /root/fws/rutas.sh 

# Configura una dmz en caso de tenerla
post-up /root/fws/dmz.sh 

# Configuración personalizada de reglas especificas para el establecimiento dado.
post-up /root/fws/establecimiento.sh
