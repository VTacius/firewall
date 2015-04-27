---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title: Directivas para instalación del sistema base
orden: 0
header: no
---

# Directivas para instalación del sistema base

El proyecto es altamente configurable. Sin embargo, podrá sentirse más comódo si se limita a cambiar aquellos parámetros de los que se le pida explícitamente que los haga. El objetivo de esto es estandarizar el proyecto, facilitando así la asistencia con posibles problemas.

* El usuario sin derechos administrativos será mafi.  
* Se recomienda que en **Particionado de discos** escoja la opción **Guiado – utilizar todo el disco**.  
  * Después de **Elija disco a particionar**, escoja en **Esquema de particionado** la opción **Todos los ficheros en una partición (recomendado para novatos)**.  
  * De esta forma, el instalador se ocupara de moldear algunas particiones.  
  * Luego, borre la partición raíz y proceda al esquema sugerido
* La recomendación es usar **XFS** como sistema de archivos
* Al calcular el tamaño en base al porcentaje dado, siempre redondee hacia el entero superior. Siempre
* El esquema de particionado sugerido es el siguiente:  
  * La capacidad del disco a particionar debe ser mayor a 50 GB.   
  * Dicho disco será particionado en la siguiente forma  

|---
| Particion | Instrucción
|:-|:-|
| Arranque EFI  | A configurarse en equipos modernos con EFI<br>Debe ser la primera particion en el sistema, usualmente con espacio libre designado por el sistema antes de ella<br>Su tipo es **Partición de arranque <<EFI>>**<br>Verifique no que tenga más de 512 MB fijos| 
| /             | Al igual que con las demás particiones, recomendamos usar **xfs**
| /home         | Configure el **40%** del espacio disponible|
| /tmp          | Configure el **5%** del espacio disponible|
| /var          | Configure el **40%** del espacio disponible|
| intercambio   | Siempre el doble de la memoria RAM disponible. Siempre |
|===

* Instale Debian Wheezy en su mínima expresión
![Selección de paquetes mínima en Debian]({{site.urlimg}}/Debian_seleccion_paquetes_minimo.png)

* Después de **Configuración primaria de Red**, use SSH para configurar su Firewall según esta guía. Así podrá copiar y pegar el contenido de los ficheros, lo cual reducirá considerablemente el riesgo de error frente a tener que escribir todo.
