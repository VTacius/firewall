use strict;
use warnings;

use Archive::Tar;
use File::Find;

my @ficheros = (
    qw(    
        /etc/apache2/sites-available/000-default.conf
        /etc/network/interfaces 
        /etc/host.conf 
        /etc/resolv.conf
        /etc/hosts
        /etc/sarg/sarg.conf 
		/etc/sarg/sarg-reports.conf
        /etc/squid/squid.conf 
        /etc/squidguard/squidGuard.conf 
        /root/fws/tools/cleantmp.sh
        /root/fws/tools/reinicio.sh
        /root/fws/grupos_ipset.sh
        /root/fws/firewall.sh
        /root/fws/dmz.sh
        /root/fws/rutas.sh
        /root/fws/establecimiento.sh
        /root/fws/infraestructura.sh
        /root/fws/reportes.sh
        /var/www/html/
        /var/www/html/script
        /var/www/html/script/default.css
        /var/www/html/index.php
        /var/www/html/favicon.ico
        /var/www/html/categorias.php
        /var/www/html/destino.php
    )
);

sub backup {

	my $fichero_resultante = shift;
	my $usa_dhcp = shift;

	my $tar = Archive::Tar->new;
	
	while (my $fichero = shift(@ficheros)){
	    $tar->add_files($fichero) 
	        or die "No puedo agregar $fichero: $!";
	}
	
	# Las reglas de squidGuard tienen la particularidad de crearse arbitrariamente
	my $directorio = "/var/lib/squidguard/db/custom";
	
	find(\&busqueda, $directorio);
	
	sub busqueda {
	    \$tar->add_files($File::Find::name) 
	        or die "No puedo agregar $File::Find::name $!";
	}

	# La configuración de DHCP, sólo cuando sea necesaria
	if ($usa_dhcp){
	    $tar->add_files('/etc/dhcp/dhcpd.conf') 
	        or die "No puedo agregar $File::Find::name $!";
		
	    $tar->add_files('/etc/default/isc-dhcp-server') 
	        or die "No puedo agregar $File::Find::name $!";
	}
	
	$tar->write($fichero_resultante, COMPRESS_GZIP)
		or die "No puedo agregar $File::Find::name $!";

}

1;
