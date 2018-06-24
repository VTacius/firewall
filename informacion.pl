#!/usr/bin/perl
use strict;
use warnings;
use utf8;

use Switch;
use Getopt::Long;
use Minsal::Informacion qw(informacion_equipo);

my $opcion;

GetOptions ("modulo=s" => \$opcion);

#####
my $ruta = "/etc/network/interfaces";

open(my $fichero, '<', $ruta) or die("No puedo abrir el fichero");

my @contenido = <$fichero>;

my $cadena;

sub interfaz {

    my $resultado;

    my $interface = shift;
    if($interface =~ /# RED\s([A-Z]+)\..+?iface\s(\w+).+?\s+address\s((?:[0-9]+\.*)+)/){
        $resultado = "estado_confred,asignacion=$1,interface=$2 ipaddress=\"$3\"\n";
        return $resultado;
    }

}

sub obtiene_interfaz {
    
    my $resultado = "";
    my $linea = shift;

    $cadena .= substr($linea, 0, -1);        
    
    if ($linea =~/^#\s?RED/){
        $cadena = "";
        $cadena .= substr($linea, 0, -1);        
    }elsif ($linea =~ /^\s+address/){
        $resultado = interfaz($cadena);
    }

    return $resultado;
}

sub informacion_interfaces {
    my $resultado; 

    foreach my $i (0 .. $#contenido){
        $resultado .= obtiene_interfaz($contenido[$i]);
    }

    return $resultado;
    
}

#####
sub reglas_firewall {
    # De cada tabla, obtiene su política por defecto actual
    my $tabla = shift;
    my $resultado; 
    my @cadena = qx(/sbin/iptables -t filter -nvL $tabla);
    
    my $fila = shift(@cadena);
    if ($fila =~ /^Chain\s+(INPUT|FORWARD|OUTPUT)\s+\(policy\s+(\w+)/){
        $resultado = ($2 =~ "DROP") ? 1 : 5;
    }

    return $resultado; 
}


switch ($opcion){
    case "iptables" {
        my $input = reglas_firewall("INPUT");
        my $output = reglas_firewall("OUTPUT");
        my $forward = reglas_firewall("FORWARD");
        print "estado_iptables,cadena=input value=$input\nestado_iptables,cadena=output value=$output\nestado_iptables,cadena=forward value=$forward";
    }
    
    case "hardware" {
        my ($c, $m, $a) = informacion_equipo();
        print "estado_hardware chasis=\"$c\",modelo=\"$m\",marca=\"$a\""; 
    }

    case "red" {
        print informacion_interfaces();
    }
    
}
