#!/bin/bash -x
## grupos_ipset.sh ## 
## El presente archivo configurará la tabla filter del Firewall.  
# Leemos el archivo de configuración 
source /root/fws/infraestructura.sh 
echo -e "\n\n GRUPOS_IPSET.SH\n\n" 

#### Operaciones para la creación de grupos IPSET #####
## Grupos con IP para listas varias
for grupo in ${!listados[*]}
do
    ipset -exist create $grupo hash:ip
    for ipa in ${listados[$grupo]}
    do  
        ipset -exist add $grupo $(echo $ipa | cut -d '/' -f 1)
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
