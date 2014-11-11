#!/bin/bash

## Création de tout le bazar de configuration Apache/Nginx
## Emmanuel B.
## 20/04/2014

## variables
nomProjet=$1
extension=$2
sousDossier=$3
apacheConf='/etc/apache2/sites-available'
nginxConf='/etc/apache2/sites-available'
www='/var/www'

if [ -z $sousDossier ]
then
	cheminComplet=$nomProjet
else
	cheminComplet=$sousDossier'/'$nomProjet
fi

# Vérification de projet
function VerifierNomProjet {
	# S'il n'ya a pas de nom, en demande un
	if [ -z $nomProjet ]
	then
		read -p "Entrez le nom du projet (pas d'espaces, maximum 30 caractères) : " -n 30 nomProjet

	# Si le projet existe déjà, demander un autre nom
	elif [ -f ../etc/apache2/sites-available/$nomProjet.$extension ]
	then
		echo "Ce nom de projet est déjà utilisé. Choisissez un nouveau nom (pas d'espaces, maximum 30 caractères) : " -n 30 nomProjet
		read -p "Entrez une extension de site web : " -n 4 extension
	fi

	# S'il n'y a pas d'extension, demander
	if [ -z $extension ]
	then
		read -p "Entrez une extension de site web : " -n 4 extension
	fi
}

# Créer le répertoire www
function CreerDossierWeb {
	mkdir -p  "/var/www/$cheminComplet/site"
}

#Créer le répertoire log
function CreerDossierLog {
	mkdir -p "/var/log/apache2/$nomProjet/"
}

# Créer le fichier de configuration Apache
function CreerFichierApache {
	# Créer le fichier
	local fichier=$apacheConf/$nomProjet

	# Écrire la configuration dans le fichier
	echo '<VirtualHost 127.0.0.1:8082>
	ServerName www.'$nomProjet'.'$extension'
	ServerAlias www.'$nomProjet'.'$extension'
	ServerAdmin contact@'$nomProjet'.'$extension'

	DocumentRoot '$www'/'$cheminComplet'/site

	ErrorLog ${APACHE_LOG_DIR}/'$nomProjet'/site_error.log
	CustomLog ${APACHE_LOG_DIR}/'$nomProjet'/site_access.log combined
</VirtualHost>

<VirtualHost 127.0.0.1:8082>
	ServerName '$nomProjet'.'$extension'
	ServerAlias '$nomProjet'.'$extension'

	Redirect permanent / http://www.'$nomProjet'.'$extension'/
</VirtualHost>' > $fichier

	# Activer le fichier dans la configuration Apache
	a2ensite $nomProjet

	#relancer Apache
	service apache2 restart
}

# Créer le fichier de configuration Nginx
function CreerFichierNginx {
	# Créer le fichier
	local fichier=$nginxConf/$nomProjet

	# Écrire la configuration dans le fichier
	echo 'server {
	listen	80;
	server_name	www.'$nomProjet'.'$extension';
	#access_log	/var/log/'$nomProjet'.access.log;
	#error_log	/var/log/'$nomProjet'.nginx_error.log info;

	access_log	off;

	location = /robots.txt	{ access_log off; log_not_found off; }
	location = /favicon.ico	{ access_log off; log_not_found off; }
	location / {
		proxy_pass http://127.0.0.1:8082/;
		include /etc/nginx/conf.d/proxy.conf;
		root '$www/$cheminComplet'/site;
	}

	location ~* ^.+.(jpg|jpeg|gif|css|png|js|ico|txt|srt|swf)$ {
		root '$www/$cheminComplet'/site/;
		expires 30d;
	}
}' > $fichier

	# Activer le fichier dans la configuration Nginx
	ln -s $nginxConf/$nomProjet $nginxConf/

	#relancer Nginx
	service nginx restart
}

# Installer WordPress
function InstallerWordpress {
	# Demander si l'utilisateur souhaite installer WordPress
	read -ep 'Installer WordPress ? (y/n) : '

	if [[ $REPLY == [yY] ]]; then
		WPURL='https://fr.wordpress.org/latest-fr_FR.tar.gz'

		echo 'Téléchargement de WordPress depuis $WPURL...'
		echo
		mkdir '/var/www/'$cheminComplet'/site/'
		curl '/var/www/'$cheminComplet'/site/' | tar -xz -C $www/$cheminComplet/site --strip 1
		RET=$?
		echo

		if [ $RET != 0 ]; then
			echo "*** ECHEC"
			revert
			exit 1
		fi

		echo "Permissions 644..."
		chmod -R 644 $www/$cheminComplet
		chmod -R g+X $www/$cheminComplet

		echo "Création d'un fichier .htaccess vide..."
		touch $www/$cheminComplet/.htaccess
		chmod g+w $www/$cheminComplet/.htaccess

		echo "Persmissions sur wp-content..."
		chmod -R g+w $www/$cheminComplet/wp-content

		echo "Suppression de plugin Hello Dolly"
		rm $www/$cheminComplet/wp-content/plugins/hello.php

		echo "Configuration de wp-config.php..."
		mv $www/$cheminComplet/wp-config-sample.php $www/$cheminComplet/wp-config.php

		LINESTART=$(grep -n "define('AUTH_KEY'" $www/$cheminComplet/wp-config.php | cut -d: -f1)
		LINEEND=$(echo "$SALT" | wc -l)
		LINEEND=$(($LINESTART + $LINEEND - 1))

		sed -i "${LINESTART},${LINEEND}d" $www/$cheminComplet/wp-config.php

		while read -r LINE; do
			sed -i "${LINESTART}i $LINE" $www/$cheminComplet/wp-config.php
			LINESTART=$(($LINESTART + 1))
		done <<< "$SALT"

		echo "Configurer FS_METHOD sur direct..."
		LINESTART=$(grep -n "define('WP_DEBUG'" $www/$cheminComplet/wp-config.php | cut -d: -f1)
		sed -i "${LINESTART}a define('FS_METHOD', 'direct');" $www/$cheminComplet/wp-config.php

		echo "Configuration de WP_HOME et WP_SITEURL.."
		sed -i "${LINESTART}a define('WP_HOME', 'http://' . \$_SERVER['HTTP_HOST']);" $www/$cheminComplet/wp-config.php
		sed -i "${LINESTART}a define('WP_SITEURL', 'http://' . \$_SERVER['HTTP_HOST']);" $www/$cheminComplet/wp-config.php
	fi

}

# Inifialiser la création
function CreerProjet {
	echo "Lancement de la création"

	# Vérifier que le nom soit bon
	VerifierNomProjet

	# Créer le dossier log
	echo "Création du dossier log"
	CreerDossierLog

	# Créer le dossier web
	echo "Création du dossier web"
	CreerDossierWeb

	# Créer fichier de configuration Apache
	echo "Création du fichier de configuration Apache"
	CreerFichierApache

	# Créer fichier de configuration Nginx
	echo "Création du fichier de configuration Nginx"
	CreerFichierNginx

	# Installer WordPress
	InstallerWordpress

	echo "C'est terminé !"
}

## INITIALISATION, BABY !
CreerProjet