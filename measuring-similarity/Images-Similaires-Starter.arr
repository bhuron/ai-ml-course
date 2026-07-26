use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ai-library.arr")

# Définir quelques images simples
black-sq   = square(10, "solid", "black")
white-sq   = square(10, "solid", "white")
red-sq     = square(10, "solid", "red")
green-t    = triangle(15, "solid", "green")
big-red-sq = square(100, "solid", "red")
half-and-half = beside(white-sq, black-sq)

# pixels -> modèle
red-blue-tile = overlay(square(5, "solid", "blue"), square(10, "solid", "red"))
pixel = image-to-color-list(red-blue-tile)
pixel-dominant-rgb = dominant-rgb-colors(red-blue-tile)

# Importer quelques images - vous pouvez les remplacer par n'importe quelles images du Web !
lesson-folder = "https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/ai/mountain-imgs/"
img1 = image-url(lesson-folder + "adirondacks.png")
img2 = image-url(lesson-folder + "arizona-mountains.png")
img3 = image-url(lesson-folder + "bear-lake.png")
img4 = image-url(lesson-folder + "grassy-mountains.png")
img5 = image-url(lesson-folder + "nz-mountains.png")
img6 = image-url(lesson-folder + "snowy-mountains.png")
img7 = image-url(lesson-folder + "sunny-grass-mountains.png")
img8 = image-url(lesson-folder + "sunrise-mountains.png")
img9 = image-url(lesson-folder + "sunset-mountains.png")

mountains =   image-url(lesson-folder + "all-mountains.webp")

# Définir la table d'images
corpus =
  table: ID,          DOC,              LIKED, DISLIKED, TAGS
    row: "sun1",      scale(1/2, img1), false,   false,  ""
    row: "day1",      scale(1/2, img2), true,    false,  ""
    row: "day2",      scale(1/2, img3), false,   false,  ""
    row: "grass",     scale(1/2, img4), false,   false,  ""
    row: "snow1",     scale(1/2, img5), false,   false,  ""
    row: "snow2",     scale(1/2, img6), false,   false,  "water"
    row: "grass-sun", scale(1/2, img7), false,   false,  ""
    row: "sun2",      scale(1/2, img8), false,   false,  ""
    row: "sunset",    scale(1/2, img9), false,   false,  ""
    row: "red-blue",  red-blue-tile,    false,   true,   ""
    row: "red1",      red-sq,           false,   true,   ""
    row: "red2",      big-red-sq,       false,   true,   ""
  end

# Utiliser la colonne « DOC » pour calculer DOMINANT-RGB-COLORS, SYMMETRY, LUMINANCE, etc.
# et ajouter des colonnes à notre corpus d'images
computed-with-color-names = decorate-image-table(corpus, "DOC")

# Utiliser un résumé « sac de mots » pour remplacer la chaîne DOMINANT-RGB-COLORS
# par des colonnes qui comptent chaque mot
computed = add-bag-cols(computed-with-color-names, "DOMINANT-RGB-COLORS")

# Étant donné une Row, produire une image réduite de moitié
fun thumbnail(r):
  scale(1/2, r["DOC"])
end