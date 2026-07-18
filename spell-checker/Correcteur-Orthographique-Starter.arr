# ══════════════════════════════════════════════════════════════════════════════
# CORRECTEUR ORTHOGRAPHIQUE — FICHIER DE DÉMARRAGE (FRANÇAIS)
# ══════════════════════════════════════════════════════════════════════════════
#
# Adapté de Bootstrap World (Fall 2026) — Leçon « Data-Driven Algorithms »
#
# Ce fichier contient tout le nécessaire pour explorer la correction
# orthographique en français comme un algorithme piloté par les données.
#
# ══════════════════════════════════════════════════════════════════════════════

import lists as L

# ─── ALPHABET FRANÇAIS ───────────────────────────────────────────────────────

# Version complète : toutes les lettres accentuées du français
ALPHABET-FR = [list:
  "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
  "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  "à", "â", "é", "è", "ê", "ë", "î", "ï", "ô", "ö", "ù", "û", "ü",
  "ç", "æ", "œ"
]

# Version réduite pour les démos rapides
ALPHABET-FR-SIMPLE = [list:
  "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
  "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  "é", "è", "ê", "à", "ù", "ç"
]

# ══════════════════════════════════════════════════════════════════════════════
# FONCTIONS DE DISTANCE D'ÉDITION
# ══════════════════════════════════════════════════════════════════════════════

# ─── SUBSTITUTION ───────────────────────────────────────────────────────────
# Remplace chaque lettre du mot par toutes les lettres de l'alphabet.
# Pour un mot de n lettres et un alphabet de a lettres : n × a variantes.
# Exemple : subs("chian", ALPHABET-FR-SIMPLE) génère ..., "chien", ...

fun subs(word :: String, alphabet :: List<String>) -> List<String>:
  doc: "Remplace chaque lettre du mot par toutes les lettres de l'alphabet"
  for fold(acc from empty, i from range(0, string-length(word))):
    orig-letter = string-substring(word, i, i + 1)
    before = string-substring(word, 0, i)
    after = string-substring(word, i + 1, string-length(word))
    inner = for map(letter from alphabet):
      if letter == orig-letter:
        ""
      else:
        string-append(before, string-append(letter, after))
      end
    end
    L.append(acc, inner)
  end
end

# ─── ÉCHANGE (SWAP) ─────────────────────────────────────────────────────────
# Échange chaque paire de lettres adjacentes.
# Pour un mot de n lettres : n-1 variantes.
# Exemple : swaps("chein") génère ..., "chien", ...

fun swaps(word :: String) -> List<String>:
  doc: "Échange chaque paire de lettres adjacentes"
  for map(i from range(0, string-length(word) - 1)):
    c1 = string-substring(word, i, i + 1)
    c2 = string-substring(word, i + 1, i + 2)
    before = string-substring(word, 0, i)
    after = string-substring(word, i + 2, string-length(word))
    string-append(string-append(before, c2), string-append(c1, after))
  end
end

# ─── INSERTION ──────────────────────────────────────────────────────────────
# Insère chaque lettre de l'alphabet à chaque position possible.
# Pour un mot de n lettres et a lettres : (n+1) × a variantes.
# Exemple : insertions("aboi", ALPHABET-FR-SIMPLE) génère ..., "aboie", ...

fun insertions(word :: String, alphabet :: List<String>) -> List<String>:
  doc: "Insère chaque lettre de l'alphabet à chaque position"
  for fold(acc from empty, i from range(0, string-length(word) + 1)):
    before = string-substring(word, 0, i)
    after = string-substring(word, i, string-length(word))
    inner = for map(letter from alphabet):
      string-append(before, string-append(letter, after))
    end
    L.append(acc, inner)
  end
end

# ─── SUPPRESSION ────────────────────────────────────────────────────────────
# Supprime chaque lettre du mot, une par une.
# Pour un mot de n lettres : n variantes.
# Exemple : deletions("for") génère "fo", "fr", "or", ...

fun deletions(word :: String) -> List<String>:
  doc: "Supprime chaque lettre du mot, une par une"
  for map(i from range(0, string-length(word))):
    before = string-substring(word, 0, i)
    after = string-substring(word, i + 1, string-length(word))
    string-append(before, after)
  end
end

# ─── ONLY-REAL ──────────────────────────────────────────────────────────────
# Ne garde que les mots qui existent dans le dictionnaire.
# Supprime aussi les chaînes vides et les doublons.

fun only-real(words :: List<String>, dict :: List<String>) -> List<String>:
  doc: "Filtre pour ne garder que les mots présents dans le dictionnaire"
  clean = L.filter(lam(w): string-length(w) > 0 end, words)
  uniq = L.distinct(clean)
  L.filter(lam(w): L.member(dict, w) end, uniq)
end

# ─── ALT-WORDS ──────────────────────────────────────────────────────────────
# Trouve tous les mots du dictionnaire à distance d'édition ≤ edits.
#
# Paramètres :
#   word     — le mot à corriger (ex: "chein")
#   dict     — la liste de mots du dictionnaire (ex: WORDS-XS)
#   edits    — distance d'édition maximale (1, 2, 3 ou 4)
#   alphabet — l'alphabet à utiliser
#
# Exemples :
#   alt-words("chein", WORDS-XS, 1, ALPHABET-FR-SIMPLE)
#   alt-words("aboit", WORDS-XS, 2, ALPHABET-FR-SIMPLE)

fun alt-words(
    word :: String,
    dict :: List<String>,
    edits :: Number,
    alphabet :: List<String>
  ) -> List<String>:
  doc: "Trouve tous les mots du dictionnaire à distance ≤ edits"
  if edits <= 0:
    if L.member(dict, word): [list: word] else: empty end
  else:
    s = subs(word, alphabet)
    sw = swaps(word)
    ins = insertions(word, alphabet)
    dels = deletions(word)
    all-variants = L.append(L.append(s, sw), L.append(ins, dels))

    distance-1 = only-real(all-variants, dict)

    if edits == 1:
      distance-1
    else:
      distance-1-words = for fold(acc from empty, w from distance-1):
        deeper = alt-words(w, dict, edits - 1, alphabet)
        L.append(acc, deeper)
      end
      L.distinct(L.append(distance-1, distance-1-words))
    end
  end
end

# ══════════════════════════════════════════════════════════════════════════════
# DICTIONNAIRES FRANÇAIS
# ══════════════════════════════════════════════════════════════════════════════
#
# Dictionnaire minimal — 169 mots de 5 lettres (embarqué, toujours dispo)
WORDS-XS = [list:
  "abîme", "abord", "abris", "absent", "acheté", "actif", "adore", "aider",
  "aigle", "aimer", "aller", "amour", "appel", "arbre", "asile", "assez",
  "atome", "auber", "aussi", "autre", "avant", "avoir", "bague", "belle",
  "bêtes", "blanc", "bleue", "boire", "bonne", "bruit", "calme", "carte",
  "cause", "champ", "chant", "chaud", "chien", "choix", "coule", "court",
  "danse", "dette", "douce", "durer", "écart", "école", "écrit", "égale",
  "envie", "essai", "étude", "faire", "faute", "femme", "fleur", "force",
  "forme", "frais", "fruit", "garde", "geste", "glace", "grand", "haute",
  "homme", "idées", "jardin", "jeune", "jouer", "juger", "juste", "large",
  "libre", "linge", "livre", "longs", "louer", "lutte", "mains", "maman",
  "mange", "mardi", "masse", "mener", "mieux", "monde", "morte", "moule",
  "murer", "nager", "noble", "noire", "noter", "noyer", "objet", "ombre",
  "orage", "ordre", "oubli", "parle", "parti", "passe", "patte", "peine",
  "pense", "perte", "peuple", "pidre", "piste", "place", "plage", "plein",
  "pluie", "porte", "poser", "poule", "prend", "prête", "preux", "prive",
  "proie", "prose", "proue", "quête", "rêver", "rivée", "ronde", "rouge",
  "sable", "saint", "salle", "scène", "séché", "selon", "serré", "seule",
  "siège", "signe", "singe", "sorte", "souci", "sourd", "style", "suite",
  "table", "tâche", "terre", "tirer", "titre", "tombe", "trace", "train",
  "trame", "triste", "trois", "tuer", "usage", "vague", "valse", "venir",
  "vente", "verse", "vêtir", "vider", "ville", "vivre", "voile", "voler",
  "yeuse"
]

# ══════════════════════════════════════════════════════════════════════════════
# DICTIONNAIRES PLUS GRANDS
# ══════════════════════════════════════════════════════════════════════════════
#
# Pour utiliser un dictionnaire plus grand, hébergez les fichiers .arr
# du dossier dictionaries/ sur un serveur web public (par exemple GitHub)
# et décommentez la ligne correspondante ci-dessous.
#
# Format des URLs (si hébergé sur GitHub) :
#   https://raw.githubusercontent.com/<user>/<repo>/main/spell-checker/dictionaries/<fichier>
#
# Pour charger, remplacez WORDS-XS par le nom du dictionnaire voulu
# dans vos appels à alt-words().

# Dictionnaire small — 5 000 mots (chargement : ~1 seconde)
# include url-file("https://votre-serveur.com/dictionaries/WORDS-S-FR.arr")

# Dictionnaire medium — 13 000 mots (chargement : ~3 secondes)
# include url-file("https://votre-serveur.com/dictionaries/WORDS-M-FR.arr")

# Dictionnaire large — 40 000 mots (chargement : ~10 secondes)
# include url-file("https://votre-serveur.com/dictionaries/WORDS-L-FR.arr")

# ══════════════════════════════════════════════════════════════════════════════
# POUR COMMENCER
# ══════════════════════════════════════════════════════════════════════════════
#
# 1. Cliquez sur "Run" pour charger le programme.
#
# 2. Dans la Zone d'Interactions (à droite), essayez :
#
#    subs("chian", ALPHABET-FR-SIMPLE)
#    swaps("chein")
#    insertions("aboi", ALPHABET-FR-SIMPLE)
#    deletions("vossinage")
#
# 3. Puis testez le correcteur complet :
#
#    alt-words("chein", WORDS-XS, 1, ALPHABET-FR-SIMPLE)
#    alt-words("aboit", WORDS-XS, 1, ALPHABET-FR-SIMPLE)
#    alt-words("for",   WORDS-XS, 1, ALPHABET-FR-SIMPLE)
#
# 4. Essayez vos propres mots mal orthographiés !
