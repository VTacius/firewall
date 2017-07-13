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
        redirect http://$(echo ${SRV[0]} | cut -d '/' -f 1)/index.php?purl=%u&razon=%t
    }else{
        redirect http://$(echo ${SRV[0]} | cut -d '/' -f 1)/index.php?purl=%u&razon=%t }
