#!/usr/bin/perl
use strict;
use warnings;

my $RUTA = '/root/reporte';
my $RUTA_BACKUP = "/var/backups"; 

require "$RUTA/backup.pl";
require "$RUTA/envio_correo.pl";
require "$RUTA/informacion_sistema.pl";
require "$RUTA/grafica_disco.pl";

my @orden = ('/boot', '/boot/efi', '/', '/home', '/tmp', '/var');
# TODO: Esta configuración debería ser más dinámica
my $memoria_disponible = 4000000;

# Obtenemos algunas marcas de tiempo para crear nombres más adelante
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year += 1900;
my $dia = "$mday/$mon/$year";
my $timestamp = "$mday$mon$year-$hour$min$sec";

# Información del equipo obtenida directamente del sistema
my $hostname = hostname();
my %reglas_firewall = reglas_firewall();
my ($chasis, $modelo, $marca) = informacion_equipo();
my ($dias, $horas, $minutos, $segundos) = uptime();

# Información obtenida desde ~/configuracion_reporte.ini
my $RUTA_DATA = obtener_configuracion_general('ruta_datos');
my $TIPO_FUENTE = obtener_configuracion_general('tipo_fuente');

my $memoria_imagen = '/var/spool/actividad/memoria.png';
my $trafico_imagen = '/var/spool/actividad/trafico.png';
my $disco_imagen = '/var/spool/actividad/disco.png';
my $fichero_backup = '/var/backups/backup-firewall-86117-7141.tgz';

### A partir de acá, dumpear todo

# Información obtenida desde /root/fws/infraestructura.sh
my %configuracion_legacy = cargar_configuracion_legacy();
my $institucion = $configuracion_legacy{'INSTITUCION'};
my $fondo_compra = $configuracion_legacy{'FONDO_COMPRA'};
my $interfaz_wan = $configuracion_legacy{'INW'}; 
my $ip_interfaz_wan = $configuracion_legacy{'SRW'};

# Operaciones estadísticas relacionadas con discos
my $disco_origen = "$RUTA_DATA/disco.data";
my $disco_promedio = "$RUTA_DATA/disco.promedio"; 
creacion_promedio_disco($disco_origen, @orden); 

my %porcentaje_disco = obtener_porcentaje_disco($disco_origen, @orden); 

my $actual_uso_disco = "<ul>"; 
foreach(@orden){
    if (exists($porcentaje_disco{$_})){
        $actual_uso_disco .= "<li><b>$_:</b> $porcentaje_disco{$_}%</li>";
    }
}
$actual_uso_disco .= "</ul>";


my $asunto = "Firewall $institucion: Reporte y Backup en $dia";

my $mensaje = <<"MAFI";
<html>
        <head>
<style>
        ul {
                list-style: none;
                padding-left: 0;
        }

        li {
                display: inline;
        } 

        li b {
                width: 9em;
                display: inline-block;
                text-align: right;
        }
</style>
        </head>
        <body>
                <h4>Información General del Firewall</h4>
                <p><b>$hostname</b> accesible en <tt>$ip_interfaz_wan</tt></p> 
                <p>En <b>$modelo</b> por <b>$marca</b> </p>
                <div>           
                        <ul>    
                                <li><b>Service TAG:</b> $chasis</li>
                                <li><b>Fondo Compra:</b> $fondo_compra</li>
                        </ul>
                </div>
                
                <h4>Información General del Sistema</h4>
                <p>Arriba por <b>$dias días, $horas horas y $minutos minutos</b></p>

                <h4> Memoria </h4>
                <img src="cid:memoria" />
                
                <h4> Tráfico en interfaz WAN ($interfaz_wan) </h4>
                <img src="cid:trafico" />
                
                <h4> Uso actual de disco duro </h4>
                   $actual_uso_disco
 
                <h4> Uso histórico de disco duro </h4>
                <img src="cid:disco" />

                <h4> Estado Firewall </h4>
                <ul>    
                        <li><b>INPUT:</b> $reglas_firewall{'INPUT'}</li> 
                        <li><b>OUTPUT:</b> $reglas_firewall{'OUTPUT'}</li>
                        <li><b>FORWARD:</b> $reglas_firewall{'FORWARD'}</li>
                </ul>   
        </body>
</html>

MAFI

envio_reporte($asunto, $mensaje, $memoria_imagen, $trafico_imagen, $disco_imagen, $fichero_backup);
