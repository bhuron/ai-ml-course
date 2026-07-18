use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries", "core.arr")

# ══════════════════════════════════════════════════════════════════════════════
# CORRECTEUR ORTHOGRAPHIQUE — FICHIER DE DÉMARRAGE (FRANÇAIS)
# ══════════════════════════════════════════════════════════════════════════════
#
# Adaptation française du fichier `Spell Checker Starter File.arr` de
# Bootstrap World (Fall 2026, leçon « Data-Driven Algorithms »).
# Licence : Creative Commons 4.0 Unported (Bootstrap Community).
#
# Ce fichier reprend INTÉGRALEMENT la bibliothèque `spell-checker-library.arr`
# de Bootstrap, en conservant l'API d'origine (fonctions renvoyant des
# Tables, dictionnaires sous forme de BK-trees via BKNode). Les seules
# modifications par rapport à l'original sont :
#   1. Les alphabets `abcdefghijklmnopqrstuvwxyz` hardcodés dans subs() et
#      insertions() sont remplacés par `ALPHABET-FR-SIMPLE` (32 lettres
#      avec accents français). Une variante étendue `ALPHABET-FR` (44
#      caractères, incluant æ/œ) est fournie pour usage manuel.
#   2. Le BK-tree anglais pré-sérialisé WORDS-XS est remplacé par
#      `WORDS-XS-FR` (169 mots français de 5 lettres), embarqué et
#      construit au chargement via `build-bk-tree()`. Les dictionnaires
#      plus grands (WORDS-S/M/L-FR, 5k/13k/40k mots) ne sont PAS embarqués
#      (trop volumineux pour l'éditeur en ligne) ; ils se chargent à la
#      demande par `import url-file(...)` sur les fichiers .arr associés
#      dans `spell-checker/dictionaries/`. Voir la section en bas de ce
#      fichier pour la marche à suivre.
#
# API publique (identique à l'original) :
#   subs(word-or-words)              -> Table   # utilise ALPHABET-FR-SIMPLE
#   swaps(word-or-words)             -> Table
#   insertions(word-or-words)        -> Table   # utilise ALPHABET-FR-SIMPLE
#   deletions(word-or-words)         -> Table
#   only-real(table, dict :: BKNode) -> Table
#   alt-words(s, dict :: BKNode, n)   -> Table   # distance d'édition ≤ n
#
# Exemples (à essayer dans la fenêtre d'interactions après « Run ») :
#   subs("chein")              # table contenant "chien"
#   alt-words("plation", WORDS-L-FR, 4)
#   only-real(subs("ecole"), WORDS-XS-FR)   → table contenant "école"
# ══════════════════════════════════════════════════════════════════════════════
################################################################
# Bootstrap Spell Checker Library, as of Fall 2026

provide *

# re-export every symbol from Core
import url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/core", "../libraries/core.arr") as Core
import csv as csv
include string-dict
provide from Core:
  *,
  type Posn,
  module Err,
  module Sets,
  module T,
  module SD,
  module R,
  module L,
  module Stats
end
# export every symbol from starter2024 except for those we override
import starter2024 as Starter
provide from Starter:
    * hiding(translate, filter, range, sort, sin, cos, tan)
end

provide from L: * hiding(filter, range, sort), type *, data * end
include valueskeleton

# ─── ALPHABETS FRANÇAIS ──────────────────────────────────────────────────────
# 32 caractères : 26 lettres de base + les 6 accents les plus courants.
# Utilisé par défaut par subs() et insertions() pour des démos rapides.
ALPHABET-FR-SIMPLE = "abcdefghijklmnopqrstuvwxyzéèêàùç"

# 44 caractères : alphabet complet avec accents étendus (à, â, ë, î, ï,
# ô, ö, û, ü) et ligatures (æ, œ). Utilisez-le en passant la valeur
# explicitement si vous modifiez subs() / insertions().
ALPHABET-FR        = "abcdefghijklmnopqrstuvwxyzàâéèêëîïôöùûüçæœ"

# given two strings, produce the edit-distance between the
fun levenshtein(s :: String, t :: String) -> Number:
  t-chars = string-explode(t)
  t-len = t-chars.length()
  init-row = L.range(0, t-len + 1)

  fun next-row(prev-row :: List<Number>, row-num :: Number, s-char :: String) -> List<Number>:
    fun go(pr :: List<Number>, tc-rest :: List<String>, left :: Number, acc-rev :: List<Number>) -> List<Number>:
      cases (List) tc-rest:
        | empty => L.reverse(acc-rev)
        | link(tc, t-suf) =>
          diag  = pr.first
          shadow above = pr.rest.first
          cost  = if s-char == tc: 0 else: 1 end
          val   = num-min(num-min(left + 1, above + 1), diag + cost)
          go(pr.rest, t-suf, val, link(val, acc-rev))
      end
    end
    go(prev-row, t-chars, row-num, [list: row-num])
  end

  fun process-rows(prev-row :: List<Number>, sc-rest :: List<String>, row-num :: Number) -> Number:
    cases (List) sc-rest:
      | empty => prev-row.last()
      | link(sc, s-suf) =>
        process-rows(next-row(prev-row, row-num, sc), s-suf, row-num + 1)
    end
  end

  process-rows(init-row, string-explode(s), 1)
end

data WordResult:
  | word-result(word :: String, edit-distance :: Number)
end

DICTIONARY-IMG = image-url("https://raw.githubusercontent.com/bootstrapworld/starter-files/fall2026/libraries/images/dictionary-icon.png")

data BKNode:
  | bk-node(word :: String, children :: SD.MutableStringDict) with:
  
  method _output(self) block:
      count-str = num-to-string(count-words(self))
      count-img = rotate(-7, text(count-str, 12, "white"))
      vs-value(
        put-image(
          count-img,
          38, 45,
          scale(0.5, DICTIONARY-IMG)
          )
        )
  end
end

fun bk-search(node :: BKNode, query :: String, n :: Number) -> List<WordResult>:
  d = levenshtein(node.word, query)
  init-acc = if d <= n: [list: word-result(node.word, d)] else: empty end
  lo = if d < n: 0 else: d - n end
  hi = d + n
  for fold(acc from init-acc, dist from L.range(lo, hi + 1)):
    cases (Starter.Option) node.children.get-now(num-to-string(dist)):
      | none => acc
      | some(child) => acc + bk-search(child, query, n)
    end
  end
end

fun count-words(node :: BKNode) -> Number:
  child-keys = node.children.keys-now().to-list()
  for fold(total from 1, key from child-keys):
    child = node.children.get-value-now(key)
    total + count-words(child)
  end
end

fun apply-transformation(transform-word :: (String -> List<String>), word-or-words) -> Table block:
  words = if is-string(word-or-words): [list: word-or-words]
  else: word-or-words.column("alternate spellings")
  end
 
  acc-dict = [SD.mutable-string-dict: ]
  for each(word from words):
    for each(result from transform-word(word)):
      acc-dict.set-now(result, true)
    end
  end
 
  res = acc-dict.keys-now().to-list()
  [T.table-from-columns: {"alternate spellings"; res}]
    .order-by("alternate spellings", true)
end


fun subs(word-or-words) -> Table:

  words = if is-string(word-or-words): [list: word-or-words]
  else: word-or-words.column("alternate spellings")
  end

  alphabet = ALPHABET-FR-SIMPLE
  letters = string-explode(alphabet)

  fun transform-word(word :: String) -> List<String>:
    word-chars = string-explode(word)
    word-len = word-chars.length()

    fun substitute-at-position(pos :: Number) -> List<String>:
      current-char = word-chars.get(pos)
      for fold(substitutions from [list: ], letter from letters):
        if letter == current-char:
          substitutions
        else:
          new-chars = for fold(chars from [list: ], i from L.range(0, word-len)):
            if i == pos:
              link(letter, chars)
            else:
              link(word-chars.get(i), chars)
            end
          end
          new-word = L.reverse(new-chars).join-str("")
          link(new-word, substitutions)
        end
      end
    end

    for fold(all-substitutions from [list: ], pos from L.range(0, word-len)):
      all-substitutions + substitute-at-position(pos)
    end
  end

  apply-transformation(transform-word, word-or-words)
end


fun swaps(word-or-words) -> Table:

  words = if is-string(word-or-words): [list: word-or-words]
  else: word-or-words.column("alternate spellings")
  end

  fun transform-word(word :: String) -> List<String>:
    word-chars = string-explode(word)
    word-len = word-chars.length()

    fun swap-at-position(pos :: Number) -> String:
      # Swap character at pos with character at pos + 1
      swapped-chars = for fold(chars from [list: ], i from L.range(0, word-len)):
        if i == pos:
          link(word-chars.get(pos + 1), chars)
        else if i == (pos + 1):
          link(word-chars.get(pos), chars)
        else:
          link(word-chars.get(i), chars)
        end
      end
      L.reverse(swapped-chars).join-str("")
    end

    for fold(swapped from [list: ], pos from L.range(0, word-len - 1)):
      link(swap-at-position(pos), swapped)
    end
  end

  apply-transformation(transform-word, word-or-words)
end

fun deletions(word-or-words) -> Table:
 
  words = if is-string(word-or-words): [list: word-or-words]
  else: word-or-words.column("alternate spellings")
  end
 
  fun transform-word(word :: String) -> List<String>:
    word-chars = string-explode(word)
    word-len = word-chars.length()
 
    fun delete-at-position(pos :: Number) -> String:
      # Delete character at position pos
      deleted-chars = for fold(chars from [list: ], i from L.range(0, word-len)):
        if i == pos:
          chars
        else:
          link(word-chars.get(i), chars)
        end
      end
      L.reverse(deleted-chars).join-str("")
    end
 
    for fold(all-deletions from [list: ], pos from L.range(0, word-len)):
      link(delete-at-position(pos), all-deletions)
    end
  end
  
  apply-transformation(transform-word, word-or-words)
end

fun insertions(word-or-words) -> Table:
 
  words = if is-string(word-or-words): [list: word-or-words]
  else: word-or-words.column("alternate spellings")
  end
 
  alphabet = ALPHABET-FR-SIMPLE
  letters = string-explode(alphabet)
 
  fun transform-word(word :: String) -> List<String>:
    word-chars = string-explode(word)
    word-len = word-chars.length()
 
    fun insert-at-position(pos :: Number) -> List<String>:
      for fold(shadow insertions from [list: ], letter from letters):
        new-chars = for fold(chars from [list: ], i from L.range(0, word-len + 1)):
          if i == pos:
            link(letter, chars)
          else if i < pos:
            link(word-chars.get(i), chars)
          else:
            link(word-chars.get(i - 1), chars)
          end
        end
        new-word = L.reverse(new-chars).join-str("")
        link(new-word, insertions)
      end
    end
 
    for fold(all-insertions from [list: ], pos from L.range(0, word-len + 1)):
      all-insertions + insert-at-position(pos)
    end
  end
 
  apply-transformation(transform-word, word-or-words)
end

fun only-real(word-table :: Table, dictionary :: BKNode) -> Table block:
  words = word-table.column("alternate spellings")

  acc-dict = [SD.mutable-string-dict: ]
  for each(word from words):
    results = bk-search(dictionary, word, 0)
    if results.length() > 0:
      acc-dict.set-now(word, true)
    else:
      nothing
    end
  end

  res = acc-dict.keys-now().to-list()
  [T.table-from-columns: {"word"; res}]
    .order-by("word", true)
end


fun alt-words(orig-s :: String, dictionary :: BKNode, n :: Number):
  s = string-to-lower(orig-s)
  results = Sets.list-to-set(bk-search(dictionary, s, n)).to-list()
  row-list = results.map({(wr): [
        T.raw-row: {"word"; wr.word},
        {"edit-distance"; wr.edit-distance},
        {"id"; random(9999999999)} 
      ]})
  row-list.foldl({(r, t): t.add-row(r)}, table: word, edit-distance, id end)
    .order-by("id", true)
    .filter(lam(r): r["word"] <> orig-s end)
    .select-columns([list: "word", "edit-distance"])
end

#################### For Authoring ##########################################
# The English originals ship pre-serialized BK-trees sourced from a
# Google Sheet. This French adaptation instead inlines the French word
# lists (from dictionaries/WORDS-{XS,S,M,L}-FR.txt) and builds the
# BK-trees at load time via build-bk-tree(). The helper functions
# serialize-tree / deserialize-tree / get-tree are kept verbatim from
# the upstream library so authors can pre-serialize later if desired.

DICTIONARY-URL = "https://docs.google.com/spreadsheets/d/13vL8Tg4lJ09s9GJwTKTZ9Ne1b6wDa92nj8RUPwgNfBQ/export?format=csv&gid="

# The gid number for each separate tab (word-list)
# specific to the google sheet being linked above
WORDS-L-GID  = "0"           # 44,000 most-common words
WORDS-M-GID  = "1465800911"  # 25,000 most-common words
WORDS-S-GID  = "1712073918"  #  5,000 most-common words
WORDS-XS-GID = "160808960"   #    100 5-letter words (from Wordle)

# Given a GID, produce a list of all the words
fun get-words-from-sheet(gid :: String) -> List<String>:
  extract all-words from
    load-table: all-words :: String
      source: csv.csv-table-url(DICTIONARY-URL + gid, {
            header-row: true,
            infer-content: false
          })
    end
  end
end

fun build-bk-tree(words :: List<String>) -> BKNode:

  fun bk-insert(node :: BKNode, w :: String) -> Nothing:
    d = levenshtein(node.word, w)
    ds = num-to-string(d)
    cases (Starter.Option) node.children.get-now(ds):
      | none => node.children.set-now(ds, bk-node(w, [SD.mutable-string-dict: ]))
      | some(child) => bk-insert(child, w)
    end
  end

  cases (List) words block:
    | empty => raise("Cannot build BK-tree from empty word list")
    | link(first-word, rest) =>
      root = bk-node(first-word, [SD.mutable-string-dict: ])
      for each(w from rest):
        bk-insert(root, w)
      end
      root
  end
end

# Given a GID, produce a bk-tree for the word-list
# in the corresponding sheet
fun get-tree(gid) -> BKNode:
  build-bk-tree(get-words-from-sheet(gid))
end

# Given a bk-tree, serialize it to a String
fun serialize-tree(tree :: BKNode) -> String:
  fun serialize-node(node :: BKNode) -> String:
    keys = node.children.keys-now().to-list()
    header = node.word + "," + num-to-string(keys.length())
    for fold(acc from header, key from keys):
      child = node.children.get-value-now(key)
      acc + "," + key + "," + serialize-node(child)
    end
  end

  serialize-node(tree)
end

# gid-to-serial-str :: String -> String
# consumes the gid of a google sheets tab, and produces
# a serialized version of a bk-tree for those words
fun gid-to-serial-str(gid):
  serialize-tree(get-tree(gid))
end

# example:
# gid-to-serial-str(WORDS-XS-GID)
# copy-paste the resulting string to the bottom of this file

#########################################################################

fun deserialize-tree(s :: String) -> BKNode:

  fun parse-children(
      toks :: List<String>, 
      sacount :: Number, 
      acc :: SD.MutableStringDict
      ) -> {SD.MutableStringDict; List<String>}:
    if sacount == 0:
      {acc; toks}
    else:
      cases (List) toks block:
        | empty => raise("Unexpected end of serialized tree")
        | link(dist, after-dist) =>
          {child; after-child} = parse-node(after-dist)
          acc.set-now(dist, child)
          parse-children(after-child, sacount - 1, acc)
      end
    end
  end

  fun parse-node(tokens :: List<String>) -> {BKNode; List<String>}:
    cases (List) tokens:
      | empty => raise("Unexpected end of serialized tree")
      | link(word, after-word) =>
        cases (List) after-word:
          | empty => raise("Unexpected end of serialized tree")
          | link(n-str, after-n) =>
            n = cases (Starter.Option) string-to-number(n-str):
              | some(v) => v
              | none => raise("Expected number, got: " + n-str)
            end
            {children; remaining} = parse-children(after-n, n, [SD.mutable-string-dict: ])
            {bk-node(word, children); remaining}
        end
    end
  end
  {tree; _} = parse-node(string-split-all(s, ","))
  tree
end
############# Pre-Compiled BK-Trees

# Word lists sources : spell-checker/dictionaries/WORDS-{XS,S,M,L}-FR.txt
# (extrait du dictionnaire Hunspell fr_FR, filtré en minuscules + accents).
# À la place des arbres pré-sérialisés de l'original anglais,
# on construit les BK-trees au chargement avec build-bk-tree().

# WORDS-XS-FR — 169 mots français, embarqué
WORDS-XS-FR = build-bk-tree(
[list:
  "abîme", "abord", "abris", "absent", "acheté", "actif", "adore", "aider", "aigle", "aimer", "aller", "amour",
  "appel", "arbre", "asile", "assez", "atome", "auber", "aussi", "autre", "avant", "avoir", "bague", "belle",
  "bêtes", "blanc", "bleue", "boire", "bonne", "bruit", "calme", "carte", "cause", "champ", "chant", "chaud",
  "chien", "choix", "coule", "court", "danse", "dette", "douce", "durer", "écart", "école", "écrit", "égale",
  "envie", "essai", "étude", "faire", "faute", "femme", "fleur", "force", "forme", "frais", "fruit", "garde",
  "geste", "glace", "grand", "haute", "homme", "idées", "jardin", "jeune", "jouer", "juger", "juste", "large",
  "libre", "linge", "livre", "longs", "louer", "lutte", "mains", "maman", "mange", "mardi", "masse", "mener",
  "mieux", "monde", "morte", "moule", "murer", "nager", "noble", "noire", "noter", "noyer", "objet", "ombre",
  "orage", "ordre", "oubli", "parle", "parti", "passe", "patte", "peine", "pense", "perte", "peuple", "pidre",
  "piste", "place", "plage", "plein", "pluie", "porte", "poser", "poule", "prend", "prête", "preux", "prive",
  "proie", "prose", "proue", "quête", "rêver", "rivée", "ronde", "rouge", "sable", "saint", "salle", "scène",
  "séché", "selon", "serré", "seule", "siège", "signe", "singe", "sorte", "souci", "sourd", "style", "suite",
  "table", "tâche", "terre", "tirer", "titre", "tombe", "trace", "train", "trame", "triste", "trois", "tuer",
  "usage", "vague", "valse", "venir", "vente", "verse", "vêtir", "vider", "ville", "vivre", "voile", "voler",
  "yeuse"
]
)

# WORDS-S-FR — chargé à la demande depuis dictionaries/WORDS-S-FR.arr
# (fichier d'accompagnement, non embarqué pour garder ce starter léger).
# Pour l'utiliser, décommentez l'import ci-dessous APRES avoir hébergé
# le fichier .arr à une URL publique :
#
#   import url-file("https://raw.githubusercontent.com/USER/ai-ml-course/main/spell-checker/dictionaries/WORDS-S-FR.arr") as DS
#   WORDS-S-FR = build-bk-tree(DS.WORDS-S)
#
# Le format attendu : le fichier .arr définit WORDS-S comme une
# List<String> littérale, p. ex. :  WORDS-S = [list: " ... ", ... ]

# WORDS-M-FR — chargé à la demande depuis dictionaries/WORDS-M-FR.arr
# (fichier d'accompagnement, non embarqué pour garder ce starter léger).
# Pour l'utiliser, décommentez l'import ci-dessous APRES avoir hébergé
# le fichier .arr à une URL publique :
#
#   import url-file("https://raw.githubusercontent.com/USER/ai-ml-course/main/spell-checker/dictionaries/WORDS-M-FR.arr") as DM
#   WORDS-M-FR = build-bk-tree(DM.WORDS-M)
#
# Le format attendu : le fichier .arr définit WORDS-M comme une
# List<String> littérale, p. ex. :  WORDS-M = [list: " ... ", ... ]

# WORDS-L-FR — chargé à la demande depuis dictionaries/WORDS-L-FR.arr
# (fichier d'accompagnement, non embarqué pour garder ce starter léger).
# Décommenté par défaut : le dictionnaire de 40 000 mots est requis par
# l'exemple phare de la leçon (alt-words("plation", WORDS-L-FR, 4)).
# Contenu de WORDS-L-FR.arr : WORDS-L = [list: ... 40 000 mots ... ]

import url-file("https://raw.githubusercontent.com/bhuron/ai-ml-course/master/spell-checker/dictionaries/WORDS-L-FR.arr") as DL
WORDS-L-FR = build-bk-tree(DL.WORDS-L)

