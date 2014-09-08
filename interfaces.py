#!/usr/bin/python
import argparse
import re

class ipeador:
	def __init__(self, interface, address):
		self.interface = interface
		# Creamos la máscara de red a partir del prefijo que el usuario pasa por consola
		self.cidr = re.search("((\d{1,3})\.*(\d{1,3})\.*(\d{1,3})\.*(\.*\d{1,3}))\/(\d{1,2})", address);
		self.ip_address = self.cidr.group(1)
		
		self.sufijo_red = self.cidr.group(6)
	
		bits = int(self.sufijo_red) % 8
		self.octeto = 0
		for bit in [ 2 ** (7-x) for x in range(bits) ]:
		  self.octeto += bit
		
		self.pos = int(self.sufijo_red) // 8
		
	def network(self):		
		# Cual es la red segun la mascara de red
		byte_mask = bin(self.octeto)[2:]
		subred = bin(int(self.cidr.group(self.pos+2)))[2:]
		# Cual es la red segun la mascara de red
		byte_mask = bin(self.octeto)[2:]
		subred = bin(int(self.cidr.group(self.pos+2)))[2:]
		
		while len(subred) !=  8:
			subred = "0" + subred
		
		red = 0
		for i in range(len(byte_mask)):
			red += 2 ** (7 - i) * (int(byte_mask[i]) & int(subred[i]) )

		# Cual es la red segun la mascara de red
		byte_mask = bin(self.octeto)[2:]
		subred = bin(int(self.cidr.group(self.pos+2)))[2:]
		
		while len(subred) !=  8:
			subred = "0" + subred
		
		red = 0
		for i in range(len(byte_mask)):
			red += 2 ** (7 - i) * (int(byte_mask[i]) & int(subred[i]) )

		# Cual es la red segun la mascara de red
		byte_mask = bin(self.octeto)[2:]
		subred = bin(int(self.cidr.group(self.pos+2)))[2:]
		
		while len(subred) !=  8:
			subred = "0" + subred
		
		red = 0
		for i in range(len(byte_mask)):
			red += 2 ** (7 - i) * (int(byte_mask[i]) & int(subred[i]) )

		# Cual es la red segun la mascara de red
		byte_mask = bin(self.octeto)[2:]
		subred = bin(int(self.cidr.group(self.pos+2)))[2:]
		
		while len(subred) !=  8:
			subred = "0" + subred
		
		red = 0
		for i in range(len(byte_mask)):
			red += 2 ** (7 - i) * (int(byte_mask[i]) & int(subred[i]) )

		# Cual es la red segun la mascara de red
		byte_mask = bin(self.octeto)[2:]
		subred = bin(int(self.cidr.group(self.pos+2)))[2:]
		
		while len(subred) !=  8:
			subred = "0" + subred
		
		red = 0
		for i in range(len(byte_mask)):
			red += 2 ** (7 - i) * (int(byte_mask[i]) & int(subred[i]) )

		# Cual es la red segun la mascara de red
		byte_mask = bin(self.octeto)[2:]
		subred = bin(int(self.cidr.group(self.pos+2)))[2:]
		
		while len(subred) !=  8:
			subred = "0" + subred
		
		red = 0
		for i in range(len(byte_mask)):
			red += 2 ** (7 - i) * (int(byte_mask[i]) & int(subred[i]) )

		# Cual es la red segun la mascara de red
		byte_mask = bin(self.octeto)[2:]
		subred = bin(int(self.cidr.group(self.pos+2)))[2:]
		
		while len(subred) !=  8:
			subred = "0" + subred
		
		red = 0
		for i in range(len(byte_mask)):
			red += 2 ** (7 - i) * (int(byte_mask[i]) & int(subred[i]) )

		
		while len(subred) !=  8:
			subred = "0" + subred
		
		red = 0
		for i in range(len(byte_mask)):
			red += 2 ** (7 - i) * (int(byte_mask[i]) & int(subred[i]) )

		network = []
		for i in range(2, self.pos+2):
			network.append(self.cidr.group(i))
		
		network.append(str(red))
		
		while len(network)!=4:
			network.append("0")
		
		network = ".".join(network)
		return network

	def mascara(self):
		# Fabricamos la mascara de red
		bites = ["255"] * self.pos 
		bites.append(str(self.octeto))
		while len(bites) !=4:
			bites.append("0")
		
		mascara = ".".join(bites)
		return mascara
		
	def configuracion(self):
		interfaz = """
		auto {0} 
		iface {0} inet static 
		        address {1}
		        netmask {2}
		        network {3} 
		        broadcast 192.168.106.255
		""".format
		
		return interfaz(self.interface, self.ip_address, self.mascara(), self.network())

if __name__ == "__main__":
	# Obtenemos la información desde opciones en consola
	parser = argparse.ArgumentParser(prog='interfaz', description='Asistente para configuración de Interfaz en Debian')
	wan = parser.add_argument_group('wan', 'Configuración Interfaz WAN')
	wan.add_argument('--iwan', help='Interfaz WAN', nargs="+", required=True)
	
	lan = parser.add_argument_group('lan', 'Configuración Interfaz LAN')
	lan.add_argument('--ilan', help='Interfaz LAN', nargs="+", required=True)
	
	mh = parser.add_argument_group('mh', 'Configuración Interfaz hacia Ministerio de Hacienda')
	mh.add_argument('--imh', help='Interfaz MH', nargs="+")
	
	args = parser.parse_args()

configuracion = ipeador(args.iwan[0], args.iwan[1])
print(configuracion.configuracion())
