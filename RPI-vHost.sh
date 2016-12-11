#!/bin/bash

#########################################################################################
#											#
# Author: Tom Baumbach									#
# GitHub: https://github.com/Funkahdafi							#
#											#
# RPI-vhost.sh wurde für Rasbian 8 entwickelt und ist OpenSource.			#
# Für andere Linux-Distributionen sind Anpassungen am Skript notwendig.			#
#											#
# Für Schäden, die durch diese Software entstehen können, übernehme ich keine Haftung.	#
#											#
#########################################################################################

clear;												#Bildschirm löschen

#START KONFIGURATION

apache_dir=/etc/apache2										#Apache2 Installationspfad

html_dir=/var/www/html										#Apache2 DocumentRoot, innerhalb dessen wird vhost angelegt.

index_file=index.html										#Index z.B.: *.htm, *.html, *.php, *.php5

server_admin_mail=mail@example.com								#E-Mail des Serveradmin

domain=localhost										#Auf welcher Domain soll der vhost laufen ?

#ENDE KONFIGURATION

if [[ $EUID != 0 ]];										#Script muss als Root ausgeführt werden !
then
	echo "";
	echo -e "\e[41mBitte führen Sie das Script als Root aus !\e[49m";
	echo "";
	exit
else
	echo "";
        echo "Willkommen beim Apache2 Virtual Host-Generator.";
        echo "";

if [ ! -d $apache_dir ];									#Ist Apache2 vorhanden ?
then
	echo -e "\e[41m$apache_dir ist nicht vorhanden!\e[49m";
	echo "Das Programm wird beendet! Bitte installieren Sie Apache2.";
	echo "";
	exit
else

if [ ! -d $apache_dir/logs ];									#Apache2 log prüfen
then
	sudo mkdir $apache_dir/logs;
else

function vhost_hinzufuegen(){									#Funktion vhost_hinzufügen ANFANG
        echo "";
	echo "Installation von $vhostname beginnt.";
        echo "Dieser Vorgang kann einige Sekunden in Anspruch nehmen.";
	echo "";
        sleep 1
        sudo mkdir $html_dir/$vhostname;
        echo "Status: $html_dir/$vhostname wurde angelegt.";
        sleep 1
        sudo chmod 755 $html_dir/$vhostname;
        sudo chown www-data:www-data $html_dir/$vhostname;
        echo "Status: Schreibrecht für $html_dir/$vhostname gesetzt.";
        sleep 1
        sudo touch $html_dir/$vhostname/$index_file;
        echo "Status: $index_file wurde angelegt.";
        sleep 1
        sudo chmod 644 $html_dir/$vhostname/$index_file;
        sudo chown www-data:www-data $html_dir/$vhostname/$index_file;
        sleep 1
        sudo touch $apache_dir/sites-available/$vhostname.conf;
        sleep 1
        echo "<VirtualHost  *:80>" >> $apache_dir/sites-available/$vhostname.conf;
        echo "  ServerAdmin $server_admin_mail" >> $apache_dir/sites-available/$vhostname.conf;
        echo "  DocumentRoot $html_dir/$vhostname" >> $apache_dir/sites-available/$vhostname.conf;
        echo "  ServerName $vhostname.$domain" >> $apache_dir/sites-available/$vhostname.conf;
        echo "  ErrorLog logs/$vhostname.error_log" >> $apache_dir/sites-available/$vhostname.conf;
        echo "  CustomLog logs/$vhostname.access_log common" >> $apache_dir/sites-available/$vhostname.conf;
        echo "</VirtualHost>" >> $apache_dir/sites-available/$vhostname.conf;
        sleep 1
        echo "Status: $vhostname.conf wurde erfolgreich angelegt und wird aktiviert.";
        sleep 1
        sudo a2ensite $vhostname.conf;
        sleep 1
        echo "Status: Apache2 wird neugestartet.";
	echo "";
        sleep 1
        sudo service apache2 reload;
        sleep 3
        echo "Ihr virtueller Host: $vhostname wurde erfolgreich in $html_dir angelegt." >> $html_dir/$vhostname/$index_file;
	echo -e "Ihr  vhost ist unter \033[32mhttp://$vhostname.$domain\033[0m erreichbar.";
	echo "";
        echo "Vielen Dank, wir sind fertig :-))";
	exit
}												#Funktion vhost_hinzufügen ENDE

function vhost_eintragen(){									#Funtion vhost_eintragen ANFANG
	echo "Bitte geben Sie einen neuen Hostnamen an:";
	read hostname
	vhostname=$(echo $hostname | tr '[A-Z]' '[a-z]');					#Eingabe to lower konvertieren

if [[ ! -e $apache_dir/sites-available/$vhostname.conf && ! -d $html_dir/$vhostname ]];		#Prüfung ob *.conf und directory vorhanden
then
	echo "";
	echo "$apache_dir/sites-available/$vhostname.conf ist frei.";
	echo "$html_dir/$vhostname ist frei.";
	vhost_hinzufuegen
else
	echo "";
	echo -e "Achtung: \e[41mvHostname $vhostname kann nicht vergeben werden.\e[49m !";
	echo "Grund: Es gibt diesen vhost schon oder ein gleichnamiges HTML-Verzeichnis.";
	echo "";
	echo "Wollen Sie einen neuen Hostnamen wählen? j/n";
	read antwort
	if [ $antwort = "j" ];
then
	vhost_eintragen
else
	if [ $antwort = "n" ];
	then
	echo "";
	echo "Auf Wiedersehen !";
	echo "";
	exit
else
	echo "";
	echo "Ungültige Auswahl, probieren Sie bitte es erneut.";
	echo "";
	vhost_eintragen
fi
fi
fi

}

	vhost_eintragen

fi
fi
fi

