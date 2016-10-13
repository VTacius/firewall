#!/bin/bash -x 
## rutas.sh ## 
## El presente archivo configurará la tabla NAT de iptables 
# Leemos el archivo de configuración 
source /root/fws/infraestructura.sh
echo -e "\n\n RUTAS.SH\n\n"

# Borramos las reglas de filtrado, reinicializamos los contadores y borramos las cadenas personalizadas que existan al momento de ejecutar el script
iptables -t nat -F
iptables -t nat -Z
iptables -t nat -X

#### Rutas ##### 
### Creación de las rutas hacia Red WAN Alterna En caso de ser necesario
a=$(egrep -c '^(INA|SRA|GWA)' /root/fws/infraestructura.sh)
if [ $a -eq 3 ]; then 
    ifconfig $INA $SRA
    for net in ${listado_red[RWA]}
    do
        route add -net $net gw $GWA
    done
fi

### PREROUTING
NATPR="iptables -t nat -A PREROUTING -i $INL -m set --match-set LAN src"
$NATPR -m set --match-set LAN dst -m multiport -p tcp --dport 80,443 -j ACCEPT -m comment --comment "Excluimos equipos de la misma red del Nateo"
$NATPR -m set --match-set RWA dst -m multiport -p tcp --dport 80,443 -j ACCEPT -m comment --comment "Paso directo hacia Red WAN Alterna"
## Creamos las reglas personalizadas SERVICIOS en PREROUTING de NAT, que tienen a bien ocurrir antes de un nateo de tráfico web
iptables -t nat -N SERVICIOS 
iptables -t nat -A PREROUTING -j SERVICIOS -m comment --comment "Enviamos a las reglas PREROUTING personalizadas"
## Mandamos todo el tráfico web hacia squid para proxy transparente, o al menos para evitar todo intento de traspasar el firewall
$NATPR -d 0.0.0.0/0 -p tcp --dport 443 -j REDIRECT --to-port 3128
$NATPR -d 0.0.0.0/0 -p tcp --dport 80 -j REDIRECT --to-port 3128

### POSTROUTING
NATPO="iptables -t nat -A POSTROUTING -m set --match-set LAN src"
## Recordar que en un entorno de pruebas es posible que si haya que natear el contenido hacia la DMZ Institucional
$NATPO -d 10.10.20.0/24 -o $INW -j ACCEPT -m comment --comment "Vamos hacia DMZ MINSAL"
$NATPO -m set --match-set RWA dst -o $INW -j MASQUERADE -m comment --comment "Vamos hacia RWA"
$NATPO -d 0.0.0.0/0 -o $INW -j MASQUERADE -m comment --comment "Vamos hacia Internet"
