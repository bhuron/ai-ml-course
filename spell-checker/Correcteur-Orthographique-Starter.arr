# ══════════════════════════════════════════════════════════════════════════════
# CORRECTEUR ORTHOGRAPHIQUE FRANÇAIS — IMPLÉMENTATION COMPLÈTE EN PYRET
# ══════════════════════════════════════════════════════════════════════════════
#
# Ce fichier est autonome : toutes les fonctions sont implémentées ci-dessous.
# Il n'y a pas de dépendance externe.
#
# Pour utiliser les grands dictionnaires (WORDS-S-FR, WORDS-M-FR, WORDS-L-FR),
# placez les fichiers .txt du dossier dictionaries/ à côté de ce fichier,
# ou hébergez-les en ligne et adaptez les chemins dans la section DICTIONNAIRES.
#
# ══════════════════════════════════════════════════════════════════════════════

# ─── ALPHABET FRANÇAIS ───────────────────────────────────────────────────────
# Inclut les lettres de base + caractères accentués.
# Lors d'une substitution ou insertion, on essaie toutes ces lettres.

ALPHABET-FR = [list:
  "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
  "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  "à", "â", "é", "è", "ê", "ë", "î", "ï", "ô", "ö", "ù", "û", "ü",
  "ç", "æ", "œ"
]

# Version réduite pour les démos rapides (substitutions moins nombreuses)
ALPHABET-FR-SIMPLE = [list:
  "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
  "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  "é", "è", "ê", "à", "ù", "ç"
]

# ─── FONCTIONS UTILITAIRES ──────────────────────────────────────────────────

# Convertit une chaîne de caractères en liste de chaînes d'un caractère
fun string-to-char-list(s):
  for map(i from range(0, string-length(s))):
    string-substring(s, i, i + 1)
  end
end

# Convertit une liste de chaînes d'un caractère en une chaîne
fun char-list-to-string(lst):
  for fold(str from "", elt from lst):
    string-append(str, elt)
  end
end

# ══════════════════════════════════════════════════════════════════════════════
# FONCTIONS DE DISTANCE D'ÉDITION (1 édition = distance 1)
# ══════════════════════════════════════════════════════════════════════════════

# ─── SUBSTITUTION ───────────────────────────────────────────────────────────
# Remplace chaque lettre du mot par chaque lettre de l'alphabet.
# Pour un mot de n lettres et un alphabet de a lettres : n × a variantes.
# Exemple : subs("chein") génère "ahien", "bhien", ..., "chien", ..., "cheiœ"

fun subs(word :: String, alphabet :: List<String>) -> List<String>:
  doc: "Remplace chaque lettre par toutes les lettres de l'alphabet"
  for map(i from range(0, string-length(word))):
    orig-letter = string-substring(word, i, i + 1)
    before = string-substring(word, 0, i)
    after = string-substring(word, i + 1, string-length(word))
    for map(letter from alphabet):
      if letter == orig-letter: # ne pas générer le mot original
        ""
      else:
        string-append(before, letter, after)
      end
    end
  end
end

# ─── ÉCHANGE (SWAP) ─────────────────────────────────────────────────────────
# Échange chaque paire de lettres adjacentes.
# Pour un mot de n lettres : n-1 variantes.
# Exemple : swaps("chein") génère "hcein", "cehin", "chien", "cheïn"

fun swaps(word :: String) -> List<String>:
  doc: "Échange chaque paire de lettres adjacentes"
  for map(i from range(0, string-length(word) - 1)):
    c1 = string-substring(word, i, i + 1)
    c2 = string-substring(word, i + 1, i + 2)
    before = string-substring(word, 0, i)
    after = string-substring(word, i + 2, string-length(word))
    string-append(before, c2, c1, after)
  end
end

# ─── INSERTION ──────────────────────────────────────────────────────────────
# Insère chaque lettre de l'alphabet à chaque position possible.
# Pour un mot de n lettres et a lettres dans l'alphabet : (n+1) × a variantes.
# Exemple : insertions("aboi") génère "aaboi", "baboi", ..., "aboie", ...

fun insertions(word :: String, alphabet :: List<String>) -> List<String>:
  doc: "Insère chaque lettre de l'alphabet à chaque position"
  for map(i from range(0, string-length(word) + 1)):
    before = string-substring(word, 0, i)
    after = string-substring(word, i, string-length(word))
    for map(letter from alphabet):
      string-append(before, letter, after)
    end
  end
end

# ─── SUPPRESSION ────────────────────────────────────────────────────────────
# Supprime chaque lettre du mot, une par une.
# Pour un mot de n lettres : n variantes.
# Exemple : deletions("vossinage") génère "ossinage", "vssinage", "voisinage", ...

fun deletions(word :: String) -> List<String>:
  doc: "Supprime chaque lettre du mot, une par une"
  for map(i from range(0, string-length(word))):
    before = string-substring(word, 0, i)
    after = string-substring(word, i + 1, string-length(word))
    string-append(before, after)
  end
end

# ══════════════════════════════════════════════════════════════════════════════
# FILTRE PAR DICTIONNAIRE
# ══════════════════════════════════════════════════════════════════════════════

# Ne garde que les mots qui existent dans le dictionnaire.
# Supprime aussi les doublons et les chaînes vides.

fun only-real(words :: List<String>, dict :: List<String>) -> List<String>:
  doc: "Filtre la liste pour ne garder que les mots présents dans le dictionnaire"
  clean = L.filter(lam(w): string-length(w) > 0 end, words)
  uniq = L.distinct(clean)
  L.filter(lam(w): L.member(dict, w) end, uniq)
end

# ══════════════════════════════════════════════════════════════════════════════
# CORRECTEUR ORTHOGRAPHIQUE COMPLET
# ══════════════════════════════════════════════════════════════════════════════

# Génère toutes les variantes à distance d'édition ≤ n, puis filtre.
#
# Paramètres :
#   word     — le mot à corriger (ex: "chein")
#   dict     — la liste de mots du dictionnaire
#   edits    — distance d'édition maximale (1, 2, 3 ou 4)
#   alphabet — l'alphabet à utiliser pour les substitutions/insertions
#
# Exemples :
#   alt-words("chein", WORDS-XS-FR, 1, ALPHABET-FR-SIMPLE)
#   alt-words("aboit", WORDS-XS-FR, 2, ALPHABET-FR-SIMPLE)

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
    # Génère toutes les variantes à distance 1
    s = subs(word, alphabet)
    sw = swaps(word)
    ins = insertions(word, alphabet)
    dels = deletions(word)
    all-variants = L.flatten([list: s, sw, ins, dels])

    # Filtre par le dictionnaire (mots réels à distance 1)
    distance-1 = only-real(all-variants, dict)

    if edits == 1:
      distance-1
    else:
      # Récursion : pour chaque mot à distance 1, trouve les mots à distance edits-1
      distance-1-words = for fold(acc from empty, w from distance-1):
        deeper = alt-words(w, dict, edits - 1, alphabet)
        L.append(acc, deeper)
      end
      # Combine distance-1 et les résultats plus profonds, dédoublonne
      L.distinct(L.append(distance-1, distance-1-words))
    end
  end
end

# ══════════════════════════════════════════════════════════════════════════════
# DICTIONNAIRES FRANÇAIS
# ══════════════════════════════════════════════════════════════════════════════

# ─── WORDS-XS-FR : 100 mots français de 5 lettres ───────────────────────────
# Sélectionnés manuellement pour être courants et reconnaissables.
# Idéal pour les démonstrations rapides (les opérations sont quasi instantanées).

WORDS-XS-FR = [list:
  "abîme", "abord", "abris", "actif", "adore", "aider", "aigle", "aimer",
  "aller", "amour", "appel", "arbre", "asile", "assez", "atome", "aussi",
  "autre", "avant", "avoir", "bague", "belle", "bêtes", "blanc", "bleue",
  "boire", "bonne", "bruit", "calme", "carte", "cause", "champ", "chant",
  "chaud", "chien", "choix", "coule", "court", "danse", "dette", "douce",
  "durer", "écart", "école", "écrit", "égale", "envie", "essai", "étude",
  "faire", "faute", "femme", "fleur", "force", "forme", "frais", "fruit",
  "garde", "geste", "glace", "grand", "haute", "homme", "idées", "jardin",
  "jeune", "jouer", "juger", "juste", "large", "libre", "linge", "livre",
  "longs", "louer", "lutte", "mains", "maman", "mange", "mardi", "masse",
  "mener", "mieux", "monde", "morte", "moule", "murer", "nager", "noble",
  "noire", "noter", "noyer", "objet", "ombre", "orage", "ordre", "oubli",
  "parle", "parti", "passe", "patte", "peine", "pense", "perte", "peuple",
  "piste", "place", "plage", "plein", "pluie", "porte", "poser", "poule",
  "prend", "prête", "prive", "proie", "prose", "quête", "rêver", "ronde",
  "rouge", "sable", "saint", "salle", "scène", "séché", "selon", "serré",
  "seule", "siège", "signe", "singe", "sorte", "souci", "sourd", "style",
  "suite", "table", "tâche", "terre", "tirer", "titre", "tombe", "trace",
  "train", "trame", "triste", "trois", "usage", "vague", "valse", "venir",
  "vente", "verse", "vider", "ville", "vivre", "voile", "voler"
]

# ─── WORDS-S-FR : charger depuis un fichier externe ─────────────────────────
# Si le fichier dictionaries/WORDS-S-FR.txt est accessible, décommentez :
#
#   WORDS-S-FR = file-read-lines("dictionaries/WORDS-S-FR.txt")
#
# Sinon, vous pouvez copier-coller le contenu du fichier ici,
# ou l'héberger en ligne et utiliser :
#
#   WORDS-S-FR-RAW = fetch("https://votre-serveur.com/WORDS-S-FR.txt")
#   WORDS-S-FR = string-split(WORDS-S-FR-RAW, "\n")

# Pour les exercices, WORDS-XS-FR (ci-dessus, 100 mots) est suffisant.

# ══════════════════════════════════════════════════════════════════════════════
# EXEMPLES ET TESTS RAPIDES
# ══════════════════════════════════════════════════════════════════════════════
#
# Décommentez les lignes ci-dessous pour tester les fonctions dans la
# fenêtre d'interactions (à droite dans Pyret) après avoir cliqué "Run".

# Test : substitution sur "chein" → devrait contenir "chien"
# check "subs trouve chien":
#   L.member(subs("chein", ALPHABET-FR-SIMPLE), "chien") is true
# end

# Test : swaps sur "chein" → devrait contenir "chien"
# check "swaps trouve chien":
#   L.member(swaps("chein"), "chien") is true
# end

# Test : insertions sur "aboi" → devrait contenir "aboie"
# check "insertions trouve aboie":
#   L.member(insertions("aboi", ALPHABET-FR-SIMPLE), "aboie") is true
# end

# Test : deletions sur "vossinage" → devrait contenir "voisinage"
# check "deletions trouve voisinage":
#   L.member(deletions("vossinage"), "voisinage") is true
# end

# ─── DÉMO : phrase de la leçon ──────────────────────────────────────────────
# Essayez ceci dans la fenêtre d'interactions après avoir cliqué "Run" :
#
#   alt-words("chein",   WORDS-XS-FR, 1, ALPHABET-FR-SIMPLE)
#   alt-words("aboit",   WORDS-XS-FR, 1, ALPHABET-FR-SIMPLE)
#   alt-words("for",     WORDS-XS-FR, 1, ALPHABET-FR-SIMPLE)
#   alt-words("vossinage", WORDS-XS-FR, 1, ALPHABET-FR-SIMPLE)
#
# Pour une recherche plus large (distance 2) :
#   alt-words("chein", WORDS-XS-FR, 2, ALPHABET-FR-SIMPLE)
#
# ══════════════════════════════════════════════════════════════════════════════
