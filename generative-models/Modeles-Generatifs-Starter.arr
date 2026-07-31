use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ai-library.arr")

# ══════════════════════════════════════════════════════════════════════════════
# MODÈLES GÉNÉRATIFS — FICHIER DE DÉMARRAGE (FRANÇAIS)
# ══════════════════════════════════════════════════════════════════════════════
#
# Adapté de Bootstrap World (Fall 2026) — Leçon « Generative Models »
# Licence : Creative Commons 4.0 Unported (Bootstrap Community).
#
# Dans la leçon originale, le corpus est la chanson enfantine anglaise
# « There Was an Old Lady Who Swallowed a Fly ». Nous utilisons son
# équivalent français : « Une vieille dame avala une mouche »,
# dont la structure en vers répétitifs est identique (une mouche, puis
# une araignée, un oiseau, un chat…).
#
# POURQUOI DES FONCTIONS -fr ?
# La bibliothèque ai-library.arr définit massage-string (mise en minuscules
# + suppression de la ponctuation) qui ne conserve que les lettres a-z/A-Z.
# Toutes les fonctions n-grammes de la bibliothèque (generate-ngrams,
# build-lang-model, completions, choose-completion, generate-from,
# next-word-probability) l'utilisent en interne. Cette fonction supprime
# TOUS les accents français (é, è, ê, à, ç, …), ce qui casserait le corpus.
# Nous fournissons donc ci-dessous des versions -fr autonomes :
#   * massage-string-fr     : conserve les accents, remplace les apostrophes
#                             par des espaces ("l'araignée" -> "l araignée")
#   * generate-ngrams-fr    : découpe le corpus en n-grammes
#   * build-lang-model-fr   : construit le modèle de langue
#   * completions-fr        : suite possibles d'un début de phrase
#   * next-word-probability-fr : probabilité qu'un mot suive un autre
#   * choose-completion-fr  : choisit les n mots suivants
#   * generate-from-fr      : génère du texte en continu
# Ces fonctions sont des copies conformes des fonctions de la bibliothèque,
# dont seule la fonction de normalisation (massage-string) diffère.
# ══════════════════════════════════════════════════════════════════════════════

# ─── Lettres françaises ───────────────────────────────────────────────────────
lettres-francaises = [list:
  "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
  "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  "à", "â", "é", "è", "ê", "ë", "î", "ï", "ô", "ö", "ù", "û", "ü",
  "ç", "æ", "œ"
]

# masse une chaîne : minuscules, apostrophes -> espaces, puis suppression
# de tout ce qui n'est ni une lettre française ni un espace.
fun massage-string-fr(w :: String) -> String:
  minuscules = string-explode(string-to-lower(w)).map(replace-newlines)
  sans-apostrophes = for fold(acc from [list: ], c from minuscules):
    if c == "'": link(" ", acc) else: link(c, acc) end
  end
  chars = L.reverse(sans-apostrophes)
  for fold(acc from "", c from chars):
    if (c == " ") or (lettres-francaises.member(c)): acc + c else: acc end
  end
end

# ─── N-grammes ────────────────────────────────────────────────────────────────
# generate-ngrams-fr :: String, Number -> Table
fun generate-ngrams-fr(corpus :: String, n :: Number) -> Table block:
  words = string-split-all(massage-string-fr(corpus), " ")
    .filter(is-non-empty-string)

  fun join-words(w-list):
    for fold(acc from "", w from w-list):
      if acc == "": w else: acc + " " + w end
    end
  end

  fun get-ngrams(w-list):
    if w-list.length() < n:
      empty
    else:
      current-ngram = join-words(w-list.take(n))
      link(current-ngram, get-ngrams(w-list.rest))
    end
  end

  ngrams = get-ngrams(words)

  counts = for fold(dict from [SD.string-dict:], ngram from ngrams):
    if dict.has-key(ngram):
      dict.set(ngram, dict.get-value(ngram) + 1)
    else:
      dict.set(ngram, 1)
    end
  end

  rows = for map(key from counts.keys().to-list()):
    [T.raw-row: {"n-gram"; key}, {"count"; counts.get-value(key)}]
  end

  T.table-from-rows
    .make(raw-array-from-list(rows))
    .order-by("count", false)
end

# ─── Modèle de langue ─────────────────────────────────────────────────────────
# build-lang-model-fr :: String -> Table
fun build-lang-model-fr(corpus :: String) -> Table:
  word-count = string-split-all(massage-string-fr(corpus), " ")
    .filter(is-non-empty-string)
    .length()

  all-rows = for fold(acc from empty, n from L.range(1, 6)):
    these-rows = for fold(rows from empty, r from generate-ngrams-fr(corpus, n).all-rows()):
      link([T.raw-row: {"size"; n}, {"n-gram"; r["n-gram"]}, {"count"; r["count"]}], rows)
    end
    acc + these-rows
  end

  T.table-from-rows
    .make(raw-array-from-list(all-rows))
    .order-by("count", false)
end

# ─── Complétions ──────────────────────────────────────────────────────────────
# completions-fr :: Model, String -> Table
fun completions-fr(model :: Table, input :: String) -> Table block:
  input-lst = string-split-all(massage-string-fr(input), " ")
    .filter(is-non-empty-string)

  input-length = input-lst.length()

  shadow input = if input-length >= 5:
    input-lst.reverse()
      .take(5)
      .reverse()
      .join-str(" ")
  else: input-lst.join-str(" ")
  end

  gram-size = num-min(string-split-all(input, " ").length() + 1, 5)

  filtered = model
    .filter({(r): (r["size"] == gram-size) and
        ((input == "") or string-starts-with(r["n-gram"], input + " "))})
    .transform-column("n-gram", {(ngram): string-split-all(ngram, " ").reverse().get(0)})

  total-count = for fold(acc from 0, r from filtered.all-rows()):
    acc + r["count"]
  end

  filtered.build-column("probability", {(r):
      if total-count == 0:
        0
      else:
        rounded-exact((r["count"] / total-count))
      end
    })
end

# ─── Probabilité du mot suivant ───────────────────────────────────────────────
# next-word-probability-fr :: Model, String, String -> Number
fun next-word-probability-fr(model :: Table, first :: String, second :: String):
  choices = completions-fr(model, first)

  total = for fold(acc from 0, r from choices.all-rows()):
    acc + r["count"]
  end

  if total == 0:
    0
  else:
    matching = choices.filter({(r): r["n-gram"] == massage-string-fr(second)})
    if matching.length() == 0:
      0
    else:
      matching.row-n(0)["count"] / total
    end
  end
end

# ─── Choisir une complétion ───────────────────────────────────────────────────
# choose-completion-fr :: Model, String, Number -> String
fun choose-completion-fr(model :: Table, input :: String, n :: Number) -> String:
  fun last-tokens(str):
    toks = string-split-all(str, " ").filter(is-non-empty-string)
    toks.reverse().take(num-min(toks.length(), 4)).reverse().join-str(" ")
  end

  fun choose-one(context):
    words = string-split-all(massage-string-fr(context), " ")
      .filter(is-non-empty-string)
    last-word = if words.length() == 0: "" else: words.reverse().get(0) end

    choices = completions-fr(model, context)
      .filter({(r): r["n-gram"] <> last-word})
    row-count = choices.length()

    if row-count == 0:
      if words.length() == 0:
        ""
      else:
        choose-one(words.rest.join-str(" "))
      end
    else if row-count == 1:
      choices.row-n(0)["n-gram"]
    else:
      choices.row-n(random(row-count))["n-gram"]
    end
  end

  fun choose-n(context, k):
    if k <= 0:
      empty
    else:
      word = choose-one(context)
      if word == "":
        empty
      else:
        link(word, choose-n(last-tokens(context + " " + word), k - 1))
      end
    end
  end

  choose-n(last-tokens(input), n).join-str(" ")
end

# ─── Génération en continu ────────────────────────────────────────────────────
fun add-next-word-fr(model :: Table, input :: String) -> String:
  input + " " + choose-completion-fr(model, input, 1)
end

fun dessiner-lignes(txt):
  fun build-image(str):
    overlay(text(str, 20, "black"),
      square(25, "solid", "transparent"))
  end

  words = string-split-all(txt, " ")
  fun build-lines(remaining, current-line):
    cases (L.List) remaining:
      | empty =>
        if current-line == "":
          empty
        else:
          [list: build-image(current-line)]
        end
      | link(word, rest) =>
        candidate =
          if current-line == "": word
          else: current-line + " " + word
          end
        if (current-line == "") or (string-length(candidate) <= 80):
          build-lines(rest, candidate)
        else:
          link(build-image(current-line), build-lines(rest, word))
        end
    end
  end
  above-align-list("left", build-lines(words, ""))
end

# generate-from-fr :: Model, String -> String
fun generate-from-fr(model :: Table, input):
  reactor:
    init: input,
    to-draw: dessiner-lignes,
    on-tick: lam(i): add-next-word-fr(model, i) end,
    seconds-per-tick: 0.1
  end
    .interact()
    .get-value()
end

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
# generate-ngrams-fr(corpus, 1)
# m = build-lang-model-fr(corpus)
# next-word-probability-fr(m, "une", "mouche")
# completions-fr(m, "une")
# choose-completion-fr(m, "une", 2)
# generate-from-fr(m, "une vieille")