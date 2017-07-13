########################################################################### 
#### Archivo de configuración para squidGuard #### 
#### NO USE COMENTARIOS DENTRO DE {}
## Directorio de listas negras y log 
dbhome /var/lib/squidguard/db 
logdir /var/log/squidguard 

{% include_relative acl_tiempo.md %}
{% include_relative clases_destino.md %}
{% include_relative src_usuario.md %}
## Empiezan sus reglas personalizadas 
src usuarios_laboral {
    $(for r in ${listados_red['LAN']}; do printf "ip %s\n" $r; done)
    within  laboral
}

src usuarios_almuerzo {
    $(for r in ${listados_red['LAN']}; do printf "ip %s\n" $r; done)
    within  almuerzo
}

## Empiezan las acl_rules personalizadas
{% include_relative acl_rules.md %}
    usuarios_laboral  { 
        pass sitios !in-addr !adv !archivos !compras !descargas !deportes !foros !juegos !juegos-online !juegos-misc !musica !peliculas !porn !proxy !radio !redes !sexo !tracker !warez !web-proxy !web-tv !webphone !any 
        redirect http://$(echo ${SRV[0]} | cut -d '/' -f 1)/index.php?purl=%u&razon=%t 
    } 
   
    usuarios_almuerzo  { 
        pass sitios !in-addr !adv !archivos !compras !descargas !juegos !porn !proxy !radio !sexo !tracker !warez !web-proxy !any 
        redirect http://$(echo ${SRV[0]} | cut -d '/' -f 1)/index.php?purl=%u&razon=%t 
    } 
 
    default { 
        pass   none 
        redirect http://$(echo ${SRV[0]} | cut -d '/' -f 1)/index.php?purl=%u&razon=%t 
    } 
}
