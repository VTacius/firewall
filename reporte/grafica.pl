use strict;
use warnings;

# PRIVATE
sub guardar_grafica {
    my $data = shift;
    my $salida = shift;
    my $etiqueta = shift;
    my $intervalo = shift;
    my $fuente = shift;
    my $leyenda = shift;
    my $colores = shift;

	my $graph = GD::Graph::lines->new(600, 200);
	 
    $graph->set( 
        legend_placement => 'BB',
	    t_margin         => 15,
	    r_margin         => 15,
	    b_margin         => 5,
	    dclrs            => \@$colores,
	    y_label          => $etiqueta,
        x_label_skip     => $intervalo,
	
	    line_width       => 2,
	    shadow_depth     => 4,
	 
	) or die $graph->error;
	
	$graph->set_legend(@$leyenda);
	
	$graph->set_y_label_font($fuente, 12);
	$graph->set_x_label_font($fuente, 12);
	$graph->set_y_axis_font($fuente, 8);
	$graph->set_x_axis_font($fuente, 7);
	$graph->set_title_font($fuente, 14);
	$graph->set_legend_font($fuente, 9);
	$graph->set_values_font($fuente, 8);
	
	$graph->plot($data) or die $graph->error;
	 
	open(my $grafica, '>', $salida) 
        or die "Problemas abriendo '$salida' para crear gráfico: $!";
	binmode $grafica;
	print $grafica $graph->gd->png;
	close $grafica;

}

1;
