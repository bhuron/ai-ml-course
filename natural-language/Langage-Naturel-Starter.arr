use context url-file("https://raw.githubusercontent.com/bootstrapworld/starter-files/refs/heads/main/", "libraries/ai-library.arr")

# ══════════════════════════════════════════════════════════════════════════════
# TRAITEMENT DU LANGAGE NATUREL — FICHIER DE DÉMARRAGE (FRANÇAIS)
# ══════════════════════════════════════════════════════════════════════════════
#
# Adapté de Bootstrap World (Fall 2026) — Leçon « Working with Natural Language »
# Licence : Creative Commons 4.0 Unported (Bootstrap Community).
#
# La bibliothèque ai-library.arr de Bootstrap fournit remove-stop-words,
# normalize-text-table, etc. avec une liste de stop words ANGLAIS.
# Nous redéfinissons ci-dessous stop-words, remove-stop-words et
# normalize-text-table avec une liste de stop words FRANÇAIS.
# ══════════════════════════════════════════════════════════════════════════════

blaireau = "Le blaireau américain est un blaireau nord-américain semblable en apparence au blaireau européen, bien qu'il ne soit pas étroitement apparenté. On le trouve dans l'ouest, le centre et le nord-est des États-Unis, dans le nord du Mexique, et dans le sud du Canada jusqu'à certaines régions du sud-ouest de la Colombie-Britannique. L'habitat du blaireau américain se caractérise par des prairies ouvertes avec des proies disponibles (comme des souris, des écureuils et des marmottes)."

kangourou = "Le kangourou est un contributeur de la société australienne et l'emblème national officiel de l'Australie. Il a été une icône du folklore australien pendant de nombreux siècles. C'est l'un des meilleurs de tous, et cela depuis aussi longtemps qu'on puisse se souvenir. Il n'y en a pas beaucoup comme lui, et il n'y en aura peut-être jamais d'autres."

elephant = "L'éléphant a été un contributeur de la société thaïlandaise et son icône pendant de nombreux siècles. L'éléphant a eu un impact considérable sur la culture thaïlandaise. L'éléphant thaïlandais est l'animal national officiel de la Thaïlande. L'éléphant que l'on trouve en Thaïlande est l'éléphant indien, une sous-espèce de l'éléphant d'Asie."

girafe = "Les caractéristiques distinctives de la girafe sont son cou et ses pattes extrêmement longs, ses ossicônes en forme de cornes, et les motifs tachetés de sa fourrure. Elle est classée dans la famille des Giraffidae, avec son plus proche parent existant, l'okapi. Son aire de répartition dispersée s'étend du Tchad au nord jusqu'à l'Afrique du Sud au sud, et du Niger à l'ouest jusqu'à la Somalie à l'est."

hamster = "Les hamsters se nourrissent principalement de graines, de fruits, de végétation et occasionnellement d'insectes fouisseurs. À l'état sauvage, ils sont crépusculaires : ils cherchent leur nourriture pendant les heures crépusculaires. En captivité, cependant, ils sont connus pour mener une vie nocturne conventionnelle, se réveillant autour du coucher du soleil pour se nourrir et faire de l'exercice. Physiquement, ils ont un corps trapu avec des caractéristiques distinctives qui incluent des abajoues allongées s'étendant jusqu'à leurs épaules, qu'ils utilisent pour transporter de la nourriture vers leurs terriers, ainsi qu'une queue courte et des pattes couvertes de fourrure."

loutre = "Les loutres sont des mammifères très intelligents, semi-aquatiques, membres de la famille des mustélidés, connues pour leur nature ludique et leur rôle écologique vital. Qu'elles vivent en rivière ou en mer, elles agissent comme des espèces clés. En contrôlant les populations d'oursins, les loutres de mer protègent les forêts de kelp, qui séquestrent le carbone et soutiennent la biodiversité marine."

ours-polaire = "L'ours polaire est un grand ours originaire de l'Arctique et des régions voisines. Il est étroitement apparenté à l'ours brun, et les deux espèces peuvent s'hybrider. L'ours polaire est la plus grande espèce existante d'ours et de carnivore terrestre, les mâles adultes pesant de 300 à 800 kg. L'ours polaire a une fourrure blanche ou jaunâtre avec une peau noire et une épaisse couche de graisse."

rhinoceros = "Les rhinocéros sont parmi les plus grandes mégafaunes restantes : tous pèsent plus d'une demi-tonne à l'âge adulte. Ils ont un régime herbivore, un petit cerveau de 400 à 600 g pour des mammifères de leur taille, une ou deux cornes, et une peau épaisse de 1,5 à 5 cm, protectrice, formée de couches de collagène positionnées en structure de treillis. Ils mangent généralement des matériaux feuillus."

escargot = "Les escargots peuvent être trouvés dans une très grande variété d'environnements, y compris les fossés, les déserts et les profondeurs abyssales de la mer. Bien que les escargots terrestres puissent être plus familiers pour les profanes, les escargots marins constituent la majorité des espèces d'escargots, et ont une diversité beaucoup plus grande et une biomasse plus importante. De nombreux types d'escargots peuvent également être trouvés en eau douce."

baleine = "La baleine bleue est un mammifère marin et une baleine à fanons. Atteignant une longueur maximale confirmée de 29,9 m et pesant jusqu'à 199 tonnes, c'est le plus grand animal connu ayant jamais existé. Le corps long et élancé de la baleine bleue peut présenter diverses nuances de bleu grisâtre sur sa surface supérieure et un peu plus clair en dessous."

mystere = "L'éléphant est un contributeur de la société thaïlandaise et l'animal national officiel de la Thaïlande. Il a été une icône de la culture thaïlandaise pendant de nombreux siècles. C'est l'un des meilleurs de tous, et cela depuis aussi longtemps qu'on puisse se souvenir. Il n'y en a pas beaucoup comme lui, et il n'y en aura peut-être jamais d'autres."

# définir la table des essais, en laissant l'évaluation et les étiquettes vides
corpus =
  table:  ID, EMOJI,    DOC,    LIKED, DISLIKED, TAGS
    row: "B", "🦡", blaireau,     false,   false,  ""
    row: "E", "🐘", elephant,     false,   false,  ""
    row: "G", "🦒", girafe,       false,   false,  ""
    row: "H", "🐹", hamster,      false,   false,  ""
    row: "O", "🦦", loutre,       false,   false,  ""
    row: "P", "🐻‍❄️", ours-polaire, false,   false,  ""
    row: "R", "🦏", rhinoceros,   false,   false,  ""
    row: "S", "🐌", escargot,     false,   false,  ""
    row: "W", "🐳", baleine,      false,   false,  ""
    row: "K", "🦘", kangourou,    false,   false,  ""
    row: "?", "❓", mystere,      false,   false,  ""
  end

essai-blaireau = row-n(corpus, 0)
essai-baleine = row-n(corpus, 9)

fun image-essai(r): text(r["EMOJI"], 24, "black") end

decorated = decorate-text-table(corpus, "DOC")

computed = add-bag-cols(corpus, "DOC")

# ══════════════════════════════════════════════════════════════════════════════
# NORMALISATION DU TEXTE FRANÇAIS
# ══════════════════════════════════════════════════════════════════════════════
# La bibliothèque ai-library.arr définit remove-stop-words et
# normalize-text-table avec une liste de stop words ANGLAIS.
# Nous redéfinissons ces fonctions ci-dessous avec des stop words FRANÇAIS.

# Une liste standard de stop words français (mots courants comme "le", "et",
# "un", etc.) qui portent peu de sens et peuvent être ignorés lors de la
# comparaison de documents pour la similarité.
shadow stop-words = [list:
  "le", "la", "les", "un", "une", "des", "du", "de", "d", "l",
  "et", "ou", "mais", "donc", "or", "ni", "car",
  "que", "qui", "quoi", "dont", "où",
  "ce", "cet", "cette", "ces", "il", "elle", "ils", "elles",
  "on", "nous", "vous", "je", "tu", "me", "te", "se",
  "mon", "ma", "mes", "ton", "ta", "tes", "son", "sa", "ses",
  "notre", "nos", "votre", "vos", "leur", "leurs",
  "est", "sont", "était", "étaient", "être", "avoir", "a",
  "en", "dans", "sur", "sous", "avec", "sans", "pour",
  "par", "vers", "chez", "entre", "chez", "hors",
  "ne", "pas", "plus", "rien", "jamais", "guère",
  "aussi", "très", "bien", "tout", "tous", "toute", "toutes",
  "comme", "si", "quand", "lorsque", "pendant",
  "son", "sa", "ses", "leur", "leurs",
  "y", "en", "cela", "ça", "celui", "celle", "ceux", "celles",
  "au", "aux", "du", "des",
  "ne", "pas", "que", "se",
  "ont", "eu", "été",
  "ceci", "cela", "cela",
  "peut", "peuvent", "pour", "pourtant",
  "dont", "lequel", "laquelle", "lesquels", "lesquelles",
  "au", "aux", "celui", "celle"
]

# Redéfinition de remove-stop-words avec la liste française
# remove-stop-words :: String -> String
shadow fun remove-stop-words(s :: String) -> String:
  string-split-all(s, " ")
    .filter({(w): not(stop-words.member(w))})
    .filter(is-non-empty-string)
    .join-str(" ")
end

# Redéfinition de normalize-text-table avec notre remove-stop-words français
shadow fun normalize-text-table(t :: Table, col :: String) -> Table:
  t.transform-column(
    col,
    {(txt): remove-stop-words(remove-punct(lowercase(txt)))}
  )
end

# ══════════════════════════════════════════════════════════════════════════════

# Une chaîne pour tester ces fonctions.
vacances = "Les vacances c'est amusant ! L'une de mes choses préférées à propos des vacances c'est que j'ai le temps pour le petit-déjeuner. Qu'est-ce que tu aimes des vacances ?"

# Nous pouvons composer ces fonctions pour qu'elles travaillent ensemble.
# lowercase(remove-punct(remove-stop-words("")))

norm = normalize-text-table(corpus, "DOC")

norm-computed = add-bag-cols(norm, "DOC")

# Une nouvelle fonction pour mesurer la similarité en utilisant toutes les colonnes quantitatives
# all-cols-similarity :: Table, String -> Table
# all-cols-similarity(computed, "?")
# all-cols-similarity(norm-computed, "?")