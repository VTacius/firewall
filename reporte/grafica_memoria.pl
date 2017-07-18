use strict;
use warnings;

use GD::Graph::lines;
use GD::Graph::Data;
use POSIX;

sub creacion_grafica_memoria { 
    my $datos_origen = shift;
    my $fuente = shift;
    my $memoria_disponible = shift;

    $datos_origen =~  /(.+?)\.(\w+)$/;
    my $salida = $1 . ".png";

    my $data = GD::Graph::Data->new();
    
    open (my $contenido, '<:encoding(UTF-8)', $datos_origen) or die "Problema al conseguir los datos en $datos_origen: $!";
    
    my $header = <$contenido>;
    while (my $fila = <$contenido>){
        my @campos = split(/;/, $fila);
        my $hora = $campos[2];
        $hora =~ /(\d+\-*)+\s(\d+:+\d+)/;
        $data->add_point($2, $campos[3], $campos[4], $campos[7]);
    }
   
    # Adecuamos la escala con conveniencia de cualquier datos que se disponga 
    my @limite = $data->x_values();
    my $intervalo = ceil(scalar(@limite)/11);

    my $graph = GD::Graph::lines->new(600, 200);
     
    $graph->set( 
        legend_placement => 'BB',
        t_margin         => 15,
        r_margin         => 15,
        b_margin         => 5,
        dclrs            => [qw(blue red green)] ,
    
        y_label          => 'Memoria (kb)',
        y_max_value      => $memoria_disponible,
        x_label_skip     => $intervalo,
    
        line_width       => 2,
        shadow_depth    => 4,
     
    ) or die $graph->error;
    
    $graph->set_legend('Memoria Libre', 'Memoria Usada', 'buff/cache');
    
    $graph->set_y_label_font($fuente, 12);
    $graph->set_x_label_font($fuente, 12);
    $graph->set_y_axis_font($fuente, 8);
    $graph->set_x_axis_font($fuente, 7);
    $graph->set_title_font($fuente, 14);
    $graph->set_legend_font($fuente, 9);
    $graph->set_values_font($fuente, 8);
    
    $graph->plot($data) or die $graph->error;
     
    open(my $grafica, '>', $salida) or die "Problemas abriendo '$salida' para crear gráfico: $!";
    binmode $grafica;
    print $grafica $graph->gd->png;
    close $grafica;
}

1;
