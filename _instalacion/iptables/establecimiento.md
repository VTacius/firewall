#!/bin/bash -x 
## establecimiento.sh #### 
source /root/fws/infraestructura.sh
echo -e "\n\n ESTABLECIMIENTO.SH\n\n"

## Servicios adicionales en el servidor
# Aún cuando lo desaconsejemos rotundamente, es posible habilitar un par de servicios adicionales en el Firewall
# No especificar el estado con conntrack
# Para habilitar un servidor hacia INL, es decir, como publicando un DHCP hacia redes LAN
# iptables -t filter -A SRVADD -i $INL -m set --match-set SRV dst -p udp -m multiport --dport 67,68 -j ACCEPT
# Para habilitar servicios hacia FWD_DMZ, es decir, publicando un servicio como http hacia internet
# iptables -t filter -A SRVADD -i $IND -d $SRD -p udp -m multiport --dport 53,123 -m comment --comment "Servicios básicos a RED LAN" -j ACCEPT

### Creación de interfaces adicionales para servicios publicados
## Recuerde empezar las interfaces adicionales desde :1 
## Asegurése de la IP que esta configurando acá sea la misma del servicio que esta publicando
# ifconfig eth0:1 192.168.2.3/27
# ifconfig eth0:2 192.168.2.5/27

## Se presentan algunas pautas sobre la manera de configurar nuevos permisos en su red
# Acceso a toda su red LAN hacia lo que sea que halla después de WAN. Podría especificar con -d un destino especifico
FWD_SLAN="iptables -t filter -A FWD_LOCAL -i $INL -m set --match-set LAN src -o $INW"
# Acceso desde el con entrada en interfaz LAN y salida en WAN, se recomienda que use un grupo ipset
FWD_SSET="iptables -t filter -A FWD_LOCAL -i $INL -o $INW"
# Acceso especial para un permiso, usualmente desde DMZ Minsal, hacia dentro de LAN
FWD_SWAN="iptables -t filter -A FWD_LOCAL -i $INW"
# Acceso de toda la Red DMZ a un nuevo servicios
FWD_SDMZ="iptables -t filter -A FWD_DMZ -i $IND -s $DMZ -o $INW"
## Configura reglas especificas del establecimiento en la cadena FWD_DMZ referenciada en la cadena FORWARD
FWD_DDMZ="iptables -t filter -A FWD_DMZ -i $INL -m set --match-set LAN src -o $IND"

## Trafico de servicios avanzados
# Revise cuales son verdaderamente necesarios para su establecimiento

# Acceso remoto al servidor de Hacienda
$FWD_SLAN -p tcp --dport 63231 -m conntrack --ctstate NEW -j ACCEPT

## Configuración necesaria para Comunicarse con Antivirus Kaspersky
#$FWD_SLAN -d 10.10.20.5 -p tcp -m multiport --dport 13000,13111,14000 -m conntrack --ctstate NEW -j ACCEPT
#$FWD_SLAN -d 10.10.20.5 -p udp -m multiport --dport 7,67,69,13000,1500,1501 -j ACCEPT
#$FWD_SLAN -d 10.10.20.5 -p icmp -j ACCEPT
#$FWD_SWAN -s 10.10.20.5 -p udp -m multiport --dport 15000,15001 -j ACCEPT
#$FWD_SWAN -s 10.10.20.5 -p tcp -m multiport --dport 13000,13111,14000 -j ACCEPT

# Publica un servicio hacia la WAN. 
# Quizá este interesado en compartir impresoras con Hacienda
# Considere configurar esto en dmz.sh si acaso aplica para su infraestructura
iptables -t nat -A SERVICIOS -d 192.168.2.5 -j DNAT --to-destination 10.20.20.10
iptables -t filter -A FWD_LOCAL -d 10.20.20.10 -p tcp -m multiport --dport 4000 -j ACCEPT

# Servicios publicados hacia WAN
iptables -t nat -A SERVICIOS -d 192.168.2.6 -j DNAT --to-destination 10.30.20.5
iptables -t filter -A FWD_DMZ -d 10.30.20.5 -p tcp -m multiport --dport 80 -j ACCEPT

# Las siguientes reglas deberían permitir la comunicación entre <<telefono>> y <<pbx>>
# cuando es <<telefono>> el que se encuentra en dicho servidor. No es necesario cambiar nada en el nateo
# $FWD_SSET -s <<telefono>> -d <<pbx>> -p udp -j ACCEPT
# $FWD_SSET -s <<pbx>> -d <<telefono>> -p udp -m multiport --dport 5004,5005,5060 -j ACCEPT

### Empiece sus reglas a partir de este punto

