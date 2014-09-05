import sys
import re

cidr = sys.argv[1]

direccion = re.search("((\d{1,3})\.*(\d{1,3})\.*(\d{1,3})\.*(\.*\d{1,3}))\/(\d{1,2})",cidr);
ip_addr = direccion.group(1)
sufijo = direccion.group(6)
bite = (int(sufijo) // 8 ) + 2
bites = int(sufijo) % 8 
mask = "1"*bites
byte = bin(int(direccion.group(bite)))[2:]

l = 0
caso = True if (len(mask)>0) else False
octal = []
while caso:
    print("byte sobre el que se va a evaluar: ", mask[l], byte[l])
    if (mask[l]==byte[l]):
        l += 1
        octal.append(byte[l])
        caso = True if (len(mask)>1) else False
    else:
        print ("Esto hace la diferencia", mask[l], byte[l], int(mask[1]) & int(byte[l]))
        caso = False

# Probar con 192.168.2.193/27
print(octal)
