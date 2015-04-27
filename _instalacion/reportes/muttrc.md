cat << MAFI > /root/.muttrc
# Datos de la cuenta
set from = "firewall@salud.gob.sv" 
set realname = "Firewall" 
# Credenciales para el servidor SmartHost 
set smtp_authenticators = "LOGIN" 
set smtp_url = "smtps://firewall@salud.gob.sv@mail.salud.gob.sv:465/" 
# Si su contraseña tiene caracteres especiales, escape con barra invertida 
set smtp_pass = "Fir_0577" 
# No guardamos los archivos enviados
set copy=no
MAFI
