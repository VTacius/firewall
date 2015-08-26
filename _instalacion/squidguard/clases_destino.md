########################################################################### 
### Clases de Filtrado 
## Para agregar más, busque en el directorio especificado en dbhome, y revise el contenido de cada directorio. 

## Dominios a los que se permite su acceso por parte de algunos usuarios
## Se recomienda el nombre sitios_{nombre}
#dest sitios_{nombre} {
#  domainlist custom/{nombre}.lst
#  log sitio-dest.log
#}

# URL especificas que, si bien incluidos en las listas negras, se confía para su acceso a TODOS los usuarios de la red. Por lo general, para sitios de actualizaciones y ese tipo de cosas
dest sitios { 
    domainlist custom/sitios.lst
    log sitio-dest.log
} 

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

dest juegos {
    domainlist BL/gamble/domains
    log ocio-dest.log
}

dest juegos-online {
    domainlist BL/hobby/games-online/domains
    log ocio-dest.log
}

dest juegos-misc {
    domainlist BL/hobby/games-misc/domains
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
