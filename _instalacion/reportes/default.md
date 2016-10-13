cat << "MAFI" > /etc/apache2/sites-available/default
<VirtualHost *:80>
ServerAdmin fws@salud.gob.sv
DocumentRoot /var/www
<Directory /var/www/>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride None
    Order allow,deny
    Allow from all
</Directory>
<Directory /var/www/sarg>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride None
    Order deny,allow
    Allow from all
    AuthName "Autenticación"
    AuthType Basic
    Require valid-user
    AuthUserFile /var/www/sarg/.htpassword
</Directory> 
ErrorLog ${APACHE_LOG_DIR}/error.log
LogLevel warn
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
MAFI
