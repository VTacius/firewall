#!/usr/bin/python
import argparse
import re

# Obtenemos la información desde opciones en consola
parser = argparse.ArgumentParser(prog='interfaz', description='Asistente para configuración de Interfaz en Debian')
wan = parser.add_argument_group('wan', 'Configuración Interfaz WAN')
wan.add_argument('--iwan', help='Interfaz WAN', nargs="+", required=True)

lan = parser.add_argument_group('lan', 'Configuración Interfaz LAN')
lan.add_argument('--ilan', help='Interfaz LAN', nargs="+", required=True)

mh = parser.add_argument_group('mh', 'Configuración Interfaz hacia Ministerio de Hacienda')
mh.add_argument('--imh', help='Interfaz MH', nargs="+")

args = parser.parse_args()

# Creamos la máscara de red a partir del prefijo que el usuario pasa por consola
cidr = re.search('((\d{1,3}\.*){4})\/(.{1,2})', args.iwan[1])
ip_address = cidr.group(1)
sufijo_red = cidr.group(3)

bits = int(sufijo_red) % 8
bites = [ 2 ** (7-x) for x in range(bits) ]
octeto = 0
for bit in bites:
  octeto += bit

bites = ["255"] * (int(sufijo_red) // 8)
bites.append(str(octeto))
while len(bites) !=4:
	bites.append("0")

mascara = ".".join(bites)

red = re.search('(([0-9]{1,3}\.*){3})', args.iwan[1]);
print(red.group(1))

interfaz = """
auto {0} 
iface {0} inet static 
        address {1}
        netmask {2}
        network 192.168.106.0
        broadcast 192.168.106.255
""".format

print(interfaz(args.iwan[0], ip_address, mascara))
