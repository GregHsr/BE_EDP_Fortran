#!/bin/bash

# Se déplacer dans le répertoire CODE_IMPLICITE_GAUSS
cd PROG_EXP_F90 

# Supprimer les solutions précédentes
rm sol*

# Exécuter la commande "make clean"
make clean

# Exécuter le nouveau script

make
time ./prog.exe