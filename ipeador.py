import sys
import re

cidr = sys.argv[1]

direccion = re.search("((\d{1,3})\.*(\d{1,3})\.*(\d{1,3})\.*(\.*\d{1,3}))\/(\d{1,2})", cidr);
ip_addr = direccion.group(1)
sufijo = direccion.group(6)
bite = (int(sufijo) // 8 ) + 2
bites = int(sufijo) % 8 
mask = "1" * bites
netmask = ['255'] * (bite-2)

print(netmask)
byte = bin(int(direccion.group(bite)))[2:]
while len(byte) !=8:
	byte = "0" + byte

# Separamos el binario en un array para manipularlo
byte = [x for x in byte]

# Inicializamos el valor de la mascara de red
red = 0
print(byte)

# Configuramos el byte según la mascara especificada
for i in range(len(mask)):
	red +=  2 ** (7 - i) * ( int(mask[i]) & int(byte[i]) )
	byte[i] = "0"

# Agregamos el byte que hemos trabajado
netmask.append(red)

# Completamos hasta los 4 octetos de la mascara de red
while len(netmask) !=4:
	netmask.append('0')

print(netmask)
print(red)

# Probar con 192.168.2.193/27
print(mask)
print(byte)
