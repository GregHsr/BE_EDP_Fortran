import subprocess
import re
import os
import matplotlib.pyplot as plt
import numpy as np

# Valeurs à tester 
R = np.geomspace(0.5, 500, 20)
L_R_exp = []
L_temps_execution_imp_Gauss = []
L_temps_execution_imp_Sor = []
L_temps_execution_exp = []

# lecture des données et sauvegarde
fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "r")
data = fichier.readlines()
data2 = data
fichier.close()

# Sauvegarde des résultats dans un fichier csv
fichier_resultats = open("resultats.csv", "w")

for k in range(len(R)):
    ### CODE SEMI-IMPLICITE ###
    # Choisir méthode de Gauss   
    fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "w")
    for i in range(len(data)):
        if i == 12:
            fichier.write(str(R[k])+" !"+"\n")
        elif i == 15:
            fichier.write(str(0)+" !"+"\n")
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
            L_temps_execution_imp_Gauss.append(temps_execution_str)
        else:
            print("Le temps d'exécution n'a pas été trouvé dans la sortie d'erreur.")
    else:
        # Affiche les erreurs si la commande a échoué
        print("La commande Bash a échoué. Erreurs :")
        print(result.stderr)

    # Choisir méthode de SOR
    fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "w")
    for i in range(len(data)):
        if i == 12:
            fichier.write(str(R[k])+" !"+"\n")
        elif i == 15:
            fichier.write(str(1)+" !"+"\n")
        else:
            fichier.write(data[i])
    fichier.close()

    # Commande Bash qui supprime les fichiers temporaires et lance script.sh
    commande_bash = "./clean.sh"
    subprocess.run(commande_bash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
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
            L_temps_execution_imp_Sor.append(temps_execution_str)
        else:
            print("Le temps d'exécution n'a pas été trouvé dans la sortie d'erreur.")
    else:
        # Affiche les erreurs si la commande a échoué
        print("La commande Bash a échoué. Erreurs :")
        print(result.stderr)

    ### CODE EXPLICITE ###
    if R[k] < 1:
        L_R_exp.append(R[k])
        # Commande Bash qui exécute le script_explicite.sh
        commande_bash = "./script_explicite.sh"
        result = subprocess.run(commande_bash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        # Vérifie si la commande s'est exécutée avec succès (code de retour 0)
        if result.returncode == 0:
            # Recherche du motif du temps d'exécution dans la sortie d'erreur
            temps_execution = re.search(r'real\s+(\d+m[\d.]+s)', result.stderr)

            if temps_execution:
                # Récupère le temps d'exécution complet (y compris les minutes et les secondes)
                temps_execution_str = temps_execution.group(1)
                print("Temps d'exécution complet :", temps_execution_str)
                L_temps_execution_exp.append(temps_execution_str)
            else:
                print("Le temps d'exécution n'a pas été trouvé dans la sortie d'erreur.")
        else:
            # Affiche les erreurs si la commande a échoué
            print("La commande Bash a échoué. Erreurs :")
            print(result.stderr)

    # Clean des fichiers temporaires
    commande_bash = "./clean.sh"
    subprocess.run(commande_bash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    ### SAUVEGARDE DES RESULTATS ###
    if R[k] >= 1:
        # Données implicites
        temps = L_temps_execution_imp_Gauss[k].split("m")
        temps = float(temps[0])*60+float(temps[1][:-1])
        L_temps_execution_imp_Gauss[k] = temps
        temps = L_temps_execution_imp_Sor[k].split("m")
        temps = float(temps[0])*60+float(temps[1][:-1])
        L_temps_execution_imp_Sor[k] = temps
        fichier_resultats.write(str(R[k])+","+str(L_temps_execution_imp_Gauss[k])+","+str(L_temps_execution_imp_Sor[k])+","+str(None)+"\n")
    else:
        # Données implicites
        temps = L_temps_execution_imp_Gauss[k].split("m")
        temps = float(temps[0])*60+float(temps[1][:-1])
        L_temps_execution_imp_Gauss[k] = temps
        temps = L_temps_execution_imp_Sor[k].split("m")
        temps = float(temps[0])*60+float(temps[1][:-1])
        L_temps_execution_imp_Sor[k] = temps
        # Données explicites
        temps = L_temps_execution_exp[k].split("m")
        temps = float(temps[0])*60+float(temps[1][:-1])
        L_temps_execution_exp[k] = temps
        fichier_resultats.write(str(R[k])+","+str(L_temps_execution_imp_Gauss[k])+","+str(L_temps_execution_imp_Sor[k])+","+str(L_temps_execution_exp[k])+"\n")

        
# Nettoyage des fichiers temporaires
commande_bash = "./clean.sh"
subprocess.run(commande_bash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "w")
for i in range(len(data2)):
    fichier.write(data2[i])
fichier.close()
fichier_resultats.close()

# Affichage des résultats
plt.figure(1)
plt.plot(R, L_temps_execution_imp_Gauss, 'o--', label="Code implicite Gauss")
plt.plot(R, L_temps_execution_imp_Sor, 'o--', label="Code implicite SOR")
plt.plot(L_R_exp, L_temps_execution_exp, 'o--', label="Code explicite")
plt.legend()
plt.xscale("log")
plt.xlabel("Nombre de Fourier")
plt.ylabel("Temps d'exécution (s)")
plt.show()

