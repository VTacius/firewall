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
    for net in ${RWA[*]}
    do
        route add -net $net gw $GWA
    done
fi

### PREROUTING
NATPR="iptables -t nat -A PREROUTING -i $INL -s $LAN"
$NATPR -d $LAN -m multiport -p tcp --dport 80,443 -j ACCEPT -m comment --comment "Paso directo entre equipos de la misma red"
$NATPR -m set --match-set rwa dst -m multiport -p tcp --dport 80,443  -j  ACCEPT -m comment --comment "Paso directo hacia Red WAN Alterna"

## Creamos las reglas personalizadas SERVICIOS
iptables -t nat -N SERVICIOS 
iptables -t nat -A PREROUTING -j SERVICIOS -m comment --comment "Enviamos a las reglas PREROUTING personalizadas"

#### Mandamos todo el tráfico web hacia squid para proxy transparente, o al menos para evitar todo intento de traspasar el firewall
$NATPR -d 0.0.0.0/0 -p tcp --dport 443 -j REDIRECT --to-port 3128
$NATPR -d 0.0.0.0/0 -p tcp --dport 80 -j REDIRECT --to-port 3128

### POSTROUTING
iptables -t nat -A POSTROUTING -s $LAN -d 10.10.20.0/24 -o $INW -j ACCEPT -m comment --comment "Vamos hacia DMZ"
iptables -t nat -A POSTROUTING -s $LAN -m set --match-set rwa dst -o $INW -j MASQUERADE -m comment --comment "Vamos hacia RWA"
iptables -t nat -A POSTROUTING -s $LAN -d 0.0.0.0/0 -o $INW -j MASQUERADE -m comment --comment "Vamos hacia Internet"
