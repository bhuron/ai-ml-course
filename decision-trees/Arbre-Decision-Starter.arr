use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/", "libraries/ai-library.arr")

import csv as csv

# ══════════════════════════════════════════════════════════════════════════════
# ARBRE DE DÉCISION — FICHIER DE DÉMARRAGE (FRANÇAIS)
# ══════════════════════════════════════════════════════════════════════════════
#
# Adapté de Bootstrap World (Fall 2026) — Leçon « Building Decision Trees »
# Licence : Creative Commons 4.0 Unported (Bootstrap Community).
#
# Les données (15 animaux d'entraînement + 15 de test) sont chargées depuis
# des fichiers CSV hébergés sur le dépôt GitHub du projet. La bibliothèque
# `ai-library.arr` de Bootstrap (qui fournit `classify`, `image-dot-plot`,
# etc.) est chargée via `use context url-file(...)` comme dans l'original.
#
# Colonnes (noms français) : nom, espece, sexe, poids, queue, mammifere, nage
# Espèces (en français)    : chat, chien, lezard, escargot, tarentule, lapin
# ══════════════════════════════════════════════════════════════════════════════

TRAINING-URL = "https://raw.githubusercontent.com/bhuron/ai-ml-course/master/decision-trees/dictionaries/training-fr.csv"
TESTING-URL  = "https://raw.githubusercontent.com/bhuron/ai-ml-course/master/decision-trees/dictionaries/testing-fr.csv"

training =
  load-table: nom :: String, espece :: String, sexe :: String,
              poids :: Number, queue :: Boolean, mammifere :: Boolean, nage :: Boolean
    source: csv.csv-table-url(TRAINING-URL, { header-row: true, infer-content: true })
  end

testing =
  load-table: nom :: String, espece :: String, sexe :: String,
              poids :: Number, queue :: Boolean, mammifere :: Boolean, nage :: Boolean
    source: csv.csv-table-url(TESTING-URL, { header-row: true, infer-content: true })
  end

#####################################################################
# définir firepaw comme la première ligne de la table
firepaw = row-n(training, 0)

# définir frisky comme la sixième ligne de la table
frisky = row-n(training, 5)

#####################################################################
# classifieur-queue :: Row -> String
# consomme un animal, et prédit l'espèce
fun classifieur-queue(r):
  if r["queue"] == true:
    "chat"
  else:
    "escargot"
  end
end

# Vous pouvez tester n'importe quel classifieur avec la fonction `classify`
# classify(testing, "espece", classifieur-queue)

#####################################################################
# animal-img :: Row -> Image
# étant donné une ligne de la table animals, produit un emoji de l'espèce

fun animal-img(r):
  if      (r["espece"] == "chien"):      text("🐶", 20, "black")
  else if (r["espece"] == "chat"):       text("😺", 20, "black")
  else if (r["espece"] == "lezard"):     text("🦎", 20, "black")
  else if (r["espece"] == "lapin"):      text("🐇", 20, "black")
  else if (r["espece"] == "escargot"):   text("🐌", 20, "black")
  else if (r["espece"] == "tarentule"):  text("🕷️", 20, "black")
  end
end

# Utilisez animal-img pour faire un image-dot-plot
# image-dot-plot(training, "poids", animal-img)

#####################################################################
# Définissez d'autres fonctions classifieur !

# mon-classifieur1 :: Row -> String
# remplissez les `...` avec vos divisions et nœuds feuilles pour un arbre à un niveau !
fun mon-classifieur1(r):
  if r[...] == ... :
    ...
  else:
    ...
  end
end

# remplissez les `...` avec vos divisions et nœuds feuilles pour un arbre à deux niveaux !
fun mon-classifieur2(r):
  if r[...] == ... :
    if r[...] == ... :
      ...
    else:
      ...
    end

  else:
    if r[...] == ... :
      ...
    else:
      ...
    end
  end
end