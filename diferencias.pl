#!/usr/bin/perl
use strict;
use warnings;
use utf8;

use Text::Diff;
use File::Compare;
use File::Copy;
use Minsal::Mercurio; 
use Minsal::Informacion;

sub busca_diferencias {
    my $fichero_backup = shift;
    my $fichero_actual = shift;
    open(my $f_backup_encoding, '<:encoding(UTF-8)', $fichero_backup) 
        or die "No puedo abrir el fichero $fichero_backup";
    open(my $f_nuevo_encoding, '<:encoding(UTF-8)', $fichero_actual)
        or die "No puedo abrir el fichero $fichero_actual";

    my $resultado = diff ($f_backup_encoding, $f_nuevo_encoding, {STYLE => 'OldStyle'}) 
        or die "Problema al buscar cambios en fichero $fichero_backup: $!";
    
    return $resultado; 
}

sub muestra_diferencias {
    my $backup = shift;
    my $actual = shift;

    my $contenido = busca_diferencias($backup, $actual);
    my $resultado = "
	<div>
    	<h4>Cambios en $actual:</h4>
    	<pre>
        	$contenido
    	</pre>
	</div>
    ";
    
    return $resultado;
}

#### Empiezan las operaciones 

my %datos_firewall = obtener_configuracion_legacy();
my $institucion = $datos_firewall{'INSTITUCION'};

# Estos deberían conseguirse desde un fichero de configuración. Uno que permita configurar ciertos archivos para diversos directorios, básicamente ambicioso
my $directorio_base = '/etc/fws';
my @ficheros = (qw(dmz.sh establecimiento.sh firewall.sh grupos_ipset.sh infraestructura.sh rutas.sh));

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year += 1900;
my $fecha = "$mday/$mon/$year $hour:$min:$sec";
my $ts = "$year$mon$mday-$hour$min$sec";

# El cuerpo del resultado, de existir tal cosa
my $resultado = "";

# Cabecera de la plantilla
my $plantilla_cabecera = <<"MAFI";
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

			pre { 
        		font-size: 0.8em;
        		direction: ltr;
        		font-family: monospace,Courier;
        		padding: 1em;
        		color: black;
        		background-color: #f9f9f9;
        		line-height: 1.3em;
    		}
        </style>
    </head>
	<body>
MAFI

my $plantilla_pies = <<"MAFI";
	</body>
</html>
MAFI

my $asunto = "Firewall $institucion: Cambios de configuración en $fecha";

foreach(@ficheros){
    my $ruta_backup = "/var/backups/fws/$_";
    my $ruta_actual = "/etc/fws/$_";
    
    my $comparacion =  compare($ruta_backup, $ruta_actual);
    
    if ( $comparacion == 1){
        $resultado .= muestra_diferencias($ruta_backup, $ruta_actual);
        # Copiamos el actual archivo a su respectivo backup
		copy("$ruta_actual", "$ruta_backup") 
            or die "Backup de $_ fallido: $!\n";
        # Hacemos un backup del backup con una fecha para identificarle
		copy("$ruta_backup", "$ruta_backup-$ts") 
            or die "Backup de $_ fallido: $!\n";
    } elsif ($comparacion == -1){
        print "No puedo comparar los ficheros para $ruta_actual\n";
    }
}

# Sólo si en verdad hubo cambios
if (length($resultado) > 0){
	my $contenido = $plantilla_cabecera. $resultado . $plantilla_pies;
    envio_diferencias($asunto, $contenido);
}

