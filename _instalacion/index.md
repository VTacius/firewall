---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title: Directivas para instalación del sistema base
orden: 0
header: no
---

# Directivas para instalación del sistema base

El proyecto es altamente configurable. Sin embargo, podrá sentirse más comódo si se limita a cambiar aquellos parámetros de los que se le pida explícitamente que lo haga. Con esto, procuramos estandarizar el proyecto, facilitando así la asistencia con posibles problemas.

* Haga configuración manual la red. Al menos hasta configurar una interfaz (Podría ser la interfaz que será asignada a LAN) que le permite comunicarse con el firewall.
* El usuario sin derechos administrativos será mafi. Es necesario para conectarse al equipo por medio de SSH, siguiendo los actuales lineamientos de Debian.  
* A menos que sea experto particionando, o que lo haya hecho antes con ese equipo en particular, se recomienda el siguiente proceso para tal operacion:
  * En **Particionado de discos** escoja la opción **Guiado – utilizar todo el disco**.
  * Después de **Elija disco a particionar**, escoja en **Esquema de particionado** la opción **Todos los ficheros en una partición (recomendado para novatos)**.    
  * Luego, borre la partición raíz y proceda al esquema sugerido a continuación.
* **XFS** como sistema de archivos es nuestra recomendación.
* La capacidad del disco a particionar debe ser mayor a 50 GB.   
* El esquema de particionado sugerido es el siguiente:

|---
| Particion | Instrucción
|:-|:-|
| Arranque EFI  | A configurarse en equipos modernos con EFI, donde el asistente antes descrito lo haya sugerido<br>Debe ser la primera particion en el sistema, usualmente con espacio libre designado por el sistema antes de ella<br>Su tipo es **Partición de arranque <<EFI>>**<br>Verifique no que tenga más de 512 MB fijos| 
| /             | Al igual que con las demás particiones, recomendamos usar **xfs**
| /home         | Configure el **40%** del espacio disponible|
| /tmp          | Configure el **5%** del espacio disponible|
| /var          | Configure el **40%** del espacio disponible|
| intercambio   | Siempre el doble de la memoria RAM disponible. Siempre |
|===

* Instale Debian en su mínima expresión: Seleccione **SSH Server** y **Utilidades estándar del sistema**
![Selección de paquetes mínima en Debian]({{site.urlimg}}/Debian_seleccion_paquetes_minimo.png)

* Habiendo instalado el **SSH Server**, debería ser capaz de realizar la configuración de la guía en remoto, lo que facilitará enormemente su trabajo.
