#!/bin/bash
#### Archivo de configuración #### 

#### Listas de IP para grupos IPSET ##### 
declare -A listados
declare -A listados_red

### Listados de grupos REDES
## Definición de Redes LAN
## Recuerde agregar todas las redes LAN adicionales que haya agregado en /etc/network/interfaces
listados_red["LAN"]="
    10.168.2.0/24
"

## Redes que pertenecen a la Red WAN Alterna, 
## a configurar cuando tenga un enlace propio para navegación pero aún requiera usar de los servicios de DMZ MINSAL
## mediante un enlace destinado específicamente para ello
listados_red["RWA"]="
    10.10.20.0/24
    192.168.83.0/24
    192.168.85.0/24
    192.168.87.0/24
" 

### Listados de grupos HOST
## IP Interfaz de Red LAN 
## Recuerde configurar todas las interfaces LAN adicionales que haya agregado en /etc/network/interfaces
listados["SRV"]="
    10.168.2.1
"

## IP fuera de $LAN que tienen acceso administrativo a $SRW.
listados["admins"]=" 
    172.16.2.20
"

### Este es el punto perfecto para agregar listas personalizadas


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
SRW=192.168.2.6

### LAN 
## Interfaz LAN 
INL=eth1

## RED PBX
LBX=10.30.90.0/24
PBX=10.30.90.1

### DMZ
## Interfaz DMZ
IND=eth2
## IP interfaz de Red DMZ
SRD=10.20.20.1
## RED DMZ
DMZ=10.20.20.0/24 

#### Operaciones para la creación de grupos IPSET #####
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
