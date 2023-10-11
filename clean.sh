#!/bin/bash

# Se déplacer dans le répertoire CODE_IMPLICITE_GAUSS
cd CODE_IMPLICITE_GAUSS

# Supprimer les solutions précédentes
rm sol*

# Exécuter la commande "make clean"
make clean

# Idem dans le répertoire PROG_EXP_F90

cd ../PROG_EXP_F90
rm sol*
make clean