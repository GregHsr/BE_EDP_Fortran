import subprocess
import re
import os
import matplotlib.pyplot as plt
import numpy as np

"""
Ce code a pour vocation de mesurer le temps de calcul de la simulation numérique.
Il peut modifier un ou plusieurs paramètres du fichier data.txt.

Actuellement, il est configuré pour mesurer le temps de calcul en fonction du nombre de mailles (Ny)

Certaines parties peuvent être décommentées pour tester d'autres paramètres.
Attention, il est laissé dans cette configuration pour montrer comment il a été utilisé pour les tests.
Les autres configurations nécessitent beaucoup de temps de calcul. Il faut compter 5 min pour celle-ci.
"""

# Valeurs à tester 
#R = np.geomspace(0.5, 500, 2)
R = [0.8,5,50,500]
W = np.linspace(0.1, 1.9, 100)
R0 = np.geomspace(0.000001, 10, 100)
Ny = [5,7,10,12,15,20,23,25]

L_R_exp = []
L_temps_execution_imp_Gauss = []
L_temps_execution_imp_Sor = []
L_temps_execution_exp = []
L_temps_execution_W = []
L_temps_execution_R0 = []


# lecture des données et sauvegarde
fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "r")
data = fichier.readlines()
data2 = data
fichier.close()
fichier_resultats = open("resultats.csv", "w")

for k in range(len(Ny)):
    ### CODE SEMI-IMPLICITE ###
    # Choisir méthode de Gauss 
    if Ny[k] <= 15:  
        fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "w")
        for i in range(len(data)):
            #if i == 12:
            #    fichier.write(str(R[k])+" !"+"\n")
            if i == 15:
                fichier.write(str(0)+" !"+"\n")
            elif i == 0:
                fichier.write(str(2*Ny[k])+" !"+"\n")
            elif i == 1:
                fichier.write(str(Ny[k])+" !"+"\n")
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
        temps = L_temps_execution_imp_Gauss[k].split("m")
        temps = float(temps[0])*60+float(temps[1][:-1])
        L_temps_execution_imp_Gauss[k] = temps

    # Choisir méthode de SOR
    fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "w")
    for i in range(len(data)):
        #if i == 12:
        #    fichier.write(str(R[k])+" !"+"\n")
        if i== 0:
            fichier.write(str(2*Ny[k])+" !"+"\n")
        elif i == 1:
            fichier.write(str(Ny[k])+" !"+"\n")
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
    #if R[k] < 1:
    #    L_R_exp.append(R[k])
    #    # Commande Bash qui exécute le script_explicite.sh
    #    commande_bash = "./script_explicite.sh"
    #    result = subprocess.run(commande_bash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
#
    #    # Vérifie si la commande s'est exécutée avec succès (code de retour 0)
    #    if result.returncode == 0:
    #        # Recherche du motif du temps d'exécution dans la sortie d'erreur
    #        temps_execution = re.search(r'real\s+(\d+m[\d.]+s)', result.stderr)
#
    #        if temps_execution:
    #            # Récupère le temps d'exécution complet (y compris les minutes et les secondes)
    #            temps_execution_str = temps_execution.group(1)
    #            print("Temps d'exécution complet :", temps_execution_str)
    #            L_temps_execution_exp.append(temps_execution_str)
    #        else:
    #            print("Le temps d'exécution n'a pas été trouvé dans la sortie d'erreur.")
    #    else:
    #        # Affiche les erreurs si la commande a échoué
    #        print("La commande Bash a échoué. Erreurs :")
    #        print(result.stderr)

    ## Clean des fichiers temporaires
    #commande_bash = "./clean.sh"
    #subprocess.run(commande_bash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    ### SAUVEGARDE DES RESULTATS ###
    #if R[k] >= 1:
    #    # Données implicites
    #    temps = L_temps_execution_imp_Gauss[k].split("m")
    #    temps = float(temps[0])*60+float(temps[1][:-1])
    #    L_temps_execution_imp_Gauss[k] = temps
    #    temps = L_temps_execution_imp_Sor[k].split("m")
    #    temps = float(temps[0])*60+float(temps[1][:-1])
    #    L_temps_execution_imp_Sor[k] = temps
    #    fichier_resultats.write(str(R[k])+","+str(L_temps_execution_imp_Gauss[k])+","+str(L_temps_execution_imp_Sor[k])+","+str(None)+"\n")
    #else:
    #    # Données implicites
    #    temps = L_temps_execution_imp_Gauss[k].split("m")
    #    temps = float(temps[0])*60+float(temps[1][:-1])
    #    L_temps_execution_imp_Gauss[k] = temps
    #    temps = L_temps_execution_imp_Sor[k].split("m")
    #    temps = float(temps[0])*60+float(temps[1][:-1])
    #    L_temps_execution_imp_Sor[k] = temps
    #    # Données explicites
    #    temps = L_temps_execution_exp[k].split("m")
    #    temps = float(temps[0])*60+float(temps[1][:-1])
    #    L_temps_execution_exp[k] = temps
    #    fichier_resultats.write(str(R[k])+","+str(L_temps_execution_imp_Gauss[k])+","+str(L_temps_execution_imp_Sor[k])+","+str(L_temps_execution_exp[k])+"\n")

    # Test maillage

    temps = L_temps_execution_imp_Sor[k].split("m")
    temps = float(temps[0])*60+float(temps[1][:-1])
    L_temps_execution_imp_Sor[k] = temps

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
plt.plot([5,7,10,12,15], L_temps_execution_imp_Gauss, 'o--', label="Code implicite Gauss")
plt.plot(Ny, L_temps_execution_imp_Sor, 'o--', label="Code implicite SOR")
#plt.plot(L_R_exp, L_temps_execution_exp, 'o--', label="Code explicite")
plt.legend()
#plt.xscale("log")
plt.xlabel("Nombre de mailles (Ny)")
plt.ylabel("Temps d'exécution (s)")
plt.show()


#for k in range(len(R0)): # /!\ ou W
#    # Changer la valeur de W   
#    fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "w")
#    for i in range(len(data)):
#        if i == 16:   # Test R0
#        # if i == 17: # Test W
#            fichier.write(str(R0[k])+" !"+"\n")
#        else:
#            fichier.write(data[i])
#    fichier.close()
#
#    # Commande Bash qui exécute le script.sh
#    commande_bash = "./script.sh"
#
#    # Exécute la commande Bash et capture la sortie
#    result = subprocess.run(commande_bash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
#
#    # Vérifie si la commande s'est exécutée avec succès (code de retour 0)
#    if result.returncode == 0:
#        # Recherche du motif du temps d'exécution dans la sortie d'erreur
#        temps_execution = re.search(r'real\s+(\d+m[\d.]+s)', result.stderr)
#        if temps_execution:
#            # Récupère le temps d'exécution complet (y compris les minutes et les secondes)
#            temps_execution_str = temps_execution.group(1)
#            print("Temps d'exécution complet :", temps_execution_str)
#            L_temps_execution_R0.append(temps_execution_str) # Test R0
#
#            #L_temps_execution_W.append(temps_execution_str) # Test W
#        else:
#            print("Le temps d'exécution n'a pas été trouvé dans la sortie d'erreur.")
#    else:
#        # Affiche les erreurs si la commande a échoué
#        print("La commande Bash a échoué. Erreurs :")
#        print(result.stderr)
#
#
## Nettoyage des fichiers temporaires
#commande_bash = "./clean.sh"
#subprocess.run(commande_bash, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
#
#fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "w")
#for i in range(len(data2)):
#    fichier.write(data2[i])
#fichier.close()
#
## Affichage des résultats
##for k in range(len(W)):
#    # Test W
#    #temps = L_temps_execution_W[k].split("m")
#    #temps = float(temps[0])*60+float(temps[1][:-1])
#    #L_temps_execution_W[k] = temps
#
#for k in range(len(R0)):
#    # Test R0
#    temps = L_temps_execution_R0[k].split("m")
#    temps = float(temps[0])*60+float(temps[1][:-1])
#    L_temps_execution_R0[k] = temps
#
#print(R0)
#print(L_temps_execution_R0)
#
##plt.figure(2)
##plt.plot(W, L_temps_execution_W, 'o--')
##plt.xlabel("Valeur de W")
##plt.ylabel("Temps d'exécution (s)")
##plt.show()
#
#plt.figure(3)
#plt.plot(R0, L_temps_execution_R0, 'o--')
#plt.xlabel("Valeur de R0")
#plt.ylabel("Temps d'exécution (s)")
#plt.xscale("log")
#plt.show()

