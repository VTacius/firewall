use strict;
use warnings;

no if $] >= 5.017011, warnings => 'experimental::smartmatch';

use GD::Graph::lines;
use GD::Graph::Data;

sub columneador {
    my $origen_datos = shift;
    my $columna  = shift;
    my @particiones = obtener_particiones();

    my %dispositivos;

    open(my $contenido, '<:encoding(UTF8)', $origen_datos);

    while(my $fila = <$contenido>){
        my @columnas = split(/;/, $fila);
        if ($columnas[3] ~~ @particiones){
            push ( @{$dispositivos{$columnas[3]}}, $columnas[$columna]); 
        }
    }

    return %dispositivos;
}

# Privado
sub promedio {
	my $sum = 0;
	foreach(@_){
		$sum += $_;
	}

	return ($sum / @_);
}

# Obtiene el promedio de la columna dada, devuelve un diccionario así conveniente
# Este es bastante complicado de entender, tomando en cuenta que necesito tomar valores por referencia 
# para poder tomar dos argumentos de tipo lista y diccionarios
sub promedio_columna {
	my $uso_diario = shift;
	my $particiones = shift;

    my %dispositivos;
   
    foreach(@$particiones){
        if (exists($$uso_diario{$_})){
			$dispositivos{$_} = promedio(@{$$uso_diario{$_}});
        }
    }

    return %dispositivos;
}

# PRIVATE
# La columna 5 contiene MBfsused, es decir, el porcentaje de uso de disco
sub obtiene_promedio_lista {
	my $fichero = shift;
	my @orden_particiones = @_;
	
	my @registro;	

	my %uso = columneador($fichero, 5);

	my %promedio = promedio_columna(\%uso, \@orden_particiones);

	foreach(@orden_particiones){
		if (exists($promedio{$_})){
			push (@registro, $promedio{$_});
		}
	}

	return @registro;
}

# PUBLIC: Se usa directamente en reporte
# Para evitar confusión: Acá promedio se refiere a promedio de MB usados
# La columna 6 contiene %fsused, es decir, el porcentaje de uso de disco
sub promedio_uso_disco {
	my $fichero = shift;
	my @orden_particiones = @_;

	my %uso = columneador($fichero, 6);

	return promedio_columna(\%uso, \@orden_particiones);
}

# Private
# Abre el fichero con los datos promedios delos demás días
sub fichero_promedio_lee {
	my $fichero = shift;

	my @registro;
	open (my $contenido, '<', $fichero)
        or die "Problemas abriendo '$fichero' para leer promedios: $!";
	@registro = map {$_} <$contenido>;
	close($contenido);

    return @registro;
}

sub fichero_promedio_escribe {
    my $fichero = shift;
    my @datos = @_;

	open (my $agregado, '>', $fichero)
        or die "Problemas abriendo '$fichero' para guardar promedios: $!";
	say $agregado @datos;
	close ($agregado);	

}

# Para evitar confusión: Acá promedio se refiere a promedio de porcentajes
sub guarda_promedio_uso {
	my $fichero = shift;
	my @orden_particiones = @_;

   	$fichero =~ /(.+?)\.(\w+)$/;
    my $salida = $1 . ".prom";	
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();

    my @registro = fichero_promedio_lee($salida);
	while (scalar(@registro) > 12){
		shift(@registro);
	};

	my @registro_diario = obtiene_promedio_lista($fichero, @orden_particiones);
	push (@registro, "$mday\/$mon\t" . join("\t", @registro_diario));

    fichero_promedio_escribe($salida, @registro);
	
	return $salida;	
}

# PRIVATE
# Desde el fichero datos.data moldea los datos para hacer la gráfica
sub datos_grafica_disco {
	my $fichero = shift;
	my @orden = @_;

	my $data = GD::Graph::Data->new();
	
	open (my $contenido, '<:encoding(UTF-8)', $fichero) 
        or die "Problema al conseguir los datos en $fichero: $!";
	
	while (my $fila = <$contenido>){
		my @campos = split(/\t/, $fila);
		$data->add_point(@campos);
	}

	return $data;
}

# PUBLIC: Se usa directamente en reporte
sub graficar_disco {
    my $fichero = shift;
    my $fuente = shift;
    my @orden_particiones = @_;
    
   	$fichero =~ /(.+?)\.(\w+)$/;
    my $salida = $1 . ".png";	
    
    my $fichero_disco_promedio = guarda_promedio_uso($fichero, @orden_particiones);
    
    my $stats_disco = datos_grafica_disco($fichero_disco_promedio, @orden_particiones);
    
    my $etiqueta_grafica = 'Disco Utilizado';
    my $intervalo_grafica = 1;
    my @colores_grafica = qw(red blue green lorange);

    # Este es un caso especial para la leyenda de esta gráfica en particular
    my @leyenda_grafica;
    my @particiones_existentes = obtener_particiones();
    foreach(@orden_particiones){
        if ($_ ~~ @particiones_existentes ){
            push(@leyenda_grafica, $_);
        } 
    }  
    
    guardar_grafica($stats_disco, $salida, $etiqueta_grafica, $intervalo_grafica, $fuente, \@leyenda_grafica, \@colores_grafica);

    return $salida;
}

1;
# Si realizas las pruebas de esta forma, entre otras cosas, metes dos veces datos 
# en promedios, pero sirve, así podrás exactamente cuál es el problema de haberlo
##my $fichero_disco = '/var/spool/actividad/disco.data';
##my @orden_montajes = ('/', '/boot', '/boot/efi', '/home', '/tmp', '/var');
##my $fuente_grafica = '/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf';
##
##print Dumper(promedio_uso_disco($fichero_disco, @orden_montajes));
##print join("\t", obtener_particiones()) . "\n";
##print join("\t", obtiene_promedio_lista($fichero_disco, @orden_montajes)) . "\n";
##print Dumper(guarda_promedio_uso($fichero_disco, @orden_montajes));
##graficar_disco($fuente_grafica, $fichero_disco, @orden_montajes);
