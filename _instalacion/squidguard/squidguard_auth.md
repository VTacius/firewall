########################################################################### 
#### Archivo de configuración para squidGuard #### 
#### NO USE COMENTARIOS DENTRO DE {}
## Directorio de listas negras y log 
dbhome /var/lib/squidguard/db 
logdir /var/log/squidguard 

########################################################################### 
### Primeras configuraciones para USUARIOS Y GRUPOS LDAP 
ldapbinddn cn=lectura,dc=empresa,dc=com 
ldapbindpass PassUsuarioLectura
## ldap cache time in seconds 
ldapcachetime  300 
## Versión de LDAP a usar 
ldapprotover 3 

{% include_relative acl_tiempo.md %}
{% include_relative clases_destino.md %}
{% include_relative src_usuario.md %}
## Empiezan sus reglas personalizadas 

# Grupo Domains Admins 
src domain_admins_usuarios_laboral { 
    ip  <<redlan>> 
    ldapusersearch ldap://<<serverldap>>/cn=Domain%20Admins,<<basegrupos>>?memberUid?sub?(&(objectclass=sambaGroupMapping)(memberUid=%s)) 
    within  laboral 
    log users 
} 

src domain_admins_usuarios_almuerzo { 
    ip  <<redlan>>  
    ldapusersearch ldap://<<serverldap>>/cn=Domain%20Admins,<<basegrupos>>?memberUid?sub?(&(objectclass=sambaGroupMapping)(memberUid=%s)) 
    within  almuerzo 
    log users 
} 

# Grupo no http_noacces 
src http_noacces_usuarios_laboral { 
    ip  <<redlan>>  
    ldapusersearch ldap://<<serverldap>>/cn=http_noacces,<<basegrupos>>?memberUid?sub?(&(objectclass=sambaGroupMapping)(memberUid=%s)) 
    within  laboral 
    log users 
} 

src http_noacces_usuarios_almuerzo { 
    ip  <<redlan>>  
    ldapusersearch ldap://<<serverldap>>/cn=http_noacces,<<basegrupos>>?memberUid?sub?(&(objectclass=sambaGroupMapping)(memberUid=%s)) 
    within  almuerzo 
    log users 
} 

## Empiezan las acl_rules. 
{% include_relative acl_rules.md %}
domain_admins_usuarios_laboral  { 
        pass sitios !in-addr !adv !archivos !compras !descargas !deportes !foros !musica !peliculas !porn !proxy !radio !redes !sexo !tracker !warez !web-proxy !web-tv !webphone !any
        redirect http://<<ipaddresslan>>/index.php?purl=%u&razon=%t 
    } 
     
    domain_admins_usuarios_almuerzo  { 
        pass sitios !in-addr !adv !archivos !compras !descargas !porn !proxy !radio !sexo !tracker !warez !web-proxy !any  
        redirect http://<<ipaddresslan>>/index.php?purl=%u&razon=%t 
    } 
     
    http_noacces_usuarios_laboral { 
        pass sitios !in-addr !adv !archivos !compras !descargas !deportes !foros !musica !peliculas !porn !proxy !radio !redes !sexo !tracker !warez !web-proxy !web-tv !webphone !any y 
        redirect http://<<ipaddresslan>>/index.php?purl=%u&razon=%t 
    } 

    http_noacces_usuarios_almuerzo { 
        pass sitios !in-addr !adv !archivos !compras !descargas !porn !proxy !radio !sexo !tracker !warez !web-proxy !any 
        redirect http://<<ipaddresslan>>/index.php?purl=%u&razon=%t 
    } 
 
    default { 
        pass   none 
        redirect http://<<ipaddresslan>>/index.php?purl=%u&razon=%t 
    } 
}
