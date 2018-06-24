package Minsal::Backup;

use strict;
use warnings;
use utf8;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 0.20;
@ISA         = qw(Exporter);
@EXPORT      = qw(&backup);
@EXPORT_OK   = qw(&backup);
%EXPORT_TAGS = (DEFAULT => [qw(&backup)]);

use Archive::Tar;
use File::Find;
use Data::Dumper;

my $tar = Archive::Tar->new;

my @backupeables;

sub listar_directorio {
    push (@backupeables, $File::Find::name);
}

sub backup {
    
    my $fichero_resultante = shift;
    my @ficheros = @_;
    
    while (my $fichero = shift @ficheros){
        if (-f $fichero){
            push(@backupeables, $fichero);
        } elsif (-d $fichero) {
            find(\&listar_directorio, $fichero);
        } 
    }    

    $tar->add_files(@backupeables);
    
    $tar->write($fichero_resultante, COMPRESS_GZIP)
        or die "No puedo agregar $File::Find::name $!";
}

1;
