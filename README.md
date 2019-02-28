# Firewall
Configuración de Iptables + Squid3 + SquidGuard como Firewall/Proxy para pequeñas organizaciones

## Introducción
El presente es una recopilación de un poco más de seis meses de investigación y pruebas sobre la configuración de un Firewall en Linux desde cero.
Considerése una guía que es posible usar con su distribución favorita

## ¿Que incluye?
El núcleo del proyecto es información sobre los siguientes aspectos de un Firewall:
* Configuración de IPtables
* Configuración de Squid
* Configuración de SquidGuard
Todo ello esta organizado en [firewall](http://vtacius.github.io/firewall/)

Además, planteamos un par de herramientas para automatizar la configuración sobre Debian, distribución que sirvió de base para este trabajo

## Dockerfile
Consciente de que la instalación de Jekyll es una de las cosas más engorrosas en esta vida y en la otra, hice un `Dockerfile` que simplifica la vida. 
Si quiere instalarlo en una forma más tradicional, no hay problema: Sólo asegúrese de usar la guía de [Github Pages](https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/)

Así, basta con ejecutar desde la rama `gh-pages`:

```sh
rm Gemfile.lock
docker build . -t jekewall
docker run -it --rm -v $(pwd):/var/www -P jekewall
```

Si lo corre en un equipo que usa Selinux, es necesario agregar una Z al montaje del volumen:
```
docker run -it --rm -v $(pwd):/var/www:Z -P jekewall
```

En consola debe aparecer la URL a la que debe acceder.

El container hace todo un usuario de nombre `usuario` cuyo id es el 1000 por defecto, lo que puede servir para la mayoría de personas. Si el usuario que usa es diferente, puede pasar un `--build-arg ID=1001` para especificar otro id para el usuario, con lo que no tendrá que preocuparse después de los permisos en el proyecto.
