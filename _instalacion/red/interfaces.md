# Configuración de la interfaz Loopback. 
auto lo 
iface lo inet loopback 

# RED WAN. 
# Con esta interfaz accede hacia su enlace a internet. 
auto $INW
iface $INW inet static 
    address $SRW
    gateway $GWW 

# RED LAN Primaria. 
auto $INL
iface $INL inet static 
    address ${SRV[0]}

# RED LAN Adicional. 
# Cree una subinterfaz en la interfaz LAN para agregar redes adicionales
# La siguiente es la forma recomendada para agregar interfaces según https://wiki.debian.org/NetworkConfiguration#Multiple_IP_addresses_on_one_Interface
# No olvide agregar a #LAN en /root/fws/infraestructura.sh
#auto $INL:0
#iface $INL:0 inet static 
#    address 10.168.5.1/24
 
# RED DMZ. En esta interfaz colocará los servidores
# En caso de no disponer de una interfaz física dedicada, haga un subinterfaz respecto a LAN
auto $IND 
iface $IND inet static 
    address $DMZ

# Configuración de los grupos IPSET a usar en IPTABLES.
post-up /root/fws/grupos_ipset.sh 

# Configuración de la tabla FILTER de IPTABLES. 
post-up /root/fws/firewall.sh

# Configuración de tabla NAT en IPTABLES
post-up /root/fws/rutas.sh 

# Configuración de reglas para DMZ en caso de tenerla
# Descomentarize si la necesita 
#post-up /root/fws/dmz.sh 

# Configuración de reglas especificas para el establecimiento dado.
post-up /root/fws/establecimiento.sh

