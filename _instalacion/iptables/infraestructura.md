#!/bin/bash
#### Archivo de configuración #### 

#### Listas de IP para grupos IPSET ##### 
declare -A listados
declare -A listados_red

### Listados de grupos REDES
## Definición de Redes LAN
listados_red["LAN"]="
    10.40.20.0/24
    10.20.20.0/24
"

## Redes que pertenecen a la Red WAN Alterna
listados_red["RWA"]="
    10.10.20.0/24
    192.168.83.0/24
    192.168.85.0/24
    192.168.87.0/24
" 
### Listados de grupos HOST
## IP Interfaz de Red LAN 
listados["SRV"]="
    10.20.20.1
    10.40.20.1
"

## IP fuera de $LAN que tienen acceso administrativo a $SRW.
listados["admins"]=" 
    172.16.2.20
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
DOMINIO=empresa.com
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

### DMZ
## Interfaz DMZ
IND=eth2
## IP interfaz de Red DMZ
SRD=10.30.20.1
## RED DMZ
DMZ=10.30.20.0/24 

### Red WAN Alterna hacia DMZ Minsal y MH
## Descomente y configure cuando su interfaz WAN apunte hacia un servicio privado de internet, es decir
## que no seamos nosotros quiénes le brindemos el servicio de Internet

## Interfaz red WAN alterna
INA=eth0:0
## IP interfaz de Red WAN Alterna
# Específique el prefijo de red
SRA=192.168.10.15/24
## Gateway que se usa hacia DMZ en Minsal
GWA=192.168.10.1

#### Operaciones relacionadas con los grupos IPSET #####
## Grupos con IP para listas varias
for grupo in ${!listados[*]}
do
    ipset -exist create $grupo hash:ip
    for ipa in ${listados[$grupo]}
    do
        ipset -exist add $grupo $ipa
    done
done

for grupo in ${!listados_red[*]}
do
    ipset -exist create $grupo hash:net
    for red in ${listados_red[$grupo]}
    do
        ipset -exist add $grupo $red
    done
done
