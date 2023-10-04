#!/bin/bash

# Supprimer les solutions précédentes
rm sol*

# Exécuter la commande "make clean"
make clean

# Exécuter le nouveau script 

make
./prog.exe