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
