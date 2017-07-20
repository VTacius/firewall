use strict;
use warnings;

use GD::Graph::lines;
use GD::Graph::Data;

# PRIVATE
sub datos_grafica_memoria {
	my $fichero = shift;

    my $data = GD::Graph::Data->new();
    open(my $contenido, '<:encoding(UTF-8)', $fichero) 
        or die "Problema al conseguir los datos en $fichero: $!";
    
    my $header = <$contenido>;
    # Columna 2: timestamp
    # Columna 3: kbmemfree
    # Columna 4: kbmemused
    # Columna 7: kbcached
    while (my $fila = <$contenido>){
        my @campos = split(/;/, $fila);
        my $hora = $campos[2];
        $hora =~ /.+(\w+:\w+):.+/;
        $data->add_point($1, $campos[3], $campos[4], $campos[7]);
    }

    return $data;

}

# PUBLICA
sub graficar_memoria {
    my $datos_origen = shift;
    my $fuente = shift;
    
    $datos_origen =~  /(.+?)\.(\w+)$/;
    my $salida = $1 . ".png";
    
    my $stats_memoria = datos_grafica_memoria($datos_origen); 
    
    my $etiqueta_grafica = 'Memoria (KB)';
    
    # Adecuamos la escala con conveniencia de cualquier datos que se disponga 
    my @limite = $stats_memoria->x_values();
    my $intervalo_grafica = ceil(scalar(@limite)/11);
    
    my @colores_grafica = qw(blue red green);
    my @leyenda_grafica = ('Memoria Libre', 'Memoria Usada', 'buff/cache');
    
    guardar_grafica($stats_memoria, $salida, $etiqueta_grafica, $intervalo_grafica, $fuente, \@leyenda_grafica, \@colores_grafica);

    return $salida;
}

1;
