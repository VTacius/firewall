#!/usr/bin/python3
import argparse
import re

parser = argparse.ArgumentParser(prog='squidguarConf', description="Asistente por consola para configuración de squidGuard")
subparsers = parser.add_subparsers(help='sub-command help')
# Parser para comando list
listado = subparsers.add_parser('list', help='list help')
listado.add_argument('list', choices=("all", "time", "dest", "acl"), help='list help')
listado.set_defaults(comando = "listado")

# Parser para comando add
anadir = subparsers.add_parser('add', help='add help')
anadir.add_argument('add', choices=("all", "time", "dest", "acl"), help='add help')
anadir.set_defaults(comando = "anadir")


configuracion = open("squidguard.conf","r")
conf = configuracion.read()
tiempo = re.findall("(time|dest|src)\s(.*)\{*((\n\s{1,8}\w+\s.+){1,4})\n\}", conf)
elemento = "tipo:{} nombre:{} definicion:{}".format

# Estos acá harán la magia para manejar fichero

def dest(elem):
	conf = re.findall("(urllist|domainlist|expressionlist|log)\s+(.+)", elem[2])
	print(conf[0][0], conf[0][1])
	print(conf[1][0], conf[1][1])

def time(elem):
	conf = re.findall("(time)\s+(.+)", elem)
	print(conf)

if __name__ == "__main__":
	args = parser.parse_args()
	if args.comando == "listado":
		if args.list == "time":
			time(conf)
		elif args.list == "anadir":
			print("Esto es otro")

	elif args.comando == "add":
		dest(conf)
