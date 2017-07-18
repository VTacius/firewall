use strict;
use warnings;

use Archive::Tar;
use File::Find;

my @ficheros = (
    qw(    
        /root/fws/infraestructura.sh
        /etc/network/interfaces 
        /etc/hosts
        /etc/resolv.conf
        /etc/host.conf 
        /root/fws/grupos_ipset.sh
        /root/fws/firewall.sh
        /root/fws/rutas.sh
        /root/fws/dmz.sh
        /root/fws/establecimiento.sh
        /etc/squid/squid.conf 
        /etc/squidguard/squidGuard.conf 
        /var/www/html/script
        /var/www/html/script/default.css
        /var/www/html/index.php
        /var/www/html/favicon.ico
        /var/www/html/categorias.php
        /etc/apache2/conf-available/security.conf
        /etc/php/7.0/apache2/php.ini
        /etc/rsyslog.d/iptables.conf
        /etc/sarg/sarg.conf 
        /etc/sarg/sarg-reports.conf
        /etc/apache2/sites-available/000-default.conf
        /etc/default/sysstat
        /etc/cron.d/sysstat
        /root/.configuracion_reporte.ini
        /etc/systemd/timesyncd.conf
    )
);

my $tar = Archive::Tar->new;

sub busqueda {
    \$tar->add_files($File::Find::name) 
        or die "No puedo agregar $File::Find::name $!";
}

sub backup {

    my $fichero_resultante = shift;

    
    while (my $fichero = shift(@ficheros)){
        $tar->add_files($fichero) 
            or die "No puedo agregar $fichero: $!";
    }
    
    # Las reglas de squidGuard tienen la particularidad de crearse arbitrariamente
    my $directorio = "/var/lib/squidguard/db/custom";
    
    find(\&busqueda, $directorio);
    
    # Este es un par de script que se han considerado opcionales, por lo que podrían estar o no
    if (-f '/root/fws/tools/cleantmp.sh'){
        $tar->add_files('/root/fws/tools/cleantmp.sh');
    }

    if (-f '/root/fws/tools/reinicio.sh'){
        $tar->add_files('/root/fws/tools/reinicio.sh');
    }
    
    # La configuración de DHCP, sólo cuando sea necesaria
    if (-f '/etc/dhcp/dhcpd.conf'){
        $tar->add_files('/etc/dhcp/dhcpd.conf') 
            or die "No puedo agregar $File::Find::name $!";
        
        $tar->add_files('/etc/default/isc-dhcp-server') 
            or die "No puedo agregar $File::Find::name $!";
    }
    
    $tar->write($fichero_resultante, COMPRESS_GZIP)
        or die "No puedo agregar $File::Find::name $!";

}

1;
