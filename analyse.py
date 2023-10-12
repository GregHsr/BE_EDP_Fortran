import os

# Modifer data.txt

R = [0.5,5,50]

fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "r")
data = fichier.readlines()
data2 = data
fichier.close()


for i in range(len(data)):
    data[i] = data[i].replace(",", ".")
    data[i] = data[i].replace(":", "")
    line = data[i].split()
    if i == len(data)-1:
        iteration = int(line[0])
        print(iteration)

if iteration == 0: 
    fichier = open("./CODE_IMPLICITE_GAUSS/.data2.txt", "w")
    for i in range(len(data2)):
        fichier.write(data2[i])
    fichier.close()

if iteration < 3:
    print("iteration = ", iteration)
    fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "w")
    for i in range(len(data)):
        if i == 12:
            fichier.write(str(R[iteration])+" !")
        if i == 16:
            fichier.write(str(iteration+1))
        else:
            fichier.write(data[i])

    fichier.close()

# Give back the original data.txt

else:
    fichier = open("./CODE_IMPLICITE_GAUSS/.data2.txt", "r")
    data = fichier.readlines()
    fichier.close()
    fichier = open("./CODE_IMPLICITE_GAUSS/data.txt", "w")
    for i in range(len(data)):
        fichier.write(data[i])
    fichier.close()

