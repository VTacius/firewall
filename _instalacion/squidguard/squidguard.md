########################################################################### 
#### Archivo de configuración para squidGuard #### 
#### NO USE COMENTARIOS DENTRO DE {}
## Directorio de listas negras y log 
dbhome /var/lib/squidguard/db 
logdir /var/log/squidguard 

### ACL de tiempo. 
## ¿Son estos los horarios que necesita? 
time laboral {
    weekly * 00:15 - 12:29
    weekly * 13:15 - 23:55
}

time almuerzo{
    weekly * 12:30 - 13:14
}

########################################################################### 
### Clases de Filtrado 
## Para agregar más, busque en el directorio especificado en dbhome, y revise el contenido de cada directorio. 

# URL especificas que, si bien incluidos en las listas negras, se confía para su acceso a TODOS los usuarios de la red. Por lo general, para sitios de actualizaciones y ese tipo de cosas
dest sitios { 
    domainlist custom/sitios.lst
    log sitio-dest.log
} 

## Dominios a los que se permite su acceso por parte de algunos usuarios
## Se recomienda el nombre sitios_{nombre}
#dest sitios_{nombre} {
#  domainlist custom/{nombre}.lst
#  log sitio-dest.log
#}

dest adv {
    domainlist BL/adv/domains
    log proxy-dest.log 
}

dest archivos {
    expressionlist custom/extensiones.lst
    log archivo-dest.log
}

dest compras {
    domainlist BL/shopping/domains 
    log ocio-dest.log
}

dest descargas {
    domainlist BL/downloads/domains
    log ocio-dest.log
}

dest deportes {
    domainlist BL/recreation/sports/domains
    log ocio-dest.log
}

dest foros {
    domainlist BL/forum/domains
    log ocio-dest.log
}

dest musica {
    domainlist BL/webradio/domains
    log ocio-dest.log
}

dest peliculas {
    domainlist BL/movies/domains
    log ocio-dest.log
}

dest porn {
    domainlist BL/porn/domains
    log adulto-dest.log
}

dest proxy {
    domainlist BL/anonvpn/domains
    log proxy-dest.log
}

dest radio {
    domainlist BL/webradio/domains
    log ocio-dest.log
}

dest redes {
    domainlist BL/socialnet/domains
    log redes-dest.log
} 

dest sexo {
    domainlist BL/sex/lingerie/domains
    log adulto-dest.log
}

dest tracker {
    domainlist BL/tracker/domains
    log proxy-dest.log
}

dest warez {
    domainlist BL/warez/domains
    log ocio-dest.log
}
 
dest web-proxy {
    domainlist BL/redirector/domains
    log proxy-dest.log
}

dest web-tv {
    domainlist BL/webtv/domains
    log ocio-dest.log
}

dest webphone {
    domainlist BL/webphone/domains
    log ocio-dest.log
}

###########################################################################
## ACL de redes 
## Combine acá las ACL de tiempo y redes. 
## Especifique en el archivo /var/lib/squidguard/db/custom/irrestrictos.lst aquellas IP que puedan navegar sin restricciones 
## Especifique en el archivo /var/lib/squidguard/db/custom/restrictos.lst aquellas IP que no deban tener navegación.

## IP de usuario a los que se les permite el acceso a sitios_{nombre}
#src lista_{nombre} {
#  iplist custom/usuarios_{nombre}.lst
#  within  laboral
#}

src lista_blanca {
    iplist custom/irrestrictos.lst
    within  laboral
}

src lista_negra {
    iplist custom/restrictos.lst
    within  laboral
}

src usuarios_laboral {
    ip  <<redlan>>
    within  laboral
}

src usuarios_almuerzo {
    ip  <<redlan>>
    within  almuerzo
}

# ACL RULES: 
# Propiamente dichas, los nombres se corresponden con las ACL de redes. 
# Agregue lo siguiente entre lista-negra y usuarios-laboral
  # lista_{nombre} {
  #   pass sitios_{nombre}
  # }
  # Para habilitar el acceso de los usuarios en lista_{nombre} a los sitios especificados en sitios_{nombre}
acl { 
    lista_blanca { 
        pass any 
    } 
    
    lista_negra {
        redirect http://<<ipaddresslan>>/index.php?purl=%u&razon=%t
    }else{
        redirect http://<<ipaddresslan>>/index.php?purl=%u&razon=%t
    }

    usuarios_laboral  { 
        pass sitios !in-addr !adv !archivos !compras !descargas !deportes !foros !musica !peliculas !porn !proxy !radio !redes !sexo !tracker !warez !web-proxy !web-tv !webphone !any 
        redirect http://<<ipaddresslan>>/index.php?purl=%u&razon=%t 
    } 
   
    usuarios_almuerzo  { 
        pass sitios !in-addr !adv !archivos !compras !descargas !porn !proxy !radio !sexo !tracker !warez !web-proxy !any 
        redirect http://<<ipaddresslan>>/index.php?purl=%u&razon=%t 
    } 
 
    default { 
        pass   none 
        redirect http://<<ipaddresslan>>/index.php?purl=%u&razon=%t 
    } 
}
