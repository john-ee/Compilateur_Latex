# Compilateur_Latex

##Fonctionnalités disponibles

	- Gestion des chaines de caractères

	- Gestion des déclarations vides (emptyset)

	- Gestion des expressions arithmétiques (addition, soustraction, multiplication)


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

./texcc chemin_du_fichier_à_executer

exemple : 
```
./texcc texsci_exemples/tex/05_arithmetic_simple.tex
```
##Bug 

**Attention** il se peut que le fichier **texcc.c** s'efface à la suite de la commande make, pour résoudre le problème il faut faire un ctrl+z sur ce fichier et retenter la compilation 
