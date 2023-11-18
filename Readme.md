# Bureau d'Etude: Résolution numérique d'une équation aux dérivées partielles d'advection-diffusion par une méthode semi-implicite 

Ce projet est composé de deux répertoires distincts ainsi que de script *shell* simplifiant le traitement des données.

## Liste des fichiers

| CODE_IMPLICITE_GAUSS | PROG_EXP_F90         | Autre               |
| -------------------- | ---------------------| --------------------|
| calc_matriciel.f90   | VTSWriter.f90        | .gitignore          |
| data.txt             | data.txt             | clean.sh            |
| m_type.f90           | m_type.f90           | Readme.md           |
| main.f90             | main.f90             | script.sh           |
| Makefile             | Makefile             | analyse.py          |
| subroutines.f90      | subroutines.f90      | script_BE.py        |
| VTSWriter.f90        |                      | script_explicite.sh |


## Comment faire tourner le code

### Méthode 1
- Se placer dans le répertoire parent **BE_EDP_FORTRAN** (en dézippant le dossier rendu, ou à l'aide de "git clone" : ``` git clone https://github.com/GregHsr/BE_EDP_Fortran ``` pour télécharger tous les fichiers dans le répertoire courant, attention de se placer dans la branche '''main''').
- Dans un terminal, autoriser le lancement du script de lancement : ``` chmod +x ./script.sh ``` (à ne faire qu'une fois) pour exécuter le résolution semi-implicite et ``` chmod +x ./script_explicite.sh ``` pour la résolution explicite
- Lancer le script : ```./script.sh ``` ou  ```./script_execution.sh ```

### Méthode 2

Un script a été rédigé pour tester différents paramètres automatiquement. Pour cela, il faut que les scripts de la *Méthode 1* soient opérationnels (il faut autoriser le lancement) et exécuter le programme ```script_BE.py```

### Méthode 3
- Se placer dans de répertoire **CODE_IMPLICITE_GAUSS** (version implicite) ou **PROG_EXP_F90** (version explicite)
- Dans un terminal, écrire  ``` make ```
- Puis lancer l'éxécutable : ``` ./prog.exe ```

### Supprimer tous les fichiers temporaires 
- Dans le répertoire parent, autoriser le lancement du script de nettoyage : ``` chmod +x ./clean.sh ``` (à ne faire qu'une fois)
- Lancer le script : ```./clean.sh ```

