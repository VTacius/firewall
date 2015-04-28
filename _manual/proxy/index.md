---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title: Extendiendo el proxy de su servidor Firewall
orden: 3
header: no
---
<div class="panel radius" markdown="1">
**Tabla de Contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Extendiendo el proxy de su servidor Firewall
Existen algunos ficheros que podrían ser útiles para algunas configuraciones que, aunque bastante básicas, pueden ser útiles en la primera etapa de personalización:

A continuación, se explica la función de todos estos ficheros antes creados.

`/var/lib/squidguard/db/custom/restrictos.lst:`
 : Direcciones IP de usuarios a los que todo tráfico HTTP/HTTPS les será negado por defecto

`/var/lib/squidguard/db/custom/irrestrictos.lst:`
 : Direcciones IP de usuarios que, si bien siguen pasando sus peticiones HTTP/HTTPS a tráves de squid/squidGuard, no reciben ninguna restricción por parte del filtro de contenido.

`/var/lib/squidguard/db/custom/extensiones.lst:`
 : Extensiones de archivos cuya descarga se va a prohibir. Entre otro par de barras, incluya otras extensiones que necesite:

`/var/lib/squidguard/db/custom/sitios.lst`
 : Sitios cuyo en cuyo contenido se confía, y que por tanto no se necesite mayor bloquear su contenido. El mejor ejemplo es la descarga de actualizaciones de su antivirus.


