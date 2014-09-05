import sys
import re

cidr = sys.argv[1]

direccion = re.search("((\d{1,3})\.*(\d{1,3})\.*(\d{1,3})\.*(\.*\d{1,3}))\/(\d{1,2})", cidr);
ip_addr = direccion.group(1)
sufijo = direccion.group(6)
bite = (int(sufijo) // 8 ) + 2
bites = int(sufijo) % 8 
mask = "1" * bites
byte = bin(int(direccion.group(bite)))[2:]
while len(byte) !=8:
	byte = "0" + byte

l = 0
caso = True if (len(mask)>0) else False
octal = []
while caso:
    if (mask[l]==byte[l]):
        l += 1
        octal.append(byte[l])
        caso = True if (len(mask)>1) else False
    else:
        caso = False

# Probar con 192.168.2.193/27
print(mask)
print(byte)
print(octal)
