#!/bin/bash -x 
## dmz.sh ##
## El presente archivo configurará la tabla filter del Firewall. 
# Leemos el archivo de configuración 
source /root/fws/infraestructura.sh
echo -e "\n\n DMZ.SH\n\n"
 
#### FILTER ####
### OUTPUT ###
## Salida desde $IND
OUTPUTD="iptables -t filter -A OUTPUT -o $IND -d $DMZ" 
$OUTPUTD -p tcp -m multiport --sport 22 -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "Respuesta a tráfico originado en LAN" -j ACCEPT
$OUTPUTD -p tcp -m multiport --dport 22 -m comment --comment "Servicios permitidos hacia LAN" -j ACCEPT
$OUTPUTD -p icmp -m comment --comment "Sondeo de Red DMZ" -j ACCEPT  

### INPUT ### 
## Entrada hacia $IND
INPUTD="iptables -t filter -A INPUT -i $IND -s $DMZ -d $SRD" 
$INPUTD -p tcp -m multiport --dport 22 -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "Respuesta a tráfico originado en LAN" -j ACCEPT
$INPUTD -p tcp -m multiport --sport 22 -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "Respuesta a Servicios permitidos hacia LAN" -j ACCEPT
$INPUTD -p tcp -m multiport --dport 22 -m conntrack --ctstate NEW -m comment --comment "Tráfico originado en LAN" -j ACCEPT 
$INPUTD -p icmp -m comment --comment "Sondeo hacia la interfaz DMZ" -j ACCEPT 

iptables -t filter -A INPUT -i $IND -j LOG --log-prefix "IPTABLES IN DMZ: "
iptables -t filter -A OUTPUT -o $IND -j LOG --log-prefix "IPTABLES OUT DMZ: "

### DMZ ###
## Servicios permitidos a servidores DMZ
FWDD="iptables -t filter -A FWD_DMZ -i $IND -s $DMZ -o $INW"
$FWDD -p tcp -m multiport --dport 80,443,22  -d 10.10.20.0/24 -m conntrack --ctstate NEW -m comment --comment "Servicios permitidos hacia DMZ MINSAL para DMZ" -j ACCEPT
$FWDD -p tcp -m multiport --dport 587,465 -m conntrack --ctstate NEW -m comment --comment "Cliente de correo SMTP para DMZ" -j ACCEPT
$FWDD -p tcp -m multiport --dport 110,995 -m conntrack --ctstate NEW -m comment --comment "Cliente de correo POP3 para DMZ" -j ACCEPT 
$FWDD -p udp -m multiport --dport 53,123 -m comment --comment "DNS y NTP para DMZ" -j ACCEPT

## Servicios permitidos de Red LAN a Servidores
FWDD="iptables -t filter -A FWD_DMZ -i $INL -s $LAN -o $IND"
$FWDD -p tcp -m multiport --dport 80,443,22 -m comment --comment "Servicios básicos a RED LAN" -j ACCEPT
$FWDD -p icmp -m comment --comment "Sondeo de LAN a DMZ" -j ACCEPT

#### NAT ####
### PREROUTING mediante SERVICIOS 
iptables -t nat -A SERVICIOS -i $INL -s $LAN -d $DMZ -m multiport -p tcp --dport 80,443 -j ACCEPT -m comment --comment "Paso directo de LAN hacia DMZ LOCAL"
### POSTROUTING ###
iptables -t nat -A POSTROUTING -s $DMZ -d 10.10.20.20/0 -o $INW -j ACCEPT -m comment --comment "Salida de DMZ "
iptables -t nat -A POSTROUTING -s $LAN -d $DMZ -o $IND -j ACCEPT -m comment --comment "Vamos de LAN hacia DMZ LOCAL"
iptables -t nat -A POSTROUTING -s $DMZ -d 0.0.0.0/0 -o $INW -j MASQUERADE -m comment --comment "Vamos hacia internet desde DMZ"
