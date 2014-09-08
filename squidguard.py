#!/usr/bin/python3
import re
configuracion = open("squidguard.conf","r")
conf = configuracion.read()
tiempo = re.findall("(time|dest|src)\s(.*)\{*((\n\s{1,8}\w+\s.+){1,4})\n\}", conf)
elemento = "tipo:{} nombre:{} definicion:{}".format

def dest(elem):
	conf = re.findall("(urllist|domainlist|expressionlist|log)\s+(.+)", elem[2])
	print(conf[0][0], conf[0][1])
	print(conf[1][0], conf[1][1])
	
for elem in tiempo:
	if elem[0] == "dest":
		dest(elem)
	elif elem[0] == "time":
		dest(elem)
	else:
		print (elemento(elem[0], elem[1], elem[2]))
#
#for linea in configuracion:
#	if bandera == True:
#		print("F:", linea)
#	elif re.match("^time", linea):
#		bandera = True
#		print("S:", linea)
#	elif re.match("^.{0,8}\}", linea):
#		bandera = False
#		print("FS:", linea)
#	else:
#		print(linea)
