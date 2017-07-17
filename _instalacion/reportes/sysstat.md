# The first element of the path is a directory where the debian-sa1
# script is located
PATH=/usr/lib/sysstat:/usr/sbin:/usr/sbin:/usr/bin:/sbin:/bin

# Activity reports every 10 minutes everyday
0-55/5 * * * * root command -v debian-sa1 > /dev/null && debian-sa1 1 1

# Antes de que se rote al archivo de estadística de este día, disponemos de las estadísticas que en realidad nos interesan 
56 23 * * * root command -v sadf > /dev/null && sadf -d -s 00:00:00 -e 23:59:59 -- -r > /var/spool/actividad/memoria.data
57 23 * * * root command -v sadf > /dev/null && sadf -d -s 00:00:00 -e 23:59:59 -- -F MOUNT > /var/spool/actividad/disco.data
58 23 * * * root command -v sadf > /dev/null && sadf -d -s 00:00:00 -e 23:59:59 -- -n DEV > /var/spool/actividad/trafico.data

# Additional run at 23:59 to rotate the statistics file
59 23 * * * root command -v debian-sa1 > /dev/null && debian-sa1 60 2
