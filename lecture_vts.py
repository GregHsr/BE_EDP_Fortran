import os
import matplotlib.pyplot as plt
import numpy as np

"""
Ce code permet de lire dnas les fichiers vts le champ de température 
et de tracer le profil associé.

Il est configuré ici pour 4 fichiers différents. 

Attention à associer la bonne liste des coordonnées y_irreg lignes 49-50
"""

# Lecture fichier vts 
data1 = open('R05.vts', 'r')
lines1 = data1.readlines()
data1.close()

data2 = open('R5.vts', 'r')
lines2 = data2.readlines()
data2.close()

data3 = open('R50.vts', 'r')
lines3 = data3.readlines()
data3.close()

data4 = open('R500.vts', 'r')
lines4 = data4.readlines()
data4.close()

temp1 = [[0 for k in range(30)] for l in range(10)]
temp2 = [[0 for k in range(30)] for l in range(10)]
temp3 = [[0 for k in range(30)] for l in range(10)]
temp4 = [[0 for k in range(30)] for l in range(10)]

for i in range(10):
    for j in range(30):
        temp1[i][j] = float(lines1[20+i].split(' ')[j])
        temp2[i][j] = float(lines2[20+i].split(' ')[j])
        temp3[i][j] = float(lines3[20+i].split(' ')[j])
        temp4[i][j] = float(lines4[20+i].split(' ')[j])

# Liste du profil de tempréture en sortie
pro1 = [temp1[k][-1] for k in range(10)]
pro2 = [temp2[k][-1] for k in range(10)]
pro3 = [temp3[k][-1] for k in range(10)]
pro4 = [temp4[k][-1] for k in range(10)]

y = np.linspace(0, 250*10**(-6), 10)
y_irreg = [250*10**(-6)*(1-np.cos(np.pi*y[i]/(2*250*10**(-6)))) for i in range(10)]

print(max([abs(pro1[i]-pro2[i])/pro1[i] for i in range(len(pro1))]))

plt.figure(1)
plt.plot(y_irreg,pro1, 'o--', label="R=0.5")
plt.plot(y_irreg,pro2, 'o--', label="R=5")
plt.plot(y_irreg,pro3, 'o--', label="R=50")
plt.plot(y_irreg,pro4, 'o--', label="R=500")
plt.legend()
plt.ylabel("Température [°C]")
plt.xlabel("Position [m]")
plt.show()
