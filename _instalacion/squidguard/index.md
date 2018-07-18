---
layout: docs
site.author: Alexander Ortiz
author: Alexander Ortiz
title: Configuración de squidGuard
orden: 6
header: no
---

<div class="panel radius" markdown="1">
**Tabla de contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Configuración de squidGuard
Borre el contenido del archivo original de configuración de SquidGuard y copie el siguiente.
Si va a cambiar su contenido, tenga especial cuidado con los comentarios: No comente el contenido entre corchetes.

{% highlight nginx %}
source /etc/fws/infraestructura.sh
SRV=(${listados['SRV']})
cat << MAFI > /etc/squidguard/squidGuard.conf
{% include_relative squidguard.md %}

MAFI
{% endhighlight %}

# Personalizando la configuración
Obtener las listas negras a las que se hace referencia en el fichero anterior. No ubicamos en el directorio correspondiente, descargamos y descomprimimos
{% highlight bash %}
cd /var/lib/squidguard/db/
wget http://www.shallalist.de/Downloads/shallalist.tar.gz 
tar -xzvf shallalist.tar.gz
{% endhighlight %}

Ejecute lo siguientes comandos para crear ficheros donde guardar personalizaciones básicas.
{% highlight bash %}
mkdir /var/lib/squidguard/db/custom
touch /var/lib/squidguard/db/custom/{,ir}restrictos.lst
source /etc/fws/infraestructura.sh
SRV=(${listados['SRV']})
cat << MAFI > /var/lib/squidguard/db/custom/sitios.lst
$(echo $SRV[0] | cut -d '/' -f 1)
gob.sv
typepad.com
blogspot.com
wordpress.com
MAFI
cat << MAFI > /var/lib/squidguard/db/custom/extensiones.lst
.\.(com|exe|pif|scr|vbe|vbs|wsf|bat|inf|reg|lnk|url|iso|chm|hlp|avi|wma|wmf|mp3|drv|ovr|dll|torrent)$
MAFI
{% endhighlight %}

**Para una explicacion exhaustiva de los ficheros anteriormente creados, puede remitirse a [Extendiendo el proxy de su servidor Firewall]({{site.baseurl}}/manual/proxy)**

Normalice permisos a todos los archivos que ha creado:
{% highlight bash %}
chown -R proxy:proxy BL custom
{% endhighlight %}

# Despliegue de configuración
Reinicie squid, quién se encarga de iniciar/apagar a squidGuard.
{% highlight bash %}
systemctl restart squid.service 
{% endhighlight %}

Ahora debe revisar los log de squidGuard, (`tail -f /var/log/squidguard/squidGuard.log`).
Es posible que vea la siguiente línea por un tiempo considerable. Que indica que por el considerables tamaño de esa lista, le es más difícil a squidGuard crear la base de datos correpondiente
{% highlight bash %}
2015-03-07 12:46:40 [7651] init domainlist /var/lib/squidguard/db/BL/porn/domains 
{% endhighlight %}

La siguiente linea marca el momento en que el proxy es capaz de recibir peticiones. No acepte nada menos que esto, otro mensaje indica algún error que debe ser revisado.
{% highlight bash %}
2013-06-04 09:12:15 [3348] INFO: squidGuard ready for requests (1370358735.429)
{% endhighlight %}

Pese a lo anteriormente dicho, podría aceptar también esta línea (Muchas, de hecho) si ha tardado mucho en revisar los log.
{% highlight bash %}
2015-03-26 12:29:31 [14125] INFO: recalculating alarm in 30 seconds
{% endhighlight %}

# Prueba de configuración
La prueba más convincente de la configuración de filtro de contenido es ver a usuarios reales navegando realmente.  
En ese caso, necesita avanzar en Otras configuraciones importantes hasta Configuración de Mensajes de Error

Sin embargo, es posible verificar desde consola que las reglas en squidGuard funcionen tal como se espera. Ejecute desde consola el siguiente comando, cambiando `10.20.20.5` por una ip válida en su red, sin importar si algún equipo la tiene configurada:
{% highlight bash %}
echo "hola.org/- 10.20.20.5 - GET -" | squidGuard -c /etc/squidguard/squidGuard.conf -d
{% endhighlight %}

Las últimas lineas debe tener esta forma:
{% highlight bash %}
2017-07-13 08:31:59 [22635] INFO: squidGuard 1.5 started (1499956309.073)
2017-07-13 08:31:59 [22635] INFO: squidGuard ready for requests (1499956319.099)
2017-07-13 08:31:59 [22635] Request(usuarios_laboral/web-proxy/-) hola.org/- 10.168.4.5/- - GET REDIRECT
OK rewrite-url="http://10.168.4.1/index.php?purl=hola.org/-&razon=web-proxy"
2017-07-13 08:31:59 [22635] INFO: squidGuard stopped (1499956319.099)
{% endhighlight %}

Por otro lado, el fingir navegar hacia www.google.com.sv:
{% highlight bash %}
echo "www.google.com.sv/- 10.20.20.5 - GET -" | squidGuard -c /etc/squidguard/squidGuard.conf -d
{% endhighlight %}

Debería devolver un mensaje como el siguiente. Acá, `ERR` significa error en el sentido que la URL esta permitida y no necesita una redirección como la que se arroja en el anterior ejemplo
{% highlight bash %}
2017-07-13 08:33:58 [22639] INFO: squidGuard 1.5 started (1499956428.578)
2017-07-13 08:33:58 [22639] INFO: squidGuard ready for requests (1499956438.697)
ERR
2017-07-13 08:33:58 [22639] INFO: squidGuard stopped (1499956438.698)
{% endhighlight %}

# Configuración avanzada

## Configuración de Usuarios y Grupos mediante LDAP
El siguiente archivo lee los grupos de un servidor LDAP. Obviamente, usted puede configurar más grupos.  
Tome en cuenta que en el ejemplo existe dos grupos LDAP: `Domains Admins` y `http_noacces` y dos ACL de tiempo: `laboral` y `almuerzo`, estás dos últimas podría obviarlas o establecer un horario nocturno si es que necesita que sea diferente a laboral.  
Entonces, hay creadas dos `src` por cada grupo para que coincida con las ACL de tiempo, lo que nos da cuatro `src`, luego, tal como he hecho antes, debe configurar los permisos por cada `src en 
{% highlight squid %}
    {% include_relative squidguard_auth.md %}
{% endhighlight %}

## Personalizando la configuración  
La siguiente configuración es un poco más complicada de lo usual en la medida que sea más complicado para usted usar su propio servidor LDAP. Sin embargo, los siguientes datos pueden funcionar para un servidor configurado según el esquema [rfc230bis](http://www.padl.com/~lukeh/rfc2307bis.txt).

* Configure `ldapbinddn` con el DN de un usuario de lectura sin límites en las lecturas sobre el árbol LDAP. Es decir, los mismo permisos que su administrador pero de LECTURA.
* Configure `ldapbindpass` con la contraseña de dicho usuario, que como nos gusta resaltar, será mejor si sus permisos son de sólo lectura.
* Los siguientes comandos configuran el resto del archivo. Esperando que usted conozca bien los datos del servidor al cual se ha de conectar
  * Cambie **10.40.30.5** por la dirección IP del servidor LDAP
{% highlight bash %}
    sed -i 's/<<serverldap>>/10.40.30.5/g' /etc/squidguard/squidGuard.conf
{% endhighlight %}
  * Cambie **ou=Groups,dc=empresa,dc=com** por la base de los grupos LDAP
{% highlight bash %}
    sed -i 's/<<basegrupos>>/ou=Groups,dc=empresa,dc=com/g' /etc/squidguard/squidGuard.conf
{% endhighlight %}
