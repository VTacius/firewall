use strict;
use warnings;

use GD::Graph::lines;
use GD::Graph::Data;

# PRIVATE
sub datos_grafica_trafico {
	my $fichero = shift;
	my $interfaz = shift;

	my $data = GD::Graph::Data->new();
	open (my $contenido, '<:encoding(UTF-8)', $fichero) 
        or die "No encuentro los datos origen en  $fichero";
	
	my $header = <$contenido>;
    # Columna 3: IFACE
    # Columna 2: timestamp
    # Columna 6: rxkB/s
    # Columna 7: txkB/s
	while (my $fila = <$contenido>){
		my @campos = split(/;/, $fila);
		if ($campos[3] eq $interfaz){
			my $hora = $campos[2];
			$hora =~ /(\d+\-*)+\s(\d+:+\d+)/;
			$data->add_point($2, $campos[6], $campos[7]);
		}
	}

    return $data;
}	

sub graficar_trafico {
    my $datos_origen = shift;
    my $fuente = shift;
    my $interfaz_wan = shift;

    $datos_origen =~  /(.+?)\.(\w+)$/;
    my $salida = $1 . ".png";

    my $stats_trafico = datos_grafica_trafico($datos_origen, $interfaz_wan); 
    
    my $etiqueta_grafica = 'Tráfico (kb)';

    # Adecuamos la escala con conveniencia de cualquier datos que se disponga 
    my @limite = $stats_trafico->x_values();
    my $intervalo_grafica = ceil(scalar(@limite)/11);
    
    my @colores_grafica = qw(red green);
    my @leyenda_grafica = ('Kilobytes recibidos (rxkB/s)', 'Kilobytes enviados (txkB/s)');
    
    guardar_grafica($stats_trafico, $salida, $etiqueta_grafica, $intervalo_grafica, $fuente, \@leyenda_grafica, \@colores_grafica);

    return $salida;
}

1;
