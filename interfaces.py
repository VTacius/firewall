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
#cidr = re.search('((\d{1,3}\.*){4})\/(.{1,2})', args.iwan[1])
cidr = re.search("((\d{1,3})\.*(\d{1,3})\.*(\d{1,3})\.*(\.*\d{1,3}))\/(\d{1,2})", args.iwan[1]);
ip_address = cidr.group(1)
sufijo_red = cidr.group(6)

bits = int(sufijo_red) % 8
bites = [ 2 ** (7-x) for x in range(bits) ]
octeto = 0
for bit in bites:
  octeto += bit

pos = (int(sufijo_red) // 8)
print(bits, bites, octeto, pos)

# Cual es la red segun la mascara de red
byte_mask = bin(octeto)[2:]
subred = bin(int(cidr.group(pos+2)))[2:]
print(byte_mask, subred)

while len(subred) !=  8:
	subred = "0" + subred

red = 0
for i in range(len(byte_mask)):
	red += 2 ** (7 - i) * (int(byte_mask[i]) & int(subred[i]) )
print(byte_mask, subred, red)

network = []
for i in range(2, pos+2):
	network.append(cidr.group(i))

network.append(str(red))

while len(network)!=4:
	network.append("0")

network = ".".join(network)

# Fabricamos la mascara de red
bites = ["255"] * pos 
bites.append(str(octeto))
while len(bites) !=4:
	bites.append("0")

mascara = ".".join(bites)


interfaz = """
auto {0} 
iface {0} inet static 
        address {1}
        netmask {2}
        network {3} 
        broadcast 192.168.106.255
""".format

print(interfaz(args.iwan[0], ip_address, mascara, network))
