use strict;
use warnings;
use utf8;

use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTPS;

use Email::MIME;

use MIME::Base64;
use File::Slurp;

use IO::All;

my $RUTA = '/root/reporte';
require "$RUTA/informacion_sistema.pl";

sub transporte {
    my ($smtpserver, $smtpuser, $smtppassword) = obtener_configuracion_correo();

    my $t = Email::Sender::Transport::SMTPS->new({
        host => $smtpserver,
        port => '465',
        ssl => 'ssl',
        sasl_username => $smtpuser,
        sasl_password => $smtppassword,
    });
    
    return $t;
}

sub definicion_envio {
    my $asunto = shift;

    my ($receptor, $emisor) = obtener_configuracion_envio(); 
    
    return [
        'To' => $receptor,
        'From' => $emisor,
        'Subject' => $asunto,
        ]
}

sub crear_imagen_embebida {

    my $fichero_imagen = shift; 
    my $id_imagen = shift; 
    
    my $imagen = read_file($fichero_imagen, binmode => ':raw');

    return Email::MIME->create(
        header_str => [
            'Content-ID' => "<$id_imagen>",
            'Content-Disposition' => 'inline',
        ],
        attributes => {
            content_type => "image/png",
            encoding     => "base64",
        },
        body => $imagen,
    );
    
}

sub envio_diff {
    my $asunto = shift;
    my $contenido = shift; 

    my $cabecera = definicion_envio($asunto);

    my $correo = Email::MIME->create(
        header_str => $cabecera,
        attributes => {
            content_type => "text/plain",
            charset      => "utf-8",
            encoding     => "base64",
        },
        body_str => $contenido,
    );
    
    my $transporte = transporte(); 
    sendmail($correo, { transport => $transporte });
}

sub envio_reporte {
    my $asunto = shift;
    my $contenido = shift;

    my $memoria_imagen = shift;    
    my $trafico_imagen = shift;
    my $disco_imagen = shift;
	my $backup_fichero = shift;

	my $backup_name = (split (/\//, $backup_fichero))[-1];

    my $cabecera = definicion_envio($asunto);
    
    my $mail_part = Email::MIME->create(
        attributes => {
            content_type => "text/html",
            charset      => "utf-8",
            encoding     => "base64",
        },
        body_str => $contenido,
    );
    
    my $memoria = crear_imagen_embebida($memoria_imagen, 'memoria');
    my $trafico = crear_imagen_embebida($trafico_imagen, 'trafico');
    my $disco = crear_imagen_embebida($disco_imagen, 'disco');
    
	my $backup_part = Email::MIME->create(
			attributes => {
				filename => $backup_name,
				content_type => "application/x-gtar-compressed",
              	encoding     => "base64"
          },
          body => io($backup_fichero)->binary->all,
      ) or die "Error adjuntado el archivo";
    my $email = Email::MIME->create(
        header_str => $cabecera,
        attributes => {
            content_type => "multipart/related",
        },
        parts => [
            $mail_part,
            $trafico,
            $memoria,
            $disco,
			$backup_part
        ],
    );
    
    
    my $transport = transporte();
    sendmail($email, { transport => $transport });
}
1;
