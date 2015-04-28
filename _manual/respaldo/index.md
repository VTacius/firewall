---
layout: docs
site.author : Alexander Ortiz
author : Alexander Ortiz
title: Recuperación de Respaldo
orden: 5
header: no
---
<div class="panel radius" markdown="1">
**Tabla de Contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Recuperación de Respaldo

Hay varias razones por las que debería tener que recuperar _**la última configuración buena conocida**_ de su Firewall:

* Algo realmente malo ha pasado con el servidor
* Quiere migrarlo a otro equipo con el menor tiempo fuera posible.

Los pasos para dicha recuperación no podían ser más sencillos

* Se le enviará al correo un fichero con un nombre tal como `backup-26-03-2015—14.22.23.tgz`
* Desarrolle su guía de configuración de Firewall al menos hasta Configuración Primaria de Red, después de ello, 
* Envíe ese fichero al servidor mediante scp 
* Ejecute el siguiente comando en su servidor Firewall y la extracción de los archivos se harán en la ubicación adecuada.

{% highlight bash %}
tar -xzvPf  backup-26-03-2015—14.22.23.tgz
{% endhighlight %}
