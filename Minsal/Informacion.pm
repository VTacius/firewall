package Minsal::Informacion;

use strict;
use warnings;
use utf8;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 0.20;
@ISA         = qw(Exporter);
@EXPORT      = qw(&informacion_equipo &hostname &obtener_configuracion_correo &obtener_configuracion_envio &obtener_configuracion_legacy);
@EXPORT_OK   = qw(&informacion_equipo &hostname &obtener_configuracion_correo &obtener_configuracion_envio &obtener_configuracion_legacy);
%EXPORT_TAGS = ( DEFAULT => [qw(&informacion_equipo &hostname &obtener_configuracion_correo &obtener_configuracion_envio &obtener_configuracion_legacy)]);

use Config::Simple;

my $fichero_configuracion = '/root/.configuracion_reporte.ini';
my $fichero_configuracion_legacy = '/etc/fws/infraestructura.sh';

######### Auxiliares
sub  trim { 
	my $s = shift; 
	$s =~ s/^\s+|\s+$//g; 
	return $s 
}

######### Los infaltables clásicos

#####
sub hostname {
    my $hostname_fichero = '/proc/sys/kernel/hostname';
    open(my $host_name, '<', $hostname_fichero) 
        or die "No puedo abrir el fichero $hostname_fichero"; 
    close($hostname_fichero);    
    
    my $host = <$host_name>;
    return trim($host);
}

#####
sub informacion_equipo {
    # Obtenemos el número de Chasis
    my $chasis = qx(/usr/sbin/dmidecode -q -s chassis-serial-number);
    my $modelo = qx(/usr/sbin/dmidecode -q -s system-product-name);
    my $marca = qx(/usr/sbin/dmidecode -q -s system-manufacturer);
        
    return substr($chasis,0,-1), substr($modelo,0,-1), substr($marca,0,-1);     
}

######### Los siguiente se deberían considerar primordiales de acuerdo a nuestro trabajo

#####
sub obtener_configuracion_correo {
    my $cfg = new Config::Simple(filename => $fichero_configuracion)
        or die Config::Simple->error();
    
    my $server = $cfg->param('correo.servidor');
    my $user   = $cfg->param('correo.usuario');
    my $password = $cfg->param('correo.password');
    
    return ($server, $user, $password);
    
}

#####
sub obtener_configuracion_envio {
    my $cfg = new Config::Simple(filename => $fichero_configuracion)
        or die Config::Simple->error();

    my $receptor = $cfg->param('envio.receptor');
    my $emisor = $cfg->param('correo.usuario');

    return ($receptor, $emisor);
}

#####
sub obtener_configuracion_legacy {
    my $clave = shift;
    
    my %configuracion_legacy;

    open(my $contenido, '<:encoding(UTF-8)', $fichero_configuracion_legacy) 
        or die "No puedo abrir el fichero $fichero_configuracion_legacy";

    while (my $fila = <$contenido>){
        if ($fila =~ /^(INSTITUCION|FONDO_COMPRA|INW|SRW)\=\"?(.+?)(\"|$)/){
            my $clave = $1;
            my $valor = $2;
            $valor =~ s/"$//g;
            $valor = (length($valor)>0) ? $valor : "Información no disponible";
            $configuracion_legacy{$clave} = $valor;        
        }
    }

    return %configuracion_legacy;
}

1;
