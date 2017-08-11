use strict;
use warnings;
use utf8;

use Date::Calc qw(Normalize_DHMS);

use Config::Simple;

my $fichero_configuracion = '/root/.configuracion_reporte.ini';
my $fichero_configuracion_legacy = '/root/fws/infraestructura.sh';

sub  trim { 
	my $s = shift; 
	$s =~ s/^\s+|\s+$//g; 
	return $s 
}

sub uptime {
    # Calcula el tiempo que lleva encendido el equipo
    my $uptime_fichero = '/proc/uptime';
    
    open (my $uptime, '<', $uptime_fichero) 
        or die "No puedo abrir el fichero $uptime_fichero";
    
    my $up = (split( /\s+/, <$uptime>))[0];
    close($uptime_fichero);

    return Normalize_DHMS(0, 0, 0, $up);

}

sub informacion_equipo {
    # Obtenemos el número de Chasis
    my $chasis = qx(/usr/sbin/dmidecode -q -s chassis-serial-number);
    my $modelo = qx(/usr/sbin/dmidecode -q -s system-product-name);
    my $marca = qx(/usr/sbin/dmidecode -q -s system-manufacturer);
        
    return $chasis, $modelo, $marca;     
}

sub reglas_firewall {
    my %resultado; 
    my @cadena = qx(/sbin/iptables -t filter -nvL);
    
    while(my $fila = shift(@cadena)){
        if ($fila =~ /^Chain\s+(INPUT|FORWARD|OUTPUT)\s+\(policy\s+(\w+)/){
            $resultado{$1} = $2;
        }
    }

    return %resultado; 
}

sub hostname {
    my $hostname_fichero = '/proc/sys/kernel/hostname';
    open(my $host_name, '<', $hostname_fichero) 
        or die "No puedo abrir el fichero $hostname_fichero"; 
    close($hostname_fichero);    
    
    my $host = <$host_name>;
    return trim($host);
}

sub obtener_particiones {
    my $fichero = '/etc/fstab';
    open(my $contenido, '<', $fichero);
    
    my @resultado;
    while (my $fila = <$contenido>){
        if ($fila =~ /^UUID/){
           push(@resultado, (split(/\s+/, $fila))[1]);
        }
    }
    
    close($fichero);
    
    return @resultado;
}

sub obtener_configuracion_correo {
    my $cfg = new Config::Simple(filename => $fichero_configuracion);
    
    my $server = $cfg->param('correo.servidor');
    my $user   = $cfg->param('correo.usuario');
    my $password = $cfg->param('correo.password');
    
    return ($server, $user, $password);
    
}

sub obtener_configuracion_envio {
    my $cfg = new Config::Simple(filename => $fichero_configuracion);

    my $receptor = $cfg->param('envio.receptor');
    my $emisor = $cfg->param('correo.usuario');

    return ($receptor, $emisor);
}

sub obtener_configuracion_general {
    my $clave = shift;

    my $cfg = new Config::Simple(filename => $fichero_configuracion);

    my $valor = $cfg->param("general.$clave") 
        or die "Error al obtener configuración: No existe la clave $clave";

    return $valor;
}

sub obtener_configuracion_sistema {
    my $clave = shift;

    my $cfg = new Config::Simple(filename => $fichero_configuracion);

    my $valor = $cfg->param("sistema.$clave")
        or die "Error al obtener configuracion: No existe la clave $clave";

    return $valor;
}

sub cargar_configuracion_legacy {
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
