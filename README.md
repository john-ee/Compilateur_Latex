# Compilateur_Latex

##Fonctionnalités disponibles

	- Gestion des chaines de caractères

	- Gestion des déclarations vides (emptyset)

	- Gestion des expressions arithmétiques (addition, soustraction, multiplication)

	- Retour de messages d'erreurs différents selon le type (syntaxe, lexicale, sémantique, autre)


##Fonctionnalités non disponibles

	- Gestion des boucles (for, while, if)

	- Gestion des tableaux 

	- Gestion d'une suite de fonctions 

##Lancement

Compiler le programme avec les commandes suivants :

```
make clean
make all
```
pour lancer le programme faire : 

```
./texcc chemin_du_fichier_à_executer
```

exemple : 
```
./texcc texsci_exemples/tex/05_arithmetic_simple.tex
```
##A LIRE AVANT D'EXECUTER  

**Attention** il se peut que le fichier **texcc.c** s'efface à la suite de la commande make, pour résoudre le problème il faut faire un ctrl+z sur ce fichier et retenter la compilation 

**Erreur** de compilation dans le mips quand les variables b,j sont utilisées 

Respecter l'ordre des déclarations pour éviter les erreurs (toujours Constant, input, output, global, local) 
