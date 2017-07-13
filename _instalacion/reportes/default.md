cat << "MAFI" > /etc/apache2/sites-available/default
<VirtualHost *:80>
    ServerAdmin fws@salud.gob.sv
    DocumentRoot /var/www/html
    
    <Directory /var/www/html/>
        Options -Indexes -FollowSymLinks -MultiViews -ExecCGI
    
        Order allow,deny
        Allow from all
    </Directory>
    
    <Directory /var/www/html/sarg>
        Options -Indexes -FollowSymLinks -MultiViews -ExecCGI
    
        AuthType Basic
        AuthName "Acceso a SARG"
        Require valid-user
        AuthUserFile /var/www/html/sarg/.htpassword
    </Directory> 
    
    LogLevel warn
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    
</VirtualHost>
MAFI
