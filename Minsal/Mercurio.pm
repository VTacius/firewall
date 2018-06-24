package Minsal::Mercurio;

use strict;
use warnings;
use utf8;
use Exporter;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION     = 0.20;
@ISA         = qw(Exporter);
@EXPORT      = qw(&envio_diferencias &envio_backup);
@EXPORT_OK   = qw(&envio_diferencias &envio_backup);
%EXPORT_TAGS = ( DEFAULT => [qw(&envio_diferencias &envio_backup)]);

use Minsal::Informacion;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTPS;
use Email::MIME;

use IO::All;

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

sub envio_diferencias {
    my $asunto = shift;
    my $contenido = shift;

    my $cabecera = definicion_envio($asunto);
    
    my $email = Email::MIME->create(
        header_str => $cabecera,
        attributes => {
            content_type => "multipart/related",
        },
        attributes => {
            content_type => "text/html",
            charset      => "utf-8",
            encoding     => "base64",
        },
        body_str => $contenido,
    );
    
    my $transport = transporte();
    sendmail($email, { transport => $transport });
}

sub envio_backup {
    my $asunto = shift;
    my $contenido = shift;

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
			$backup_part
        ],
    );
    
    my $transport = transporte();
    sendmail($email, { transport => $transport });
}

1;
