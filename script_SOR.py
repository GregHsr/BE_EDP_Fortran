import subprocess
import re
import os
import matplotlib.pyplot as plt
import numpy as np

# Valeurs à tester 
R = np.geomspace(0.5, 500, 20)
W = np.linspace(0.1, 1.9, 50)
R0 = np.geomspace(0.0000001, 10, 15)
L_temps_execution_W = []
L_temps_execution_R0 = []

# Faire varier R0 et W en même temps

L_temps_execution_R0_W = [[0 for i in range(len(W))] for j in range(len(R0))]

# lecture des données et sauvegarde
fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "r")
data = fichier.readlines()
data2 = data
fichier.close()

for k in range(len(R0)): 
    for l in range(len(W)):
        fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "w")
        for i in range(len(data)):
            if i == 16:   # Test R0
                fichier.write(str(R0[k])+" !"+"\n")
            elif i == 17:   
                fichier.write(str(W[l])+" !"+"\n")
            else:
                fichier.write(data[i])
        fichier.close()

        # Commande Bash qui exécute le script.sh
        commande_bash = "./script.sh"

        # Exécute la commande Bash et capture la sortie
        result = subprocess.run(commande_bash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        # Vérifie si la commande s'est exécutée avec succès (code de retour 0)
        if result.returncode == 0:
            # Recherche du motif du temps d'exécution dans la sortie d'erreur
            temps_execution = re.search(r'real\s+(\d+m[\d.]+s)', result.stderr)
            if temps_execution:
                # Récupère le temps d'exécution complet (y compris les minutes et les secondes)
                temps_execution_str = temps_execution.group(1)
                print("Temps d'exécution complet :", temps_execution_str)
                L_temps_execution_R0_W[k][l]=temps_execution_str 
            else:
                print("Le temps d'exécution n'a pas été trouvé dans la sortie d'erreur.")
        else:
            # Affiche les erreurs si la commande a échoué
            print("La commande Bash a échoué. Erreurs :")
            print(result.stderr)


# Nettoyage des fichiers temporaires
commande_bash = "./clean.sh"
subprocess.run(commande_bash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "w")
for i in range(len(data2)):
    fichier.write(data2[i])
fichier.close()

print(L_temps_execution_R0_W)
for k in range(len(R0)):
    for l in range(len(W)):
        temps = L_temps_execution_R0_W[k][l].split("m")
        temps = float(temps[0])*60+float(temps[1][:-1])
        L_temps_execution_R0_W[k][l] = temps


plt.figure(1)
im = plt.imshow(L_temps_execution_R0_W,extent=[0.1, 1.9, 0.0001, 10],origin='lower', cmap='hot', interpolation='bilinear', aspect='auto')
cbar = plt.colorbar(im)
cbar.set_label('Temps d\'exécution (s)')
plt.xlabel("Valeur de W")
plt.ylabel("Valeur de R0")
plt.show()
