use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/ai", "../libraries/self-driving-car-library.arr")

# Ce fichier inclut trois fonctions :
# Dans les deux fonctions d'entraînement, le Number est la *vitesse d'animation*.
# Plus la valeur est élevée, plus c'est rapide !

#  démarre un simulateur de conduite en « vue du dessus » (vue d'en haut),
#  pour entraîner votre modèle
#  train-bev :: Number -> Table

#  démarre un simulateur de conduite « point de vue » (vue à travers le pare-brise),
#  pour entraîner votre modèle
#  train-pov :: Number -> Table

#  utilise un modèle pour conduire la voiture
#  drive :: Driving-Function -> Table

# training est une table prédéfinie de données d'entraînement de haute qualité


#######################################################################
# Modèle
fun pred-c(curve): (...  * curve ) + ... end

# Modèles entraînés à partir de curve, skew, offset, speed et steering-angle
# regression-model-code(training, [list: "curve"], "steering-angle")