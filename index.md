---
layout: base
title: Inicio
---

#Firewall para servicio de Internet a pequeñas organizaciones
El objetivo exponer algunas reglas o directrices a tomar en cuanta para configurar un servidor que funcione como Firewall, Proxy Caché y Gestor de contenidos, cuyo objetivo será el supervisar el acceso de una pequeña organización a Internet, o de pequeñas sucursales/dependencias a los recursos de toda una organización.  
El esquema más básico puede resumirse de la siguiente manera:

![Diagrama de Red de lo que se quiere configurar]({{site.baseurl}}/images/Diagrama_de_Red.png)

Por un lado el presente trabajo no es más que una guía de configuración tal como la usamos en la organización donde laboro. Y por el otro lado, no he pretendido que esta sea "La Guía Definitiva". 

Considero que realizar esta guía puede ser bastante didáctica en cuanto hay bastantes preguntas que ella aún no responde, pero bastantes los problemas que ya ha solucionado

Quizá quiera considerar el uso de un appliance en lugar de un equipo configurado con esta guía para poner en producción. Nosotros tenemos ya algunos firewall, resultados finales de esta guía funcionando, y hasta el momento no creemos que un appliance pueda ofrecernos tal nivel de manejabilidad y sencillez para las funciones que el firewall desempeña

