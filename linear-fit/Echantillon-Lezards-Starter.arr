use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/data-science", "../libraries/core.arr")

import csv as csv

# ══════════════════════════════════════════════════════════════════════════════
# ÉCHANTILLON DE LÉZARDS — FICHIER DE DÉMARRAGE (FRANÇAIS)
# ══════════════════════════════════════════════════════════════════════════════
#
# Adapté de Bootstrap World (Fall 2026) — Leçon « Fitting Models »
# Licence : Creative Commons 4.0 Unported (Bootstrap Community).
#
# Les données (10 lézards) sont chargées depuis un fichier CSV hébergé sur
# le dépôt GitHub du projet. La bibliothèque `core.arr` de Bootstrap (qui
# fournit `scatter-plot`, `fit-model`, `dot-plot`, `box-plot`, etc.) est
# chargée via `use context url-file(...)` comme dans l'original.
#
# Colonnes (noms français) : nom, espece, sexe, age, sterilise, pattes, poids, semaines
# Espèce (en français)     : lezard
# ══════════════════════════════════════════════════════════════════════════════

LIZARD-URL = "https://raw.githubusercontent.com/bhuron/ai-ml-course/master/linear-fit/dictionaries/lizard-sample-fr.csv"

# Charger le fichier CSV comme une table
lizard-sample =
  load-table: nom :: String, espece :: String, sexe :: String,
              age :: Number, sterilise :: Boolean, pattes :: Number,
              poids :: Number, semaines :: Number
    source: csv.csv-table-url(LIZARD-URL, { header-row: true, infer-content: true })
  end


########################################################
# Définir quelques modèles

# Modèle de Cy~: prédit que semaines = -3 * poids + 23
fun cy(x): (-3 * x) + 23 end

# Modèle de Jo~: prédit que semaines = -0.8 * poids + 10.4
fun jo(x): (-0.8 * x) + 10.4 end

# Ajuster les modèles
# fit-model(lizard-sample, "nom", "poids", "semaines", cy)
# fit-model(lizard-sample, "nom", "poids", "semaines", jo)