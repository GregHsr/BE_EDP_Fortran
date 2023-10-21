import subprocess
import re
import os
import matplotlib.pyplot as plt
import numpy as np

# Valeurs à tester 
R = np.geomspace(0.3, 500, 20)
L_temps_execution = []

# lecture des données et sauvegarde
fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "r")
data = fichier.readlines()
data2 = data
fichier.close()

for k in range(len(R)):
    fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "w")
    for i in range(len(data)):
        if i == 12:
            fichier.write(str(R[k])+" !"+"\n")
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
            L_temps_execution.append(temps_execution_str)
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

# Analyse des résultats

for k in range(len(L_temps_execution)):
    temps = L_temps_execution[k].split("m")
    temps = float(temps[0])*60+float(temps[1][:-1])
    L_temps_execution[k] = temps

# Affichage des résultats
plt.figure(1)
plt.plot(R, L_temps_execution, 'o--')
plt.xlabel("Nombre de Fourier")
plt.ylabel("Temps d'exécution (s)")
plt.show()

# Sauvegarde des résultats dans un fichier csv
fichier = open("resultats.csv", "w")
fichier.write("R,temps_execution\n")
for k in range(len(L_temps_execution)):
    fichier.write(str(R[k])+","+str(L_temps_execution[k])+"\n")
fichier.close()


