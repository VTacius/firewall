########################################################################### 
### Clases de Filtrado 
## Para agregar más, busque en el directorio especificado en dbhome, y revise el contenido de cada directorio. 

## Dominios a los que se permite su acceso por parte de algunos usuarios
## Se recomienda el nombre sitios_{nombre}
#dest sitios_{nombre} {
#  domainlist custom/{nombre}.lst
#  log destino.log
#}

# URL especificas que, si bien incluidos en las listas negras, se confía para su acceso a TODOS los usuarios de la red. Por lo general, para sitios de actualizaciones y ese tipo de cosas
dest sitios { 
    domainlist custom/sitios.lst
    log destino.log
} 

dest adv {
    domainlist BL/adv/domains
    log destino.log
}

dest archivos {
    expressionlist custom/extensiones.lst
    log destino.log
}

dest compras {
    domainlist BL/shopping/domains 
    log destino.log
}

dest descargas {
    domainlist BL/downloads/domains
    log destino.log
}

dest deportes {
    domainlist BL/recreation/sports/domains
    log destino.log
}

dest foros {
    domainlist BL/forum/domains
    log destino.log
}

dest juegos {
    domainlist BL/gamble/domains
    log destino.log
}

dest juegos-online {
    domainlist BL/hobby/games-online/domains
    log destino.log
}

dest juegos-misc {
    domainlist BL/hobby/games-misc/domains
    log destino.log
}

dest musica {
    domainlist BL/music/domains
    log destino.log
}

dest peliculas {
    domainlist BL/movies/domains
    log destino.log
}

dest porn {
    domainlist BL/porn/domains
    log destino.log
}

dest proxy {
    domainlist BL/anonvpn/domains
    log destino.log
}

dest radio {
    domainlist BL/webradio/domains
    log destino.log
}

dest redes {
    domainlist BL/socialnet/domains
    log destino.log
} 

dest sexo {
    domainlist BL/sex/lingerie/domains
    log destino.log
}

dest tracker {
    domainlist BL/tracker/domains
    log destino.log
}

dest warez {
    domainlist BL/warez/domains
    log destino.log
}
 
dest web-proxy {
    domainlist BL/redirector/domains
    log destino.log
}

dest web-tv {
    domainlist BL/webtv/domains
    log destino.log
}

dest webphone {
    domainlist BL/webphone/domains
    log destino.log
}
