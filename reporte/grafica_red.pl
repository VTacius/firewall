use strict;
use warnings;

use GD::Graph::lines;
use GD::Graph::Data;
	
sub creacion_grafica_red { 
	my $datos_origen = shift;
	my $fuente = shift;
	my $interfaz_wan = shift;

    $datos_origen =~  /(.+?)\.(\w+)$/;
	my $salida = $1 . ".png";

	my $data = GD::Graph::Data->new();
	
	open (my $contenido, '<:encoding(UTF-8)', $datos_origen) or die "No encuentro los datos origen en  $datos_origen";
	
	my $header = <$contenido>;
	while (my $fila = <$contenido>){
		my @campos = split(/;/, $fila);
		if ($campos[3] eq $interfaz_wan){
			my $hora = $campos[2];
			$hora =~ /(\d+\-*)+\s(\d+:+\d+)/;
			$data->add_point($2, $campos[6], $campos[7]);
		}
	}
	
	my $graph = GD::Graph::lines->new(600, 200);
	 
    # Adecuamos la escala con conveniencia de cualquier datos que se disponga 
    my @limite = $data->x_values();
    my $intervalo = ceil(scalar(@limite)/13);

	$graph->set( 
	    legend_placement => 'BB',
	    t_margin         => 15,
	    r_margin         => 15,
	    b_margin         => 5,
	    dclrs            => [ qw(red green)] ,
	
	    y_label          => 'Tráfico (kb)',
	    x_label_skip     => $intervalo,
	
	    line_width       => 2,
	    shadow_depth     => 4,
	 
	) or die $graph->error;
	
	$graph->set_legend('Kilobytes recibidos (rxkB/s)', 'Kilobytes enviados (txkB/s)', 'buff/cache');
	
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

#my $fuente = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf";
#my $interfaz_wan = 'eth0'; 
#creacion_grafica_red('redes_trafico.data', 'redes_trafico.png', $fuente, $interfaz_wan);

1;
