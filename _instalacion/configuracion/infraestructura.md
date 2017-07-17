#!/bin/bash
#### Archivo de configuración #### 

#### Listas de IP para grupos IPSET ##### 
declare -A listados
declare -A listados_red

### Listados de grupos REDES
## Definición de Redes LAN
## Recuerde agregar todas las redes LAN adicionales que haya agregado en /etc/network/interfaces
listados_red["LAN"]="
    10.168.4.0/24
"

## Listados de Red WAN Alterna, 
## Ciertas Redes con algún grado de confianza, respecto al acceso HACIA ellas por parte de nuestro establecimiento
listados_red["RWA"]="
    10.10.20.0/24
    10.168.0.0/16
    192.168.0.0/16
" 

## Listados de Red MH
## El Ministerio de Hacienda requiere algunos permisos especiales
listados_red["MH"]="
    192.168.83.0/24
    192.168.85.0/24
    192.168.87.0/24
"

### Listados de grupos HOST
## IP Interfaz de Red LAN 
## Recuerde configurar todas las interfaces LAN adicionales que haya agregado en /etc/network/interfaces
## NOTA: Para este lista es importante configurar la RED en formato máscara: /mask
listados["SRV"]="
    10.168.4.1/24
    10.168.5.1/24
"

## IP fuera de $LAN que tienen acceso administrativo a $SRW.
listados["admins"]=" 
    172.16.2.20
"

### Este es el punto perfecto para agregar listas personalizadas


#### Datos Generales ####
## Nombre de la institución donde ha de configurarse
INSTITUCION="Establecimiento"
## Nombre del equipo
NOMBRE=fw-establecimiento
## Fondo monetario con el que se ha comprado el hardware donde corre este firewall 
FONDO_COMPRA=""
## Dominio del equipo (salud.gob.sv por defecto)
DOMINIO=organizacion.org
## Versión de la guía que esta usando para configurar
VERSION={{site.version_manual}}

#### Infraestructura de red ##### 
### WAN
## Interfaz WAN 
INW=eno1
## IP Interfaz de Red WAN
SRW=192.168.2.24/27
## Gateway 
GWW=192.168.2.1

### LAN
## Interfaz LAN
INL=eno2

### DMZ
## Interfaz DMZ
IND=enp3s0f0
## IP interfaz de Red DMZ
SRD=10.20.40.1
## Red DMZ
DMZ=10.20.40.0/24

### RED PBX
## Interfaz PBX.
## Suele ser la misma interfaz para DMZ en caso de no tener un puerto físico dedicado
INX=enp3s0f0
## IP interfaz de Red PBX
SRX=10.30.40.1
# Red PBX
PBX=10.30.40.0/24

### RED AP
## Interfaz AP.
## Suele ser la misma interfaz para LAN en caso de no tener un puerto físico dedicado
INP=eno2
## IP interfaz de Red AP
SRP=10.40.40.1
# Red AP
APN=10.40.40.0/24
