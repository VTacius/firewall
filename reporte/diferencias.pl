#!/usr/bin/perl
use strict;
use warnings;
use utf8;

use Text::Diff;
use File::Compare;
use File::Copy;

my $RUTA = '/root/reporte';

require "$RUTA/envio_correo.pl";
require "$RUTA/informacion_sistema.pl";

sub diferencias {
    my $directorio_base = shift;
    my $fichero = shift;

    my $fichero_backup = "$directorio_base/archivo/$fichero";
    my $fichero_nuevo = "$directorio_base/$fichero";
    
    if (compare($fichero_backup, $fichero_nuevo)){
        open(my $f_backup_encoding, '<:encoding(UTF-8)', $fichero_backup) 
            or die "No puedo abrir el fichero $fichero_backup";
        open(my $f_nuevo_encoding, '<:encoding(UTF-8)', $fichero_nuevo)
            or die "No puedo abrir el fichero $fichero_nuevo";

        my $resultado = diff ($f_backup_encoding, $f_nuevo_encoding, {STYLE => 'OldStyle'}) 
            or die "Problema al buscar cambios en fichero $fichero_backup: $!";
        
        return $resultado; 
    } else {
        return 0;
    }
}

sub envia_diferencias {
    my $directorio_base = shift;
    my @ficheros = @_;

    my $resultado = ""; 
    
    foreach(@ficheros){
        my $fichero_resultado = diferencias ($directorio_base, $_);
        
        if ($fichero_resultado){
            $resultado .= "Los siguientes cambios fueron realizados a $_ \n";
            $resultado .= $fichero_resultado;
            $resultado .= "\n\n";
        } 
    }
    
    return $resultado;
}

my @ficheros = (qw(dmz.sh establecimiento.sh firewall.sh grupos_ipset.sh infraestructura.sh rutas.sh));
my $directorio_base = '/root/fws';

my %configuracion_legacy = cargar_configuracion_legacy();

my $institucion = $configuracion_legacy{'INSTITUCION'};
my $ip_interfaz_wan = $configuracion_legacy{'SRW'};
my $hostname = hostname();

# Obtenemos algunas marcas de tiempo para crear nombres más adelante
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year += 1900;
my $dia = "$mday/$mon/$year";

my $asunto = "Firewall $institucion: Cambios de configuración en $dia";

my $result_diferencias = envia_diferencias($directorio_base, @ficheros);
if (length($result_diferencias) > 0){
    my $contenido = <<"MAFI";
    Resumen de cambios en la configuración de $hostname, accesible en $ip_interfaz_wan
    
$result_diferencias
MAFI

	envio_diff($asunto, $contenido); 
	
    foreach(@ficheros){
		copy("$directorio_base/$_", "$directorio_base/archivo/$_") 
            or die "Backup de $_ fallido: $!";
	}
}

