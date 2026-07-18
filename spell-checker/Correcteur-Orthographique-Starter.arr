# ══════════════════════════════════════════════════════════════════════════════
# CORRECTEUR ORTHOGRAPHIQUE — FICHIER DE DÉMARRAGE (FRANÇAIS)
# ══════════════════════════════════════════════════════════════════════════════
#
# Adapté de Bootstrap World (Fall 2026)
# Leçon « Data-Driven Algorithms » / Algorithmes pilotés par les données
#
# ══════════════════════════════════════════════════════════════════════════════

import lists as L

# ─── ALPHABET FRANÇAIS ───────────────────────────────────────────────────────

ALPHABET-FR-SIMPLE = "abcdefghijklmnopqrstuvwxyzéèêàùç"
ALPHABET-FR = "abcdefghijklmnopqrstuvwxyzàâéèêëîïôöùûüçæœ"

# ─── APPLY-TRANSFORMATION ───────────────────────────────────────────────────
# Enveloppe les résultats dans une table, comme dans la bibliothèque originale.

fun apply-transformation(transform-word :: (String -> List<String>), word-or-words) -> Table:
  words = if is-string(word-or-words): [list: word-or-words]
  else: word-or-words.column("alternate spellings")
  end
  acc-dict = [SD.mutable-string-dict:]
  for each(word from words):
    for each(result from transform-word(word)):
      acc-dict.set-now(result, true)
    end
  end
  res = acc-dict.keys-now().to-list()
  [T.table-from-columns: {"alternate spellings"; res}]
    .order-by("alternate spellings", true)
end

# ══════════════════════════════════════════════════════════════════════════════
# FONCTIONS DE DISTANCE D'ÉDITION
# ══════════════════════════════════════════════════════════════════════════════

# ─── SUBSTITUTION ───────────────────────────────────────────────────────────
# Prend un mot (ou une table) et retourne une table de toutes les variantes
# obtenues en remplaçant une lettre par une autre.
#
# Exemple : subs("chian") → table contenant ..., "chien", ...

fun subs(word-or-words) -> Table:
  words = if is-string(word-or-words): [list: word-or-words]
  else: word-or-words.column("alternate spellings")
  end
  letters = string-explode(ALPHABET-FR-SIMPLE)

  fun transform-word(word :: String) -> List<String>:
    word-chars = string-explode(word)
    word-len = word-chars.length()
    fun substitute-at(pos :: Number) -> List<String>:
      current = word-chars.get(pos)
      for fold(acc from [list:], letter from letters):
        if letter == current:
          acc
        else:
          new-chars = for fold(chars from [list:], i from L.range(0, word-len)):
            if i == pos: link(letter, chars)
            else: link(word-chars.get(i), chars)
            end
          end
          link(L.reverse(new-chars).join-str(""), acc)
        end
      end
    end
    for fold(all from [list:], pos from L.range(0, word-len)):
      all + substitute-at(pos)
    end
  end
  apply-transformation(transform-word, words)
end

# ─── ÉCHANGE (SWAP) ─────────────────────────────────────────────────────────
# Prend un mot (ou une table) et retourne une table de toutes les variantes
# obtenues en inversant deux lettres adjacentes.
#
# Exemple : swaps("chein") → table contenant ..., "chien", ...

fun swaps(word-or-words) -> Table:
  words = if is-string(word-or-words): [list: word-or-words]
  else: word-or-words.column("alternate spellings")
  end

  fun transform-word(word :: String) -> List<String>:
    word-chars = string-explode(word)
    word-len = word-chars.length()
    fun swap-at(pos :: Number) -> String:
      swapped = for fold(chars from [list:], i from L.range(0, word-len)):
        if i == pos: link(word-chars.get(pos + 1), chars)
        else if i == (pos + 1): link(word-chars.get(pos), chars)
        else: link(word-chars.get(i), chars)
        end
      end
      L.reverse(swapped).join-str("")
    end
    for fold(sw from [list:], pos from L.range(0, word-len - 1)):
      link(swap-at(pos), sw)
    end
  end
  apply-transformation(transform-word, words)
end

# ─── SUPPRESSION ────────────────────────────────────────────────────────────
# Prend un mot (ou une table) et retourne une table de toutes les variantes
# obtenues en supprimant une lettre.
#
# Exemple : deletions("for") → table contenant "fo", "fr", "or"

fun deletions(word-or-words) -> Table:
  words = if is-string(word-or-words): [list: word-or-words]
  else: word-or-words.column("alternate spellings")
  end

  fun transform-word(word :: String) -> List<String>:
    word-chars = string-explode(word)
    word-len = word-chars.length()
    fun delete-at(pos :: Number) -> String:
      deleted = for fold(chars from [list:], i from L.range(0, word-len)):
        if i == pos: chars
        else: link(word-chars.get(i), chars)
        end
      end
      L.reverse(deleted).join-str("")
    end
    for fold(all from [list:], pos from L.range(0, word-len)):
      link(delete-at(pos), all)
    end
  end
  apply-transformation(transform-word, words)
end

# ─── INSERTION ──────────────────────────────────────────────────────────────
# Prend un mot (ou une table) et retourne une table de toutes les variantes
# obtenues en insérant une lettre.
#
# Exemple : insertions("aboi") → table contenant ..., "aboie", ...

fun insertions(word-or-words) -> Table:
  words = if is-string(word-or-words): [list: word-or-words]
  else: word-or-words.column("alternate spellings")
  end
  letters = string-explode(ALPHABET-FR-SIMPLE)

  fun transform-word(word :: String) -> List<String>:
    word-chars = string-explode(word)
    word-len = word-chars.length()
    fun insert-at(pos :: Number) -> List<String>:
      for fold(acc from [list:], letter from letters):
        inserted = for fold(chars from [list:], i from L.range(0, word-len + 1)):
          if i < pos: link(word-chars.get(i), chars)
          else if i == pos: link(letter, chars)
          else: link(word-chars.get(i - 1), chars)
          end
        end
        link(L.reverse(inserted).join-str(""), acc)
      end
    end
    for fold(all from [list:], pos from L.range(0, word-len + 1)):
      all + insert-at(pos)
    end
  end
  apply-transformation(transform-word, words)
end

# ══════════════════════════════════════════════════════════════════════════════
# ONLY-REAL : filtre par dictionnaire
# ══════════════════════════════════════════════════════════════════════════════

# Prend une table (colonne "alternate spellings") et un dictionnaire,
# retourne une table ne contenant que les mots présents dans le dictionnaire.

fun only-real(word-table :: Table, dict :: List<String>) -> Table:
  words = word-table.column("alternate spellings")
  filtered = for fold(acc from [list:], w from words):
    if L.member(dict, w): link(w, acc) else: acc end
  end
  [T.table-from-columns: {"alternate spellings"; L.reverse(filtered)}]
    .order-by("alternate spellings", true)
end

# ══════════════════════════════════════════════════════════════════════════════
# ALT-WORDS : correction orthographique complète
# ══════════════════════════════════════════════════════════════════════════════

# Combine toutes les fonctions ci-dessus et trouve tous les mots du
# dictionnaire à distance d'édition ≤ n.
#
# Retourne une table à deux colonnes :
#   "word"           — le mot corrigé
#   "edit-distance"  — la distance d'édition (1, 2, 3, ...)
#
# Exemple : alt-words("chein", WORDS-XS, 2)

fun alt-words(word :: String, dict :: List<String>, edits :: Number) -> Table:
  doc: "Trouve tous les mots du dictionnaire à distance ≤ edits"

  fun find-edits(w :: String, remaining :: Number, dist :: Number) -> List:
    if remaining <= 0: empty
    else:
      s   = subs(w).column("alternate spellings")
      sw  = swaps(w).column("alternate spellings")
      ins = insertions(w).column("alternate spellings")
      del = deletions(w).column("alternate spellings")
      all-variants = L.append(L.append(s, sw), L.append(ins, del))
      real-words = for fold(acc from [list:], v from all-variants):
        if L.member(dict, v): link(v, acc) else: acc end
      end
      real = L.distinct(real-words)
      # Résultats à cette distance
      current = for map(w2 from real):
        {word: w2, edit-distance: dist}
      end
      if remaining == 1:
        current
      else:
        # Récursion pour la profondeur suivante
        deeper = for fold(acc from [list:], w2 from real):
          L.append(acc, find-edits(w2, remaining - 1, dist + 1))
        end
        L.append(current, deeper)
      end
    end
  end

  results = find-edits(word, edits, 1)
  uniq-results = L.distinct(results)
  [T.table-from-columns: {
    "word": for map(r from uniq-results): r.word end;
    "edit-distance": for map(r from uniq-results): r.edit-distance end
  }].order-by("edit-distance", true).order-by("word", true)
end

# ══════════════════════════════════════════════════════════════════════════════
# DICTIONNAIRES FRANÇAIS
# ══════════════════════════════════════════════════════════════════════════════

# Dictionnaire minimal — 169 mots de 5 lettres (embarqué)
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
# Pour charger un dictionnaire plus grand (5 000, 13 000 ou 40 000 mots),
# hébergez les fichiers .arr du dossier dictionaries/ sur un serveur public
# (ex. GitHub) et utilisez url-file :
#
#   include url-file("https://raw.githubusercontent.com/<user>/<repo>/main/spell-checker/dictionaries/WORDS-S-FR.arr")
#
# Les fichiers WORDS-S-FR.arr, WORDS-M-FR.arr, WORDS-L-FR.arr définissent
# respectivement WORDS-S, WORDS-M et WORDS-L.
# ══════════════════════════════════════════════════════════════════════════════
