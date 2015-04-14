#!/bin/bash -x ## establecimiento.sh #### source /root/fws/infraestructura.sh 
echo -e "\n\n ESTABLECIMIENTO.SH\n\n"

## Servicios adicionales en el servidor
# No es que lo recomendemos apliamente, pero podría habilitar un par de servicios adicionales en el Firewall
# No especificar el estado con conntrack
# Para habilitar un servicio hacia LAN
# iptables -t filter -A SRVADD -i $INL -d $SRV -p udp -m multiport --dport 53,87,88,123 -j ACCEPT
# Para habilitar servicios hacia FWD_DMZ
# iptables -t filter -A SRVADD -i $IND -d $SRD -p udp -m multiport --dport 53,123 -m comment --comment "Servicios básicos a RED LAN" -j ACCEPT

## Creación de interfaces adicionales para servicios publicados
# Recuerde empezar las interfaces adicionales desde :1 
# Asegurése de la IP que esta configurando acá sea la misma del servicio que esta publicando
#ifconfig eth0:1 192.168.2.5/27
#ifconfig eth0:2 192.168.2.6/27

## El presente archivo configurará reglas especificas del establecimiento en la cadena FWD_LOCAL referenciada en la cadena FORWARD de la tabla FILTER de IPTABLES
FWD_SLAN="iptables -t filter -A FWD_LOCAL -i $INL -s $LAN -o $INW"
FWD_SSET="iptables -t filter -A FWD_LOCAL -i $INL -o $INW"
FWD_SWAN="iptables -t filter -A FWD_LOCAL -i $INW"

## Configura reglas especificas del establecimiento en la cadena FWD_DMZ referenciada en la cadena FORWARD
FWD_SDMZ="iptables -t filter -A FWD_DMZ -i $IND -s $DMZ -o $WAN"
FWD_ODMZ="iptables -t filter -A FWD_DMZ -i $IND -s $DMZ -o $IND"

## Trafico de servicios avanzados
# Revise cuales son verdaderamente necesarios para su establecimiento
# Acceso remoto al servidor de Hacienda
$FWD_SLAN -p tcp --dport 63231 -m conntrack --ctstate NEW -j ACCEPT

### Empiece sus reglas a partir de este punto
## Configuración necesaria para Comunicarse con Antivirus Kaspersky
# $FWD_SSET -d 10.10.20.5 -p tcp -m multiport --dport 13000,13111 -m conntrack --ctstate NEW -j ACCEPT
# $FWD_SSET -d 10.10.20.5 -p udp -m multiport --dport 7,67,69,13000,1500,1501 -j ACCEPT
# $FWD_SSET -d 10.10.20.5 -p icmp -j ACCEPT
# $FWD_SWAN -s 10.10.20.5 -p udp -m multiport --dport 15000,15001 -j ACCEPT

# Publica un servicio hacia la WAN. 
# Quizá este interesado en compartir impresoras con Hacienda
# Considere configurar esto en dmz.sh si acaso aplica para su infraestructura
#iptables -t nat -A SERVICIOS -d 192.168.2.5 -j DNAT --to-destination 10.20.20.10
#iptables -t filter -A FWD_LOCAL -d 10.20.20.10 -p tcp -m multiport --dport 4000 -j ACCEPT

### Empiece sus reglas para FWD_DMZ a partir de este punto
# Servicios publicados hacia WAN
#iptables -t nat -A SERVICIOS -d 192.168.2.6 -j DNAT --to-destination 10.30.20.5
#iptables -t filter -A FWD_DMZ -d 10.30.20.5 -p tcp -m multiport --dport 80 -j ACCEPT
