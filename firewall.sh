#!/bin/bash

function error_exit {
    echo "$1" 
    exit "${2:-1}"  ## Return a code specified by $2 or 1 by default.
}

# Define quién hace la llamada
tipo=${1:-"usuario"}

# Configuración de los grupos IPSET a usar en IPTABLES
/etc/fws/grupos_ipset.sh 2> /dev/null

# El grupo ipset debe existir. 
# TODO: No valida que el grupo tenga miembros, ni que haya alguno útil
ipset -q -L admins >/dev/null 2>&1 || error_exit "El grupo admins no existe"

# Configuración de la tabla FILTER de IPTABLES. Recuerde que al menos root debe tener permisos de ejecución
/etc/fws/firewall.sh 2> /dev/null

# Configuración de tabla NAT en IPTABLES, y configuración de rutas
/etc/fws/rutas.sh 2> /dev/null

# Configura una dmz en caso de tenerla
dmz=$(egrep -c '^(IND|SRD|DMZ)' /etc/fws/infraestructura.sh)
if [ 3 -eq $dmz ]; then
    /etc/fws/dmz.sh 2> /dev/null
fi

# Configuración personalizada de reglas especificas para el establecimiento dado.
/etc/fws/establecimiento.sh 2> /dev/null

case $tipo in
    "usuario")
        echo "Verificando cambios en los ficheros de configuración"
        # Enviamos los cambios para (escarnio) conocimiento de todos
        nohup sudo /usr/local/bin/diferencias.pl >/dev/null 2>&1 &
        exit
esac
