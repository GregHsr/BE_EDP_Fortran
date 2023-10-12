from paraview.simple import *

# Charger le fichier PVD ou VTS
data_file = "/chemin/vers/le/fichier.pvd"  # Remplacez par le chemin vers votre fichier PVD ou VTS
reader = XMLPartitionedUnstructuredGridReader(FileName=data_file)

# Créer une vue et ajuster les paramètres au besoin
view = CreateRenderView()
view.ViewSize = [800, 600]  # Ajustez la taille de la vue selon vos besoins

# Ajouter une représentation (par exemple, un contour)
contour = Contour(Input=reader)
contour.ContourBy = 'VotreVariable'  # Remplacez 'VotreVariable' par le nom de votre variable
contour.Isosurfaces = [0.5]  # Réglez les valeurs d'isovaleur selon vos besoins

# Ajouter une source de lumière (facultatif)
light = PointLight()
light.Position = [1, 1, 1]

# Réglez d'autres paramètres de visualisation au besoin (échelle, couleur, etc.)

# Mettez à jour la vue
view.ResetCamera()
view.Update()

# Spécifiez le nom du fichier d'image de sortie
output_file = "/chemin/vers/votre/image.png"

# Enregistrez l'image
WriteImage(output_file)

# Fermez Paraview
Disconnect()
