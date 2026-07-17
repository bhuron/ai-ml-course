### A Pluto.jl notebook ###
# v0.19.49

# ╔═╡ 00000000-0000-0000-0000-000000000001
## 1. Français vs Anglais : l'alphabet compte !
md"""

# 🔤 Algorithmes pilotés par les données

## Correction orthographique en français

Ce notebook explore comment fonctionne un correcteur orthographique.
Il est adapté au **français**, avec ses particularités :
- **Accents** : é, è, ê, ë, à, â, ç, ù, û, ü, ô, î, ï, æ, œ
- **Lettres muettes** : parlent, chanter, prix...
- **Homophones** : a/à, ou/où, et/est, son/sont...

> 📘 *Adapté de la leçon « Data-Driven Algorithms » de [Bootstrap World](https://www.bootstrapworld.org/), Fall 2026.*

"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
md"""

## 0. L'alphabet français

L'anglais a 26 lettres. Le français en a beaucoup plus à cause des **accents**.
Pour notre correcteur, on définit deux alphabets :

- **Simple** : 26 lettres + les 6 accents les plus courants (é, è, ê, à, ù, ç) → 32 caractères
- **Complet** : toutes les lettres accentuées du français → 44 caractères

En français, une erreur très fréquente est l'oubli d'accent :
- `ecole` au lieu de `école`
- `eleve` au lieu de `élève`

Notre correcteur doit pouvoir transformer `e` en `é` (1 édition : substitution),
exactement comme il transforme `k` en `l`.

"""

# ╔═╡ 00000000-0000-0000-0000-000000000003
# Alphabet simple : lettres de base + accents les plus courants
ALPHABET_SIMPLE = [
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'é', 'è', 'ê', 'à', 'ù', 'ç'
]

# Alphabet complet : toutes les lettres accentuées du français
ALPHABET_COMPLET = [
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    'à', 'â', 'é', 'è', 'ê', 'ë', 'î', 'ï', 'ô', 'ö', 'ù', 'û', 'ü',
    'ç', 'æ', 'œ'
]

@show length(ALPHABET_SIMPLE) length(ALPHABET_COMPLET);

# ╔═╡ 00000000-0000-0000-0000-000000000004
md"""

## 1. La phrase mystère

Voici une phrase qui contient **4 erreurs** de 4 types différents :

> **« Le chein aboit si for que tout le vossinage écoute. »**

Avec votre voisin·e, essayez de :
1. **Repérer** les mots mal orthographiés
2. **Corriger** chaque mot
3. **Décrire** le type d'erreur commise

Puis cliquez sur les boîtes ci-dessous pour voir les réponses 👇

"""

# ╔═╡ 00000000-0000-0000-0000-000000000005
md"""
$(Details(
    "🔍 Voir les 4 erreurs",
    md"""
| Mot erroné | Correction | Type d'erreur | Description |
|:-----------|:-----------|:--------------|:------------|
| **chein** | chien | Échange (swap) | Les lettres `e` et `i` sont inversées |
| **aboit** | aboie | Substitution | `t` tapé au lieu de `e` |
| **for** | fort | Suppression | Le `t` final est oublié |
| **vossinage** | voisinage | Insertion | Un `s` en trop |
    """
))
"""

# ╔═╡ 00000000-0000-0000-0000-000000000006
md"""

> 💡 **Quand les humains corrigent l'orthographe**, ils utilisent le contexte, l'expérience,
> et leurs connaissances. Un ordinateur, lui, n'a que... un algorithme et un dictionnaire.

"""

# ╔═╡ 00000000-0000-0000-0000-000000000007
md"""

## 2. Les quatre opérations de distance d'édition

Un correcteur orthographique travaille avec la **distance d'édition** :
le nombre de modifications nécessaires pour transformer un mot en un autre.

À **distance 1**, il y a 4 opérations possibles :

| Opération | Principe | Exemple |
|:----------|:---------|:--------|
| **Substitution** | Remplacer 1 lettre | `chein` → `chien` (e↔i) |
| **Échange** | Inverser 2 lettres adjacentes | `chein` → `chien` (e↔i échangées) |
| **Insertion** | Ajouter 1 lettre | `aboi` → `aboie` (ajouter e) |
| **Suppression** | Enlever 1 lettre | `vossinage` → `voisinage` (enlever s) |

> ⚠️ La substitution et l'échange (swap) sur la paire `ei` → `ie` produisent
> le **même résultat** ! Mais elles fonctionnent différemment :
> - **substitution** remplace une lettre par n'importe quelle autre
> - **échange** ne fait qu'inverser deux lettres adjacentes

Implémentons ces quatre opérations en Julia !

"""

# ╔═╡ 00000000-0000-0000-0000-000000000008
md"""

### 2.1 Substitution

On remplace **chaque** lettre du mot par **chaque** lettre de l'alphabet.

Pour un mot de $n$ lettres et un alphabet de $a$ lettres :
- Nombre de variantes : $n \times a$ (moins les $n$ lettres originales)
- Exemple : `"chat"` (4 lettres) × alphabet simple (32 lettres) → jusqu'à 128 variantes

"""

# ╔═╡ 00000000-0000-0000-0000-000000000009
function substitutions(mot::String, alphabet::Vector{Char})
    variantes = String[]
    for (i, c) in enumerate(mot)
        avant = i > 1 ? mot[1:i-1] : ""
        apres = i < length(mot) ? mot[i+1:end] : ""
        for lettre in alphabet
            if lettre != c  # ne pas générer le mot original
                push!(variantes, string(avant, lettre, apres))
            end
        end
    end
    return unique(variantes)
end

# ╔═╡ 00000000-0000-0000-0000-000000000010
let
    resultats = substitutions("chein", ALPHABET_SIMPLE)
    @show length(resultats)
    @show resultats[1:min(10, end)]
    @show "chien" in resultats
end

# ╔═╡ 00000000-0000-0000-0000-000000000011
md"""

### 2.2 Échange (swap)

On inverse **chaque paire** de lettres adjacentes.

Pour un mot de $n$ lettres : $n-1$ variantes.

"""

# ╔═╡ 00000000-0000-0000-0000-000000000012
function echanges(mot::String)
    variantes = String[]
    for i in 1:length(mot)-1
        avant = i > 1 ? mot[1:i-1] : ""
        apres = i < length(mot)-1 ? mot[i+2:end] : ""
        push!(variantes, string(avant, mot[i+1], mot[i], apres))
    end
    return variantes
end

# ╔═╡ 00000000-0000-0000-0000-000000000013
let
    resultats = echanges("chein")
    @show resultats
    @show "chien" in resultats
end

# ╔═╡ 00000000-0000-0000-0000-000000000014
md"""

### 2.3 Insertion

On insère **chaque** lettre de l'alphabet à **chaque** position possible.

Pour un mot de $n$ lettres et $a$ lettres dans l'alphabet : $(n+1) \times a$ variantes.

"""

# ╔═╡ 00000000-0000-0000-0000-000000000015
function insertions(mot::String, alphabet::Vector{Char})
    variantes = String[]
    for i in 0:length(mot)  # 0 = avant le mot, length = après le mot
        avant = i > 0 ? mot[1:i] : ""
        apres = i < length(mot) ? mot[i+1:end] : ""
        for lettre in alphabet
            push!(variantes, string(avant, lettre, apres))
        end
    end
    return unique(variantes)
end

# ╔═╡ 00000000-0000-0000-0000-000000000016
let
    resultats = insertions("aboi", ALPHABET_SIMPLE)
    @show length(resultats)
    @show "aboie" in resultats
    # Quelques exemples d'insertions au début et à la fin
    filter!(r -> startswith(r, "a") || endswith(r, "e"), resultats)
    @show resultats[1:min(8, end)]
end

# ╔═╡ 00000000-0000-0000-0000-000000000017
md"""

### 2.4 Suppression

On supprime **chaque** lettre du mot, une par une.

Pour un mot de $n$ lettres : $n$ variantes.

"""

# ╔═╡ 00000000-0000-0000-0000-000000000018
function suppressions(mot::String)
    variantes = String[]
    for i in 1:length(mot)
        push!(variantes, string(mot[1:i-1], mot[i+1:end]))
    end
    return unique(variantes)
end

# ╔═╡ 00000000-0000-0000-0000-000000000019
let
    resultats = suppressions("vossinage")
    @show length(resultats)
    @show "voisinage" in resultats
    @show resultats
end

# ╔═╡ 00000000-0000-0000-0000-000000000020
md"""

## 3. Le dictionnaire

On a besoin d'un dictionnaire pour savoir si un mot « existe » en français.

Celui-ci contient **100 mots français courants de 5 lettres**, sélectionnés manuellement.

> ℹ️ Des dictionnaires plus grands (5 000, 13 000, 40 000 mots) sont disponibles
> dans le dossier `dictionaries/`. Pour un notebook interactif, 100 mots
> suffisent pour des démonstrations instantanées.

"""

# ╔═╡ 00000000-0000-0000-0000-000000000021
const DICO_XS = Set([
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
    "vente", "verse", "vider", "ville", "vivre", "voile", "voler",
])

@show length(DICO_XS);

# ╔═╡ 00000000-0000-0000-0000-000000000022
md"""

## 4. Le filtre

Parmi toutes les variantes générées, seules certaines sont de « vrais » mots.
La fonction `mots_reels` filtre une liste pour ne garder que les mots du dictionnaire.

"""

# ╔═╡ 00000000-0000-0000-0000-000000000023
function mots_reels(variantes::Vector{String}, dico::Set{String})
    # Supprime les chaînes vides, dédoublonne, puis filtre par le dictionnaire
    uniques = unique(filter(v -> !isempty(v), variantes))
    return filter(mot -> mot ∈ dico, uniques)
end

# ╔═╡ 00000000-0000-0000-0000-000000000024
let
    # Toutes les substitutions de "chein", mais seulement les vrais mots
    toutes = substitutions("chein", ALPHABET_SIMPLE)
    reelles = mots_reels(toutes, DICO_XS)
    @show length(toutes) length(reelles)
    @show reelles
end

# ╔═╡ 00000000-0000-0000-0000-000000000025
md"""

## 5. Le correcteur complet

`mots_alternatifs(mot, dico, distance, alphabet)` combine tout :
1. Génère **toutes** les variantes à distance ≤ `distance`
2. Filtre pour ne garder que les mots du dictionnaire

C'est une fonction **récursive** :
- Distance 1 : on applique les 4 opérations et on filtre
- Distance > 1 : on applique récursivement la recherche à chaque résultat

"""

# ╔═╡ 00000000-0000-0000-0000-000000000026
function mots_alternatifs(
    mot::String,
    dico::Set{String},
    distance::Int,
    alphabet::Vector{Char}
)
    if distance <= 0
        return mot ∈ dico ? [mot] : String[]
    end

    # Génère toutes les variantes à distance 1
    sub = substitutions(mot, alphabet)
    ech = echanges(mot)
    ins = insertions(mot, alphabet)
    sup = suppressions(mot)
    toutes_variantes = unique(vcat(sub, ech, ins, sup))

    # Filtre par le dictionnaire → mots réels à distance 1
    distance_1 = mots_reels(toutes_variantes, dico)

    if distance == 1
        return distance_1
    else
        # Récursion : cherche à distance n-1 depuis chaque mot trouvé
        plus_profonds = String[]
        for w in distance_1
            append!(plus_profonds, mots_alternatifs(w, dico, distance - 1, alphabet))
        end
        return unique(vcat(distance_1, plus_profonds))
    end
end

# ╔═╡ 00000000-0000-0000-0000-000000000027
md"""

## 6. Testons notre correcteur !

Reprenons la phrase mystère du début :

> « Le **chein** **aboit** si **for** que tout le **vossinage** écoute. »

Essayons de corriger chaque mot un par un avec notre correcteur 👇

"""

# ╔═╡ 00000000-0000-0000-0000-000000000028
md"""

### 🔤 `"chein"` → ?

"""

# ╔═╡ 00000000-0000-0000-0000-000000000029
mots_alternatifs("chein", DICO_XS, 1, ALPHABET_SIMPLE)

# ╔═╡ 00000000-0000-0000-0000-000000000030
md"""

### 🔤 `"aboit"` → ?

"""

# ╔═╡ 00000000-0000-0000-0000-000000000031
mots_alternatifs("aboit", DICO_XS, 1, ALPHABET_SIMPLE)

# ╔═╡ 00000000-0000-0000-0000-000000000032
md"""

### 🔤 `"for"` → ?

"""

# ╔═╡ 00000000-0000-0000-0000-000000000033
mots_alternatifs("for", DICO_XS, 1, ALPHABET_SIMPLE)

# ╔═╡ 00000000-0000-0000-0000-000000000034
md"""

### 🔤 `"vossinage"` → ?

"""

# ╔═╡ 00000000-0000-0000-0000-000000000035
mots_alternatifs("vossinage", DICO_XS, 1, ALPHABET_SIMPLE)

# ╔═╡ 00000000-0000-0000-0000-000000000036
md"""

## 7. Expérimentons !

Utilisez le champ interactif ci-dessous pour tester vos propres mots mal orthographiés.
Essayez avec et sans accents, et observez comment le dictionnaire et la distance d'édition
influencent les résultats.

"""

# ╔═╡ 00000000-0000-0000-0000-000000000037
@bind mot_a_tester TextField(default="ecole")

# ╔═╡ 00000000-0000-0000-0000-000000000038
@bind distance_max Slider(1:4; default=1, show_value=true)

# ╔═╡ 00000000-0000-0000-0000-000000000039
let
    mot = strip(mot_a_tester)
    if !isempty(mot)
        resultats = mots_alternatifs(mot, DICO_XS, distance_max, ALPHABET_SIMPLE)
        if isempty(resultats)
            md"""
            **Aucun mot trouvé** dans le dictionnaire à distance ≤ $distance_max pour `"$mot"`.

            Essayez d'augmenter la distance ou de vérifier l'orthographe de base.
            """
        else
            md"""
            **Suggestions pour `"$mot"`** (distance ≤ $distance_max, $(length(resultats)) résultat(s)) :

            $(join(resultats, ", "))
            """
        end
    else
        md"*Entrez un mot ci-dessus pour commencer...*"
    end
end

# ╔═╡ 00000000-0000-0000-0000-000000000040
md"""

## 8. Pourquoi un petit dictionnaire donne de moins bons résultats

Changeons de dictionnaire pour voir l'effet. Créons un **tout petit** dictionnaire
de seulement 20 mots :

"""

# ╔═╡ 00000000-0000-0000-0000-000000000041
const DICO_TINY = Set([
    "chien", "chat", "oiseau", "poisson", "cheval",
    "vache", "mouton", "cochon", "lapin", "canard",
    "poule", "aigle", "serpent", "tigre", "lion",
    "force", "forte", "forêt", "forme", "forge"
])

# ╔═╡ 00000000-0000-0000-0000-000000000042
let
    mot = "chian"  # swap i/a → devrait donner "chien"

    r_xs = mots_alternatifs(mot, DICO_XS, 1, ALPHABET_SIMPLE)
    r_tiny = mots_alternatifs(mot, DICO_TINY, 1, ALPHABET_SIMPLE)

    md"""
    **Correction de `"$mot"` :**

    | Dictionnaire | Taille | Résultats |
    |:-------------|:-------|:-----------|
    | DICO_XS | $(length(DICO_XS)) mots | $(join(r_xs, ", ")) |
    | DICO_TINY | $(length(DICO_TINY)) mots | $(join(r_tiny, ", ")) |

    > 💡 **Même algorithme, données différentes → résultats différents.**
    > C'est le principe fondamental des **algorithmes pilotés par les données**.
    """
end

# ╔═╡ 00000000-0000-0000-0000-000000000043
md"""

## 9. À retenir

### 🔑 Points clés

1. **Algorithme piloté par les données** = algorithme dont la qualité dépend
   directement de la **représentativité** des données qu'on lui fournit.

2. **Distance d'édition** = nombre minimal de modifications (substitution, échange,
   insertion, suppression) pour passer d'un mot à un autre.

3. **Même algorithme, données différentes → résultats différents.**
   - Avec 100 mots courants : suggestions utiles
   - Avec 20 mots quelconques : suggestions aléatoires
   - Avec 40 000 mots : suggestions encore meilleures !

4. **Le français est plus difficile que l'anglais** pour la correction
   orthographique à cause des **accents**, des **lettres muettes** et des **homophones**.

### 🤔 Pour aller plus loin

- Que se passerait-il si on pondérait la distance d'édition ? (ex. `e→é` coûte
  moins cher que `e→x` car c'est une erreur plus fréquente en français)
- Comment les correcteurs modernes (dans les téléphones, navigateurs) combinent-ils
  distance d'édition et **modèles de langue** ?
- Pourquoi un correcteur ne peut-il **jamais** corriger `a` → `à` ou `ou` → `où`
  avec la seule distance d'édition ?

"""

# ╔═╡ 00000000-0000-0000-0000-000000000044
md"""

---

*Adapté de [Bootstrap World](https://www.bootstrapworld.org/) (Fall 2026), licence CC BY 4.0.*
*Notebook Pluto.jl — implémentation Julia autonome.*

"""

# ╔═╡ Cell order:
# ╠═00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
# ╠═00000000-0000-0000-0000-000000000003
# ╟─00000000-0000-0000-0000-000000000004
# ╟─00000000-0000-0000-0000-000000000005
# ╟─00000000-0000-0000-0000-000000000006
# ╟─00000000-0000-0000-0000-000000000007
# ╟─00000000-0000-0000-0000-000000000008
# ╠═00000000-0000-0000-0000-000000000009
# ╠═00000000-0000-0000-0000-000000000010
# ╟─00000000-0000-0000-0000-000000000011
# ╠═00000000-0000-0000-0000-000000000012
# ╠═00000000-0000-0000-0000-000000000013
# ╟─00000000-0000-0000-0000-000000000014
# ╠═00000000-0000-0000-0000-000000000015
# ╠═00000000-0000-0000-0000-000000000016
# ╟─00000000-0000-0000-0000-000000000017
# ╠═00000000-0000-0000-0000-000000000018
# ╠═00000000-0000-0000-0000-000000000019
# ╟─00000000-0000-0000-0000-000000000020
# ╠═00000000-0000-0000-0000-000000000021
# ╟─00000000-0000-0000-0000-000000000022
# ╠═00000000-0000-0000-0000-000000000023
# ╠═00000000-0000-0000-0000-000000000024
# ╟─00000000-0000-0000-0000-000000000025
# ╠═00000000-0000-0000-0000-000000000026
# ╟─00000000-0000-0000-0000-000000000027
# ╟─00000000-0000-0000-0000-000000000028
# ╠═00000000-0000-0000-0000-000000000029
# ╟─00000000-0000-0000-0000-000000000030
# ╠═00000000-0000-0000-0000-000000000031
# ╟─00000000-0000-0000-0000-000000000032
# ╠═00000000-0000-0000-0000-000000000033
# ╟─00000000-0000-0000-0000-000000000034
# ╠═00000000-0000-0000-0000-000000000035
# ╟─00000000-0000-0000-0000-000000000036
# ╟─00000000-0000-0000-0000-000000000037
# ╟─00000000-0000-0000-0000-000000000038
# ╟─00000000-0000-0000-0000-000000000039
# ╟─00000000-0000-0000-0000-000000000040
# ╠═00000000-0000-0000-0000-000000000041
# ╟─00000000-0000-0000-0000-000000000042
# ╟─00000000-0000-0000-0000-000000000043
# ╟─00000000-0000-0000-0000-000000000044
