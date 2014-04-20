BashCreateProject
=================

Un script bash qui me permet de créer un nouveau projet web en créant directement tous les fichiers de configuration Apache / Nginx et dossiers nécessaires.

##Ça fait quoi ?
- Crée un dossier pour les logs apache dans ```/var/log/apache2/``` (Parce que je regroupe mes logs par domaines)
- Crée un dossier pour le site dans ```/var/www/```, avec un dossier parent optionnel
- Crée un fichier de configuration Apache dans ```/etc/apache2/sites-available/``` et le rempli avec une configuration de base avec les informations disponibles (nom du site, extension, etc)
- Fais la même chose pour Nginx dans ```/etc/nginx/sites-available/```
- Active les nouveaux fichiers de configuration dans Apache et Nginx
- Relance Apache et Nginx

C'est évidemment très spécifique à ma configuration.

##Comment ça marche ?
Idéalement, le mettre dans un des répertoires du PATH, moi j'ai choisi ```/usr/local/bin```. Ensuite, faire un ```chmod +x newsite.sh``` pour le rendre exécutable.

Ensuite, il n'y a qu'à l'appeler :
```Shell
newsite.sh
```

S'il n'y a pas de paramètres, il demandera ceux qui lui sont nécessaires.

###Syntaxe complète
```Shell
newsite.sh <nom du projet> <extension du site> <sous-dossier (optionnel)>
```

## Vous !
Vous avez le droit de reprendre ce script à votre sauce, de l'adapter comme bon vous semble, etc. N'hésitez pas à me faire part d'idées d'amélioration ou autre.
