#!/bin/bash

#########################################################################################
#											#
# Programm ausführen:									#
# -------------------									#
# root: chmod +x ./RPI-vHost.sh								#
# root: ./RPI-vHost.sh									#
#											#
# Zusätzliche Informationen:								#
# --------------------------								#
# Autor	: Tom Baumbach									#
# GitHub: https://github.com/Funkahdafi							#
#											#
# RPI-vHost.sh wurde für Rasbian 8 / Debian 8 entwickelt und ist OpenSource.		#
# Für andere Linux-Distributionen sind eventuell Anpassungen im Skript notwendig.	#
#											#
# Für Schäden, die durch diese Software entstehen können, übernehme ich keine Haftung.	#
#											#
#########################################################################################

clear;												#Bildschirm löschen

#START KONFIGURATION

apache_dir=/etc/apache2										#Apache2 Installationspfad

html_dir=/var/www/html										#Apache2 DocumentRoot für Ihren vHost.

index_file=index.html										#Index-Datei: .htm, .html, .php, .php5

serveradmin_mail=mail@example.com								#E-Mail Serveradmin

domain=localhost										#Auf welcher Domain soll der vHost laufen ?

#ENDE KONFIGURATION

if [[ $EUID != 0 ]];										#Check: Root
then
	echo "";
	echo -e "\e[41mBitte führen Sie das Script als Root aus !\e[49m";
	echo "";
	exit
fi

function vhost_welcome(){
	echo "";
        echo "	+---------------------------------------------------------------+";
        echo "	|	Willkommen bei RPI-vHost - Apache2 vHost Generator.	|";
	echo "	|		https://github.com/Funkahdafi			|";
        echo "	+---------------------------------------------------------------+";
        echo "";
	}

while true
do

	vhost_welcome

PS3='Auswahl: '
options=("vHost anlegen" "vHost löschen" "vHost-Liste" "Beenden")
select opt in "${options[@]}"
do
	case $opt in
		"vHost anlegen")

if ! dpkg-query -s apache2 2>/dev/null|grep -q installed;						#Check: Apache2
then
	echo -e "\e[41mApache2 ist nicht installiert!\e[49m";
	echo "Das Programm wird beendet! Bitte installieren Sie Apache2.";
	echo "";
	exit
else

if [ ! -d $apache_dir/logs ];									#Check: Apache2 log
then
	mkdir $apache_dir/logs;
else

function vhost_hinzufuegen(){									#vhost_hinzufügen ANFANG
        echo "";
	echo "Die Installation von vHost $vhostname beginnt.";
        echo "Dieser Vorgang kann einige Sekunden in Anspruch nehmen.";
	echo "";
        sleep 1
        mkdir $html_dir/$vhostname;
        echo -e "[ \033[32mok\033[0m ] $html_dir/$vhostname wurde angelegt.";
        sleep 1
        chmod 755 $html_dir/$vhostname;
        chown www-data:www-data $html_dir/$vhostname;
        echo -e "[ \033[32mok\033[0m ] Schreibrecht für $html_dir/$vhostname gesetzt.";
        sleep 1
        touch $html_dir/$vhostname/$index_file;
        echo -e "[ \033[32mok\033[0m ] $index_file wurde angelegt.";
        sleep 1
        chmod 644 $html_dir/$vhostname/$index_file;
        chown www-data:www-data $html_dir/$vhostname/$index_file;
        sleep 1
        touch $apache_dir/sites-available/$vhostname.conf;
        sleep 1
        echo "<VirtualHost  *:80>" >> $apache_dir/sites-available/$vhostname.conf;
        echo "  ServerAdmin $serveradmin_mail" >> $apache_dir/sites-available/$vhostname.conf;
        echo "  DocumentRoot $html_dir/$vhostname" >> $apache_dir/sites-available/$vhostname.conf;
        echo "  ServerName $vhostname.$domain" >> $apache_dir/sites-available/$vhostname.conf;
        echo "  ErrorLog logs/$vhostname.error_log" >> $apache_dir/sites-available/$vhostname.conf;
        echo "  CustomLog logs/$vhostname.access_log common" >> $apache_dir/sites-available/$vhostname.conf;
        echo "</VirtualHost>" >> $apache_dir/sites-available/$vhostname.conf;
        sleep 1
        echo -e "[ \033[32mok\033[0m ] $vhostname.conf wurde erfolgreich angelegt und wird aktiviert.";
        sleep 1
        a2ensite $vhostname.conf > /dev/null;
        sleep 1
	echo "";
        echo "Apache2 wird neugestartet.";
	echo "";
        sleep 1
        /etc/init.d/apache2 reload > /dev/null;
        sleep 3
	echo "<br>" >> $html_dir/$vhostname/$index_file;
        echo "<center><h2>Ihr vHost: <font color=green>$vhostname</font> wurde erfolgreich in $html_dir angelegt.</h2></center>" >> $html_dir/$vhostname/$index_file;
	echo "<center><h3>http://$vhostname.$domain</center></h3>" >> $html_dir/$vhostname/$index_file;
	echo "<br><br>" >> $html_dir/$vhostname/$index_file;
	echo "<center><a href=https://github.com/Funkahdafi/RPI-vHost target=_blank>RPI-vHost@GitHub</a></center>" >> $html_dir/$vhostname/$index_file;
	echo -e "[ \033[32mok\033[0m ] Ihr vHost ist unter \033[32mhttp://$vhostname.$domain\033[0m erreichbar.";
	echo "";
        echo "Vielen Dank, wir sind fertig :-))";
	echo "";
	echo "Weiteren vHost hinzufügen  j/n?";
	echo "";
	read -p "Eingabe: " antwort
	if [[ $antwort = "j" && ! -z $antwort ]];
then
	vhost_eintragen
else
	if [[ $antwort = "n" && ! -z $antwort ]];
then
        echo "";
        echo "Zurück zum Hauptmenü";
        echo "";
        sleep 1
	clear;
	break
else
  	echo "";
        echo "Ungültige Auswahl. Bitte probieren Sie es erneut.";
        echo "";
        vhost_eintragen
fi
fi
}												#vhost_hinzufügen ENDE

function vhost_eintragen(){									#vhost_eintragen ANFANG
	echo "";
	echo "Bitte geben Sie einen Hostnamen an.";
	read -p "Eingabe: " hostname

if [[ -z $hostname ]];
then
	echo "";
	echo "Sie haben keinen Hostnamen eingegeben.";
	echo "Bitte versuchen Sie es erneut.";
	echo "";
	vhost_eintragen
else
	vhostname=$(echo $hostname | tr '[A-Z]' '[a-z]' | tr -d " ");				#Eingabe to lower

if [[ ! -e $apache_dir/sites-available/$vhostname.conf && ! -d $html_dir/$vhostname ]];		#Check: *.conf & dir
then
	echo "";
	echo -e "[ \033[32mok\033[0m ] $apache_dir/sites-available/$vhostname.conf ist frei.";
	echo -e "[ \033[32mok\033[0m ] $html_dir/$vhostname ist frei.";
	vhost_hinzufuegen
else
	echo "";
	echo -e "Achtung: \e[41mvHostname $vhostname kann nicht vergeben werden.\e[49m";
	echo "Grund: Es gibt diesen vHost schon, oder ein gleichnamiges HTML-Verzeichnis.";
	echo "";
	echo "Wollen Sie einen neuen Hostnamen wählen? j/n";
	read -p "Eingabe: " antwort
	if [[ $antwort = "j" && ! -z $antwort ]];
then
	vhost_eintragen
else
	if [[ $antwort = "n" && ! -z $antwort ]];
then
	echo "";
	echo "Zurück zum Hauptmenü.";
	echo "";
	sleep 1
	clear;
	break
else
	echo "";
	echo "Ungültige Auswahl. Bitte probieren Sie es erneut.";
	echo "";
	vhost_eintragen
fi
fi
fi
fi

}
												#vhost_eintragen ENDE
	vhost_eintragen

fi
fi
	break
	;;
	"vHost löschen")
function vhost_loeschen(){
	echo "";
	echo "Welchen vHost wollen Sie löschen ?";
	echo "";
	sleep 0.3
 	ls -1 $apache_dir/sites-available | grep conf | cut -d. -f1
	echo "";
	read -p "Hostname: " antwort_vhost_name
	vhost_name=$(echo $antwort_vhost_name | tr '[A-Z]' '[a-z]' | tr -d " ");
	echo "";

if [[ -z $vhost_name || (! -f $apache_dir/sites-available/$vhost_name.conf && ! -f $apache_dir/sites-enabled/$vhost_name.conf) ]];
then
       	echo "";
       	echo "Sie haben keinen bzw. einen ungültigen Hostnamen eingegeben.";
       	echo "Bitte versuchen Sie es erneut.";
       	echo "";
	vhost_loeschen
else

if [[ -f $apache_dir/sites-available/$vhost_name.conf && -f $apache_dir/sites-enabled/$vhost_name.conf ]];
then

	if [[ $vhost_name = "000-default" || $vhost_name = "000-default-le-ssl" || $vhost_name = "default-ssl" ]];
	then
	echo "Standard-vHost $vhost_name löschen ist nicht erlaubt!";
	echo "";
	vhost_loeschen
else
	echo "vHost $vhost_name wird gelöscht.";
	echo "Dieser Vorgang kann einige Sekunden in Anspruch nehmen.";
	echo "";
	sleep 1
	a2dissite $vhost_name > /dev/null;
	rm $apache_dir/sites-available/$vhost_name.conf
	echo -e "[ \033[32mok\033[0m ] $vhost_name wurde gelöscht.";
	sleep 1
	/etc/init.d/apache2 reload > /dev/null;
	echo -e "[ \033[32mok\033[0m ] Apache2 wurde neugestartet.";
	echo "";
	echo "Weiteren vHost löschen ? j/n"
	read -p "Eingabe: " antwort
if [[ $antwort = "j" && ! -z $antwort ]];
then
	vhost_loeschen
else

if [[ $antwort = "n" && ! -z $antwort ]];
then
	echo "";
        echo "Zurück zum Hauptmenü.";
        echo "";
        sleep 1
        clear;
        break
else
        echo "Ungültige Auswahl. Bitte probieren Sie es erneut.";
        echo "";
        vhost_loeschen
fi
fi
fi
fi
fi
}
	vhost_loeschen
	;;
	"vHost-Liste")
        echo "";
        echo "Liste der virtuellen Hosts auf diesem System:";
        echo "";
        ls -1 $apache_dir/sites-available | grep conf | cut -d. -f1
        echo "";

function pause(){
	read -p "$*"
}

	pause '[Enter] drücken für Hauptmenü...'
	clear;
        break
        ;;
	"Beenden")
	echo "";
	echo "RPI-vHost wird beendet. Auf Wiedersehen !";
	sleep 1
	exit
	;;
	*)
	echo "";
	echo "Ungültige Auswahl. Bitte probieren Sie es erneut.";
	echo "";
	sleep 1
	clear;
	break
	;;
	esac
done
done
