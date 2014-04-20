BashCreateProject
=================

Un script bash qui me permet de créer un nouveau projet web en créant directement tous les fichiers de configuration Apache / Nginx et dossiers nécessaires.

##Comment ça marche ?
Idéalement, le mettre dans un des répertoires du PATH, moi j'ai choisi /usr/local/bin. Ensuite, faire un ```chmod -x newsite.sh``` pour le rendre exécutable.

Ensuite, il n'y a qu'à l'appeler :
```Shell
newsite.sh
```

S'il n'y a pas de paramètres, il demandera ceux qui lui sont nécessaires.

###Syntaxe complète
```Shell
newsite.sh <nom du projet> <extension du site> <sous-dossier (optionnel)>
```
