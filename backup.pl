#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use POSIX;
use Minsal::Informacion;
use Minsal::Mercurio; 
use Minsal::Backup; 

my $RUTA_BACKUP = "/var/backups"; 
my @ficheros = qw(    
    /etc/fws/infraestructura.sh
    /etc/network/interfaces 
    /etc/hosts
    /etc/resolv.conf
    /etc/host.conf 
    /etc/fws/grupos_ipset.sh
    /etc/fws/firewall.sh
    /etc/fws/rutas.sh
    /etc/fws/dmz.sh
    /etc/fws/establecimiento.sh
    /etc/squid/squid.conf 
    /etc/squidguard/squidGuard.conf 
    /etc/dhcp/dhcpd.conf
    /etc/default/isc-dhcp-server
    /var/www/html/script
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
    /var/lib/squidguard/db/custom
);

# Obtenemos algunas marcas de tiempo para crear nombres más adelante
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year += 1900;
my $dia = "$mday/$mon/$year";
my $timestamp = "$year$mon$mday-$hour$min$sec";

# Información del equipo obtenida directamente del sistema
my $hostname = hostname();
my ($chasis, $modelo, $marca) = informacion_equipo();

# Información obtenida desde /etc/fws/infraestructura.sh
my %configuracion_legacy = obtener_configuracion_legacy();
my $institucion = $configuracion_legacy{'INSTITUCION'};
my $fondo_compra = $configuracion_legacy{'FONDO_COMPRA'};
my $ip_interfaz_wan = $configuracion_legacy{'SRW'};

my $fichero_backup = "$RUTA_BACKUP/backup-$hostname-$timestamp.tgz";
backup($fichero_backup, @ficheros);

my $asunto = "Firewall $institucion: Reporte y Backup en $dia";

my $mensaje = <<"MAFI";
<html>
    <head>
        <style>
			body {
			  line-height: 1.625em;
			  font-family: "Open Sans", "arial, helvetica, sans-serif"; 
			  box-sizing: border-box;
			  color: #444;
			}
			p {
			  margin: 0 0 0.625em;
			  font-size: 1em;
			  font-weight: normal;
			}
			ul {
			  list-style: none;
			  padding-left: 0;
			}
			        
			li {
			  display: inline;
			} 
			        
			li b {
			  width: 8.7em;
			  display: inline-block;
			  text-align: right;
			}
        </style>
    </head>
	<body>
	        <h2>Backup para $hostname</h2>
	        <p>Firewall de $institucion accesible en <tt>$ip_interfaz_wan</tt></p> 
	        <p>Instalado en <b>$modelo</b> por <b>$marca</b> </p>
	        <div>           
	            <ul>    
	                <li><b>Service TAG:</b> $chasis</li>
	                <li><b>Fondo Compra:</b> $fondo_compra</li>
	            </ul>
	        </div>
	    </body>
	</html>
MAFI

envio_backup($asunto, $mensaje, $fichero_backup);
