#!/bin/bash

# Se déplacer dans le répertoire CODE_IMPLICITE_GAUSS
cd CODE_IMPLICITE_GAUSS

# Supprimer les solutions précédentes
rm sol*

# Exécuter la commande "make clean"
make clean

# Exécuter le nouveau script 

make
./prog.exe