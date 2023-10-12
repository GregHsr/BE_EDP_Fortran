#!/bin/bash

for i in 1 2 3
do 
    python3 analyse.py
    # Se déplacer dans le répertoire CODE_IMPLICITE_GAUSS
    cd CODE_IMPLICITE_GAUSS
    # Supprimer les solutions précédentes
    rm sol*
    # Exécuter la commande "make clean"
    make clean
    # Exécuter le nouveau script 
    make
    time ./prog.exe
    cd ..
done 

python3 analyse.py
./clean.sh 