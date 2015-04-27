#!/bin/bash
#### Archivo de configuración #### 

#### Listas de IP para grupos IPSET ##### 
declare -A listados
## IP fuera de $LAN que tienen acceso administrativo a $SRW.
listados["admins"]=" 
    172.16.2.20
    192.168.2.20
"
## La eterna lista de ejemplo
listados["ejemplo"]="
    10.20.20.5
"
#### Datos Generales ####
## Nombre de la institución donde ha de configurarse
INSTITUCION="Firewall de prueba"
## Nombre del equipo
NOMBRE=firewall
## Dominio del equipo (salud.gob.sv por defecto)
DOMINIO=salud.gob.sv
## Versión de la guía que esta usando para configurar
VERSION={{site.version_manual}}

#### Infraestructura de red ##### 
### WAN
## Interfaz WAN 
INW=eth0
## IP Interfaz de Red WAN
SRW=192.168.10.15

### LAN 
## Interfaz LAN
INL=eth1
## IP Interfaz de Red LAN 
SRV=10.20.20.1
## Red LAN
LAN=10.20.20.0/24

### DMZ
## Interfaz DMZ
IND=eth2
## IP interfaz de Red DMZ
SRD=10.30.20.1
## Red DMZ
DMZ=10.30.20.0/24 

### Red WAN Alterna hacia DMZ Minsal y MH
## Descomente y configure cuando su interfaz WAN apunte hacia un servicio privado de internet, es decir
## que no seamos nosotros quiénes le brindemos el servicio de Internet

## Interfaz red WAN alterna
#INA=eth0:0
## IP interfaz de Red WAN Alterna
# Específique el prefijo de red
#SRA=192.168.10.15/24
## Gateway que se usa hacia DMZ en Minsal
#GWA=192.168.10.1

#### Operaciones relacionadas con los grupos IPSET #####
## Redes que pertenecen a la Red WAN Alterna
RWA="
    10.10.20.0/24
    192.168.83.0/24
    192.168.85.0/24
    192.168.87.0/24
" 
## Creación de grupos IPSET para permisos específicos
for grupo in ${!listados[*]}
do
    ipset -exist create $grupo hash:ip
    for ipa in ${listados[$grupo]}
    do
        ipset -exist add $grupo $ipa
    done
done

## Grupo RWA con Redes para Red WAN Alterna
ipset -exist create rwa hash:net
for net in ${RWA[*]}
do
    ipset -exist add rwa $net
done
