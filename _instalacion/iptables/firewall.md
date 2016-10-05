#!/bin/bash -x 
## firewall.sh ## 
## El presente archivo configurará la tabla filter del Firewall.  
# Leemos el archivo de configuración 
source /root/fws/infraestructura.sh 
echo -e "\n\n FIREWALL.SH\n\n" 
# Borramos las reglas de filtrado, reinicializamos los contadores y borramos las cadenas personalizadas que existan al momento de ejecutar el script 
iptables -t filter -F 
iptables -t filter -Z 
iptables -t filter -X 
# Configuramos las reglas por defecto en DROP 
iptables -t filter -P INPUT   DROP 
iptables -t filter -P OUTPUT  DROP 
iptables -t filter -P FORWARD DROP 
### OUTPUT ### 
## Salida desde $INL 
iptables -t filter -A OUTPUT -m set --match-set SRV src -m set --match-set SRV dst -m comment --comment "Permisivo hacia IP de interfaz LAN" -j ACCEPT 
OUTPUTL="iptables -t filter -A OUTPUT -o $INL -m set --match-set LAN dst" 
$OUTPUTL -p tcp -m multiport --sport 3128,22,80 -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "Respuesta a tráfico originado en LAN" -j ACCEPT 
$OUTPUTL -p tcp -m multiport --dport 22 -m comment --comment "Servicios permitos hacia LAN" -j ACCEPT 
$OUTPUTL -p icmp -m comment --comment "Sondeo desde Firewall hacia si mismo" -j ACCEPT 
## Salida desde $INW 
OUTPUTW="iptables -t filter -A OUTPUT -o $INW"
$OUTPUTW -m set --match-set admins dst -m multiport -p tcp --sport 80,22 -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "Puertos abiertos para WAN"  -j ACCEPT
$OUTPUTW -d 0.0.0.0/0 -m multiport -p tcp --dport 53,80,443,22,20,21,389,465 -m comment --comment "Servicios permitos hacia WAN"  -j ACCEPT
$OUTPUTW -d 0.0.0.0/0 -m multiport -p udp --dport 53,123,33434:33523 -m comment --comment "Servicios permitos hacia WAN" -j ACCEPT
$OUTPUTW -p icmp -m comment --comment "Sondeo a exteriores desde interfaz WAN" -j ACCEPT 

### INPUT ### 
## Entrada hacia $SRV
iptables -t filter -A INPUT -m set --match-set SRV src -m set --match-set SRV dst -m comment --comment "Permisivo hacia IP de interfaz LAN" -j ACCEPT
INPUTL="iptables -t filter -A INPUT -i $INL -m set --match-set LAN src -m set --match-set SRV dst" 
$INPUTL -p tcp -m multiport --dport 3128,22,80 -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "Respuesta a tráfico desde LAN" -j ACCEPT
$INPUTL -p tcp -m multiport --sport 22 -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "Respuesta a tráfico originado en Firewall" -j ACCEPT
$INPUTL -p tcp -m multiport --dport 3128,22,80 -m conntrack --ctstate NEW -m comment --comment "Tráfico entrante permitido desde LAN" -j ACCEPT 
$INPUTL -p icmp -j ACCEPT 

## Reglas adicionales para servicios que el firewall pueda ofrecer a LAN o DMZ
iptables -t filter -N SRVADD
$INPUTL -j SRVADD -m comment --comment "Enviamos a las reglas INPUT personalizadas"

## Entrada hacia $INW
INPUTW="iptables -t filter -A INPUT -i $INW"
$INPUTW -m set --match-set admins src -m multiport -p tcp --dport 80,22 -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "Respuestas para #admins" -j ACCEPT 
$INPUTW -m set --match-set admins src -p icmp -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "Respuesta ICMP para #admins" -j ACCEPT
$INPUTW -s 0.0.0.0/0 -m multiport -p tcp --sport 53,80,443,22,20,21,389,465 -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "Respuestas de tráfico originado en Firewall" -j ACCEPT 
$INPUTW -s 0.0.0.0/0 -m multiport -p udp --sport 53,123,33434:33523 -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "Respuestas de tráfico originado en Firewall" -j ACCEPT 
$INPUTW -m set --match-set admins src -m multiport -p tcp --dport 80,22 -m conntrack --ctstate NEW -m comment --comment "Sarg y SSH entrante para #admins" -j ACCEPT
$INPUTW -m set --match-set admins src -p icmp -m conntrack --ctstate NEW -m comment --comment "ICMP para #admins" -j ACCEPT
$INPUTW -p icmp -m conntrack --ctstate ESTABLISHED,RELATED -m comment --comment "ICMP iniciado por Firewall" -j ACCEPT

### FORWARD 
## Habilitamos todo el tráfico de respuesta
iptables -t filter -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -t filter -A FORWARD -i $INL -m set --match-set LAN src -o $INW -p icmp -m conntrack --ctstate ESTABLISHED,RELATED  -j ACCEPT

## Administración y monitoreo remoto para grupo admins
FWDW="iptables -t filter -A FORWARD -i $INW -m set --match-set"
$FWDW admins src -o $INL -m set --match-set LAN dst -p icmp -m comment --comment "Monitoreo remoto" -j ACCEPT
$FWDW admins src -o $INL -m set --match-set LAN dst -p tcp -m multiport --dport 22,3389,5800,5900,5901,5902 -m conntrack --ctstate NEW -m comment --comment "Administración remota" -j ACCEPT

## Tráfico de servicios básicos
FWDL="iptables -t filter -A FORWARD -i $INL -m set --match-set LAN src -o $INW"
$FWDL -p udp -m multiport --dport 53,123 -m conntrack --ctstate NEW -j ACCEPT
$FWDL -p tcp -m multiport --dport 80,443  -m set --match-set RWA dst -m conntrack --ctstate NEW -m comment --comment "Cliente WEB para DMZ Hacienda" -j ACCEPT
$FWDL -p tcp -m multiport --dport 53,587,465 -m conntrack --ctstate NEW -m comment --comment "Cliente de correo SMTP" -j ACCEPT
$FWDL -p tcp -m multiport --dport 110,995 -m conntrack --ctstate NEW -m comment --comment "Cliente de correo POP3" -j ACCEPT 
$FWDL -p tcp -m multiport --dport 20,21 -m conntrack --ctstate NEW -m comment --comment "Cliente de correo FTP" -j ACCEPT 

## Reglas personalizadas
# Servicios personalizados
iptables -t filter -N FWD_LOCAL
iptables -t filter -A FORWARD -j FWD_LOCAL -m comment --comment "Enviamos a las reglas FORWARD personalizadas"

## Reglas DMZ
iptables -t filter -N FWD_DMZ
iptables -t filter -A FORWARD -j FWD_DMZ -m comment --comment "Enviamos a las reglas de DMZ"

## LOGGIN - No dude en desactivarlo si el registro es inmenso
iptables -t filter -A FORWARD -j LOG --log-prefix "IPTABLES FWD: "
iptables -t filter -A INPUT -i $INL -j LOG --log-prefix "IPTABLES IN LAN: "
iptables -t filter -A INPUT -i $INW -j LOG --log-prefix "IPTABLES IN WAN: "
iptables -t filter -A OUTPUT -o $INL -j LOG --log-prefix "IPTABLES OUT LAN: "
iptables -t filter -A OUTPUT -o $INW -j LOG --log-prefix "IPTABLES OUT WAN: "
