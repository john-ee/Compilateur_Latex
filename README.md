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


pour lancer le mips :

```
spim -file output.s
```


##A LIRE AVANT D'EXECUTER  

**Attention** il se peut que le fichier **texcc.c** s'efface à la suite de la commande **make**, pour éviter le problème il faut d'abord ouvrir le fichier texcc.c en prévision d'un ctrl+z sur celui-ci avant de retenter la compilation 

**Erreur** de compilation dans le mips quand les variables b,j sont utilisées 

Respecter l'ordre des déclarations pour éviter les erreurs (toujours Constant, input, output, global, local) 

lien du code : https://github.com/john-ee/Compilateur_Latex