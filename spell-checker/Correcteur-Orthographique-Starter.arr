use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/ai", "../libraries/spell-checker-library.arr")

# ═══════════════════════════════════════════════════════════════════════════════
# CORRECTEUR ORTHOGRAPHIQUE — FICHIER DE DÉMARRAGE (ADAPTATION FRANÇAISE)
# ═══════════════════════════════════════════════════════════════════════════════

# Ce fichier contient plusieurs dictionnaires français de tailles différentes :
# `WORDS-XS-FR` — 100 mots de 5 lettres (dictionnaire minimal)
# `WORDS-S-FR`  — 5 000 mots français les plus courants
# `WORDS-M-FR`  — 13 000 mots français courants
# `WORDS-L-FR`  — 40 000 mots français

# Les dictionnaires sont chargés depuis le dossier `dictionaries/`.
# Format : un mot par ligne (lettres minuscules, accents acceptés).

# ═══════════════════════════════════════════════════════════════════════════════
# OUTILS DE CORRECTION ORTHOGRAPHIQUE
# ═══════════════════════════════════════════════════════════════════════════════

# Trouve toutes les variantes en remplaçant UNE lettre (1 édition)
# subs("chein")    — remplace chaque lettre une par une par toutes les lettres de l'alphabet
#                   Exemple : chien, chian, choin, chein, etc.

# Trouve toutes les variantes en échangeant deux lettres adjacentes (1 édition)
# swaps("chein")   — échange chaque paire de lettres adjacentes
#                   Exemple : hcein, cehin, chien, chein

# Trouve toutes les variantes en insérant UNE lettre (1 édition)
# insertions("aboi") — insère chaque lettre de l'alphabet à chaque position
#                    Exemple : aaboi, baboi, ..., aboie, aboia, ...

# Trouve toutes les variantes en supprimant UNE lettre (1 édition)
# deletions("vossinage") — supprime chaque lettre une par une
#                        Exemple : ossinage, vssinage, vosinage, ...

# ═══════════════════════════════════════════════════════════════════════════════
# COMBINAISONS ET FILTRES
# ═══════════════════════════════════════════════════════════════════════════════

# Combine les fonctions pour générer des mots à plus d'une édition de distance
# swaps(swaps("chein"))
# deletions(subs(swaps("chein")))

# Ne garde que les mots qui existent dans le dictionnaire choisi
# only-real(subs("chein"), WORDS-XS-FR)
# only-real(insertions("aboi"), WORDS-L-FR)

# ═══════════════════════════════════════════════════════════════════════════════
# CORRECTION ORTHOGRAPHIQUE COMPLÈTE
# ═══════════════════════════════════════════════════════════════════════════════

# La fonction alt-words combine tous les outils ci-dessus, et plus encore !
# — elle recherche des mots jusqu'à la distance d'édition que vous voulez
# — en plus des échanges et substitutions, elle ajoute et supprime des lettres
# Exemple :
# alt-words("chein", WORDS-M-FR, 2)
# → trouve tous les mots réels à distance ≤ 2 de "chein"
