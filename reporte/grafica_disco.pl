use strict;
use warnings;

no if $] >= 5.017011, warnings => 'experimental::smartmatch';

use GD::Graph::lines;
use GD::Graph::Data;
	
use POSIX;

sub obtener_porcentaje_disco {
	my $datos_origen = shift;
	my @orden = @_; 
	
	open (my $contenido, '<:encoding(UTF-8)', $datos_origen) or die "Problema al conseguir los datos en $datos_origen: $!";

	my %dispositivos; 

	while (my $fila = <$contenido>){
		my @campos = split(/;/, $fila);	
		if (exists $dispositivos{$campos[3]}) {
			push (@{$dispositivos{$campos[3]}}, $campos[6]);
		} elsif ($campos[3] =~ /^\//) {
			@{$dispositivos{$campos[3]}} = ();
		}
	} 

	my %porcentajes_final; 
	
	while (my $etiqueta = shift(@orden)){
		if (exists $dispositivos{$etiqueta}){
			$porcentajes_final{$etiqueta} = (@{$dispositivos{$etiqueta}})[-1];
		}
	}

	return %porcentajes_final;

}

sub creacion_promedio_disco {
	my $datos_origen = shift;
	my @orden = @_; 

    $datos_origen =~  /(.+?)\.(\w+)$/;
	my $datos_promedio = $1 . ".promedio";

	my %dispositivos; 
	
    open (my $contenido, '<:encoding(UTF-8)', $datos_origen) or die "Problema al conseguir los datos en $datos_origen: $!";

	while (my $fila = <$contenido>){
		my @campos = split(/;/, $fila);	
		if (exists $dispositivos{$campos[3]}) {
			push (@{$dispositivos{$campos[3]}}, $campos[4]);
		} elsif ($campos[3] =~ /^\//) {
			@{$dispositivos{$campos[3]}} = ();
		}
	} 

	close($contenido);

	my @promedio_diario = ();
	while (my $etiqueta = shift(@orden)){
		if (exists $dispositivos{$etiqueta}){
			push (@promedio_diario, promedio(@{$dispositivos{$etiqueta}}));
		}
	}

	# Esta es la fecha
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();


    # Me aseguro que no crezca más allá de un límite
	open(my $resultado, '<', $datos_promedio);
	my @registro = map{$_} <$resultado>;
	while (@registro > 10){
	    shift(@registro);
	}
	close ($resultado);
	
    # Ahora sí, guardo el registro del promedio del día 	
	open(my $inserto, '>', $datos_promedio);
	push (@registro, "$mday\/$mon\t" . join("\t", @promedio_diario));
	say $inserto @registro;
	close ($inserto);
}

sub creacion_grafica_disco { 
	my $datos_origen = shift;
	my $fuente = shift;
	my @orden = @_;

    $datos_origen =~ /(.+?)\.(\w+)$/;
    my $salida = $1 . ".png";

	my $data = GD::Graph::Data->new();
	
	open (my $contenido, '<:encoding(UTF-8)', $datos_origen) or die "Problema al conseguir los datos en $datos_origen: $!";
	
	my $header = <$contenido>;
	while (my $fila = <$contenido>){
		my @campos = split(/\t/, $fila);
		$data->add_point(@{campos});
	}

    my @leyenda;

    my @particiones = obtener_particiones();

    # Ahora ordenamos las particiones
    foreach(@orden){
        if ($_ ~~ @particiones ){
            push(@leyenda, $_);
        } 
    }  

	my $graph = GD::Graph::lines->new(600, 200);
	 
	$graph->set( 
	    legend_placement => 'BB',
	    t_margin         => 15,
	    r_margin         => 15,
	    b_margin         => 5,
	    dclrs            => [ qw(red blue green lorange)] ,
	
	    y_label          => 'Memoria (kb)',
	    x_label_skip     => 2,
	
	    line_width       => 2,
	    shadow_depth    => 4,
	 
	) or die $graph->error;
	
	$graph->set_legend(@{leyenda});
	
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

sub promedio {
	my $sum = 0;
	foreach(@_){
		$sum += $_;
	}

	return floor($sum / @_);
}

1;
