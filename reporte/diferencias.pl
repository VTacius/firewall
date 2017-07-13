#!/usr/bin/perl
use strict;
use warnings;

use Text::Diff;
use File::Compare;
use File::Copy;

my $RUTA = '/root/reporte';

require "$RUTA/envio_correo.pl";

sub diferencias {

    my $directorio_base = shift;
    my $fichero = shift;

    my $fichero_backup = "$directorio_base/archivo/$fichero";
    my $fichero_nuevo = "$directorio_base/$fichero";
    
    if (compare($fichero_backup, $fichero_nuevo)){
        my $resultado = diff ($fichero_backup, $fichero_nuevo, {STYLE => 'OldStyle'}) or die "Problema al buscar cambios en fichero $fichero_backup: $!";
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
            $resultado .= "\n";
        } 
    }
    
    return $resultado;
}

my @ficheros = (qw(dmz.sh establecimiento.sh firewall.sh grupos_ipset.sh infraestructura.sh rutas.sh));
my $directorio_base = '/root/fws';

my $result_diferencias = envia_diferencias($directorio_base, @ficheros);
if (length($result_diferencias) > 0){
	envio_diff("Envio de las diferencias", $result_diferencias); 
	foreach(@ficheros){
		copy("$directorio_base/$_", "$directorio_base/archivo/$_") or die "Backup de $_ fallido: $!";
	}
}

