---
layout: docs
site.author: Alexander Ortiz
author: Alexander Ortiz
title: Configuración sobre el sistema
orden: 3
header: no
---

<div class="panel radius" markdown="1">
**Tabla de contenido**
{: #toc }
*  TOC
{:toc}
</div>

# Configuración sobre el sistema

Tomando en cuenta que ahora tiene una red totalmente funcional, le será posible seguir con las siguientes instrucciones que incluyen la instalación de paquetes, actividad que hace uso de la red.

### sources.list. Instalación de paquetes
{% highlight bash %}
rm /etc/apt/sources.list

cat << MAFI > /etc/apt/sources.list 
{% include_relative sources.list.md %}
MAFI
{% endhighlight %}

Actualice el sistema:
{% highlight bash %}
apt update
apt upgrade 
{% endhighlight %}

Los siguientes paquetes son necesarios para las funciones críticas de su firewall.
{% highlight bash %}
apt install -y squid squidguard{,-doc} ipset apache2 libapache2-mod-php7.0 php7.0 vim
{% endhighlight %}

El siguiente paquete va para DHCP
{% highlight bash %}
apt install -y isc-dhcp-server
{% endhighlight %}

Instale los siguientes paquetes para obtener herramientas de monitoreo y administración
{% highlight bash %}
echo -e "wireshark-common\twireshark-common/install-setuid\tboolean\tfalse" | debconf-set-selections
apt -y install nmap tree pv sudo lshw iptraf tcpdump tmux tshark bwm-ng iptstate 
{% endhighlight %}

Los siguientes paquetes son necesarios para los scripts auxiliares, y como estos, son opcionales. Aunque también se verifican en el script de instalación de los mismos, es probable que quiera instalarlos de una vez. 
{% highlight bash %}
apt install -y libtext-diff-perl libconfig-simple-perl libemail-sender-perl libemail-sender-transport-smtps-perl libemail-sender-transport-smtps-perl libemail-mime-perl libio-all-perl
{% endhighlight %}

### Inicio de iptables
La configuración de iptables se realiza como si fuera un servicio en el sistema. 

Primero, creamos el script que se encarga de la ejecución de los ficheros en `/etc/fws/` donde configuramos los permisos para la red.

A continuación, creamos el fichero con la unidad `iptables` y activamos para que se ejecute al inicio del sistema:

{% highlight bash %}

tee /usr/local/bin/firewall.sh  < MAFI
{% include_relative firewall.md %}
MAFI


cat <MAFI >> /etc/systemd/system/iptables.service
{% include_relative iptables.service.md %}
MAFI

systemctl enable iptables.service
{% endhighlight %}

### Módulos para FTP Pasivo 
Configurar el reenvío de paquetes a través de interfaces, y activarla en caliente:
{% highlight bash %}
sed -i '$a ip_conntrack_ftp\nnf_nat_ftp ' /etc/modules
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
{% endhighlight %}

Si no va reiniciar el sistema antes de hacer pruebas, será necesario cargar los módulos anteriores en el sistema con los siguientes comandos:
{% highlight bash %}
modprobe nf_nat_ftp
modprobe ip_conntrack_ftp
{% endhighlight %}

### VIM  
Configuración opcional: Resaltado de sintaxis, identado a 4 espacios, patrón de colores para terminal obscuro y numerado de líneas.  
Por último, configure el comportamiento más clásico para mouse
{% highlight bash %}
sed -i '/syntax on/ a set tabstop=4\nset shiftwidth=4\nset expandtab' /etc/vim/vimrc
sed -i '/\"set background=dark/c\set background=dark' /etc/vim/vimrc
sed -i -r 's/(set\smouse=)\w/\1r/' /usr/share/vim/vim80/defaults.vim
sed -i '/^syntax /a set number' /etc/vim/vimrc
{% endhighlight %}

### Alternatives editor  
Configuración opcional: nano puede llegar a considerarse engorroso a la hora de modificar ciertos ficheros que así lo requieran
{% highlight bash %}
update-alternatives --set editor /usr/bin/vim.basic
{% endhighlight %}

### Autenticación contra el árbol LDAP 
En el servidor de dominio (10.10.20.49) existe un certificado digital llamado `CA-sv.crt`, desde un cliente cualquiera, y usando las credenciales del usuario soporte, es posible obtenerlo con el siguiente comando:

{% highlight bash %}
smbclient //10.10.20.49/soporte/ -U soporte -c 'get CA-sv.crt'
{% endhighlight %}

Luego puede enviarse al firewall de la siguiente forma:

{% highlight bash %}
scp CA-sv.crt fwadmin@<ip-firewall>:~/
{% endhighlight %}

Luego, en el firewall configuramos de la siguiente forma:
{% highlight bash %}
aptitude install sssd{,-tools} sudo
mv /home/fwadmin/CA-sv.crt /etc/ssl/certs/

cat <<MAFI>/etc/sssd/sssd.conf
[sssd]
config_file_version = 2
services = nss,pam
domains = salud.gob.sv

[nss]

[pam]  

[domain/salud.gob.sv]
ldap_uri = ldap://directorio.salud.gob.sv
ldap_search_base = dc=salud,dc=gob,dc=sv
ldap_schema = rfc2307
id_provider = ldap
ldap_user_uuid = entryuuid
ldap_group_uuid = entryuuid
ldap_id_use_start_tls = True
enumerate = False
cache_credentials = True
ldap_user_search_base = ou=Users,dc=salud,dc=gob,dc=sv
ldap_group_search_base = ou=Groups,dc=salud,dc=gob,dc=sv
chpass_provider = ldap
auth_provider = ldap
ldap_tls_cacertdir = /etc/ssl/certs
ldap_tls_cacert = /etc/ssl/certs/CA-sv.crt
MAFI

systemctl restart sssd.service

chmod 700 /etc/sssd/sssd.conf
systemctl restart sssd.service 

sed -E -i 's/^#\s*(account\s*required\s*pam_access.so)/\1/g' /etc/pam.d/sshd

grep -q '+ : root : 192.168.2.20/27' /etc/security/access.conf || sed '$a + : root : 192.168.2.20/27' /etc/security/access.conf  -i
grep -q '+ : MinsalAdminFirewall : ALL' /etc/security/access.conf || sed '$a + : MinsalAdminFirewall : ALL' /etc/security/access.conf  -i
grep -q -- '- : ALL: ALL' /etc/security/access.conf || sed '$a - : ALL: ALL' /etc/security/access.conf  -i

grep -q 'pam_mkhomedir.so' /etc/pam.d/common-session || sed -i '/"Additional" block/ a session\trequired\tpam_mkhomedir.so umask=0022 skel=/etc/skel' /etc/pam.d/common-session
grep -q 'pam_mkhomedir.so' /etc/pam.d/common-session-noninteractive || sed -i '/"Additional" block/ a session\trequired\tpam_mkhomedir.so umask=0022 skel=/etc/skel' /etc/pam.d/common-session-noninteractive

cat <<MAFI>/etc/sudoers.d/ruth 
%MinsalAdminFirewall ALL=(ALL) NOPASSWD:/bin/su
MAFI
{% endhighlight %}
