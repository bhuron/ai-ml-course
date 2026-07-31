use context url-file("https://raw.githubusercontent.com/bhuron/ai-ml-course/master/generative-models/libraries", "ai-library-fr.arr")

# ══════════════════════════════════════════════════════════════════════════════
# MODÈLES GÉNÉRATIFS — FICHIER DE DÉMARRAGE (FRANÇAIS)
# ══════════════════════════════════════════════════════════════════════════════
#
# Adapté de Bootstrap World (Fall 2026) — Leçon « Generative Models »
# Licence : Creative Commons 4.0 Unported (Bootstrap Community).
#
# Dans la leçon originale, le corpus est la chanson enfantine anglaise
# « There Was an Old Lady Who Swallowed a Fly ». Nous utilisons son
# équivalent français : « Une vieille dame avala une mouche », dont la
# structure en vers répétitifs est identique (une mouche, puis une
# araignée, un oiseau, un chat…).
#
# NORMALISATION FRANÇAISE :
# Ce fichier charge une version française de la bibliothèque Bootstrap
# (ai-library-fr.arr, hébergée dans ce dépôt). La seule différence avec
# l'original est la normalisation du texte :
#   * massage-string conserve les lettres accentuées françaises (é, è, ê,
#     à, ç, etc.) au lieu de les supprimer ;
#   * les apostrophes sont remplacées par des espaces ("l'araignée"
#     devient "l araignée", ce qui traite l'article élidé "l'" comme un
#     mot séparé, comme "the" en anglais) ;
#   * les tirets sont supprimés ("peut-être" devient "peutêtre").
# Toutes les fonctions n-grammes (build-lang-model, generate-ngrams,
# completions, choose-completion, generate-from, next-word-probability)
# sont les fonctions ORIGINALES de Bootstrap, inchangées.
# ══════════════════════════════════════════════════════════════════════════════

# ══════════════════════════════════════════════════════════════════════════════
# CORPUS : « Une vieille dame avala une mouche »
# ══════════════════════════════════════════════════════════════════════════════
# Équivalent français de la chanson enfantine « There Was an Old Lady Who
# Swallowed a Fly ». La structure est identique : un titre, puis un refrain
# répété, chaque couplet ajoutant un animal de plus en plus grand.

corpus = ```
Une vieille dame avala une mouche

Une vieille dame avala une mouche,
Je ne sais pas pourquoi elle avala une mouche – peut-être qu'elle va mourir !

Une vieille dame avala une araignée
Qui gigotait et frétillait dans son ventre ;
Elle avala l'araignée pour attraper la mouche ;
Je ne sais pas pourquoi elle avala une mouche – peut-être qu'elle va mourir !

Une vieille dame avala un oiseau ;
Quelle absurdité d'avaler un oiseau !
Elle avala l'oiseau pour attraper l'araignée
Qui gigotait et frétillait dans son ventre,
Elle avala l'araignée pour attraper la mouche ;
Je ne sais pas pourquoi elle avala une mouche – peut-être qu'elle va mourir !

Une vieille dame avala un chat ;
Eh bien, figurez-vous, elle avala un chat !
Elle avala le chat pour attraper l'oiseau,
Elle avala l'oiseau pour attraper l'araignée
Qui gigotait et frétillait dans son ventre,
Elle avala l'araignée pour attraper la mouche ;
Je ne sais pas pourquoi elle avala une mouche – peut-être qu'elle va mourir !
```

# ─── Exemples à tester dans la Zone d'Interactions ───────────────────────────
# generate-ngrams(corpus, 1)
# m = build-lang-model(corpus)
# next-word-probability(m, "une", "mouche")
# completions(m, "une")
# choose-completion(m, "une", 2)
# generate-from(m, "une vieille")