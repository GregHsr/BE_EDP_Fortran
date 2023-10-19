import subprocess
import re

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
    else:
        print("Le temps d'exécution n'a pas été trouvé dans la sortie d'erreur.")
else:
    # Affiche les erreurs si la commande a échoué
    print("La commande Bash a échoué. Erreurs :")
    print(result.stderr)


