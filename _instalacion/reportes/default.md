<VirtualHost *:80>
    ServerAdmin fws@salud.gob.sv
    DocumentRoot /var/www/html
    
    <Directory /var/www/html/>
        Options -Indexes -FollowSymLinks -MultiViews -ExecCGI
    
        Order allow,deny
        Allow from all
    </Directory>
    
    LogLevel warn
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    
</VirtualHost>
