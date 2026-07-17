### A Pluto.jl notebook ###
# v1.0.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ a0000000-0000-0000-0000-000000000000
begin
	using PlutoUI
end

# ╔═╡ a0000000-0000-0000-0000-000000000001
md"""
# 🔤 Algorithmes pilotés par les données
## Correction orthographique en français

Ce notebook explore le fonctionnement d'un correcteur orthographique adapté au **français** :
- **Accents** : é, è, ê, ë, à, â, ç, ù, û, ü, ô, î, ï, æ, œ
- **Lettres muettes** : parlent, chanter, prix…
- **Homophones** : a/à, ou/où, et/est, son/sont…

> 📘 Adapté de *Bootstrap World* (Fall 2026), licence CC BY 4.0.
"""

# ╔═╡ a0000000-0000-0000-0000-000000000002
md"""
## 0. L'alphabet français

L'anglais a 26 lettres. Le français en a beaucoup plus. Pour notre correcteur :

| Alphabet | Lettres | Usage |
|:---------|:--------|:------|
| **Simple** | 26 + 6 accents (é, è, ê, à, ù, ç) = 32 | Démonstrations rapides |
| **Complet** | 26 + 18 caractères accentués = 44 | Recherche exhaustive |

En français, une erreur très fréquente est l'oubli d'accent (`ecole` → `école`).
Notre correcteur doit pouvoir transformer `e` en `é` (1 édition : substitution).
"""

# ╔═╡ a0000000-0000-0000-0000-000000000003
ALPHABET_SIMPLE = [
    'a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','o','p','q','r','s','t','u','v','w','x','y','z',
    'é','è','ê','à','ù','ç'
]

# ╔═╡ a0000000-0000-0000-0000-000000000004
ALPHABET_COMPLET = [
    'a','b','c','d','e','f','g','h','i','j','k','l','m',
    'n','o','p','q','r','s','t','u','v','w','x','y','z',
    'à','â','é','è','ê','ë','î','ï','ô','ö','ù','û','ü',
    'ç','æ','œ'
]

# ╔═╡ a0000000-0000-0000-0000-000000000005
@show length(ALPHABET_SIMPLE) length(ALPHABET_COMPLET)

# ╔═╡ a0000000-0000-0000-0000-000000000006
md"""
## 1. La phrase mystère

Voici une phrase qui contient **4 erreurs** de 4 types différents :

> **« Le chein aboit si for que tout le vossinage écoute. »**

Avec votre voisin·e, essayez de repérer et corriger chaque mot, puis cliquez ci-dessous.
"""

# ╔═╡ a0000000-0000-0000-0000-000000000007
md"""
$(PlutoUI.Details("🔍 Voir les 4 erreurs", md"""
| Mot erroné | Correction | Type d'erreur | Description |
|:-----------|:-----------|:--------------|:------------|
| **chein** | chien | Échange (swap) | `e` et `i` inversées |
| **aboit** | aboie | Substitution | `t` au lieu de `e` |
| **for** | fort | Suppression | `t` final oublié |
| **vossinage** | voisinage | Insertion | `s` en trop |
"""))
"""

# ╔═╡ a0000000-0000-0000-0000-000000000008
md"""
> 💡 Les humains utilisent le **contexte** et l'**expérience**. Un ordinateur n'a qu'un algorithme et un dictionnaire.
"""

# ╔═╡ a0000000-0000-0000-0000-000000000009
md"""
## 2. Les quatre opérations (distance d'édition = 1)

| Opération | Principe | Exemple |
|:----------|:---------|:--------|
| **Substitution** | Remplacer 1 lettre | `chein` → `chien` |
| **Échange** (swap) | Inverser 2 lettres adjacentes | `chein` → `chien` |
| **Insertion** | Ajouter 1 lettre | `aboi` → `aboie` |
| **Suppression** | Enlever 1 lettre | `vossinage` → `voisinage` |
"""

# ╔═╡ a0000000-0000-0000-0000-000000000010
md"""
### 2.1 Substitution
"""

# ╔═╡ a0000000-0000-0000-0000-000000000011
function substitutions(mot::String, alphabet::Vector{Char})
    variantes = String[]
    for (i, c) in enumerate(mot)
        avant = i > 1 ? mot[1:i-1] : ""
        apres = i < length(mot) ? mot[i+1:end] : ""
        for lettre in alphabet
            if lettre != c
                push!(variantes, string(avant, lettre, apres))
            end
        end
    end
    return unique(variantes)
end

# ╔═╡ a0000000-0000-0000-0000-000000000012
let
    r = substitutions("chein", ALPHABET_SIMPLE)
    @show length(r)
    @show "chien" ∈ r
    @show r[1:min(8, end)]
end

# ╔═╡ a0000000-0000-0000-0000-000000000013
md"""
### 2.2 Échange (swap)
"""

# ╔═╡ a0000000-0000-0000-0000-000000000014
function echanges(mot::String)
    variantes = String[]
    for i in 1:length(mot)-1
        avant = i > 1 ? mot[1:i-1] : ""
        apres = i < length(mot)-1 ? mot[i+2:end] : ""
        push!(variantes, string(avant, mot[i+1], mot[i], apres))
    end
    return variantes
end

# ╔═╡ a0000000-0000-0000-0000-000000000015
let
    r = echanges("chein")
    @show r
    @show "chien" ∈ r
end

# ╔═╡ a0000000-0000-0000-0000-000000000016
md"""
### 2.3 Insertion
"""

# ╔═╡ a0000000-0000-0000-0000-000000000017
function insertions(mot::String, alphabet::Vector{Char})
    variantes = String[]
    for i in 0:length(mot)
        avant = i > 0 ? mot[1:i] : ""
        apres = i < length(mot) ? mot[i+1:end] : ""
        for lettre in alphabet
            push!(variantes, string(avant, lettre, apres))
        end
    end
    return unique(variantes)
end

# ╔═╡ a0000000-0000-0000-0000-000000000018
let
    r = insertions("aboi", ALPHABET_SIMPLE)
    @show length(r)
    @show "aboie" ∈ r
    exemples = filter(x -> startswith(x, "a") || endswith(x, "e"), r)
    @show exemples[1:min(8, end)]
end

# ╔═╡ a0000000-0000-0000-0000-000000000019
md"""
### 2.4 Suppression
"""

# ╔═╡ a0000000-0000-0000-0000-000000000020
function suppressions(mot::String)
    variantes = String[]
    for i in 1:length(mot)
        push!(variantes, string(mot[1:i-1], mot[i+1:end]))
    end
    return unique(variantes)
end

# ╔═╡ a0000000-0000-0000-0000-000000000021
let
    r = suppressions("vossinage")
    @show length(r)
    @show "voisinage" ∈ r
    @show r
end

# ╔═╡ a0000000-0000-0000-0000-000000000022
md"""
## 3. Le dictionnaire

100 mots français courants de 5 lettres. Des dictionnaires plus grands (5 000, 13 000, 40 000 mots) sont dans `dictionaries/`.
"""

# ╔═╡ a0000000-0000-0000-0000-000000000023
const DICO_XS = Set([
    "abîme","abord","abris","actif","adore","aider","aigle","aimer",
    "aller","amour","appel","arbre","asile","assez","atome","aussi",
    "autre","avant","avoir","bague","belle","bêtes","blanc","bleue",
    "boire","bonne","bruit","calme","carte","cause","champ","chant",
    "chaud","chien","choix","coule","court","danse","dette","douce",
    "durer","écart","école","écrit","égale","envie","essai","étude",
    "faire","faute","femme","fleur","force","forme","frais","fruit",
    "garde","geste","glace","grand","haute","homme","idées","jardin",
    "jeune","jouer","juger","juste","large","libre","linge","livre",
    "longs","louer","lutte","mains","maman","mange","mardi","masse",
    "mener","mieux","monde","morte","moule","murer","nager","noble",
    "noire","noter","noyer","objet","ombre","orage","ordre","oubli",
    "parle","parti","passe","patte","peine","pense","perte","peuple",
    "piste","place","plage","plein","pluie","porte","poser","poule",
    "prend","prête","prive","proie","prose","quête","rêver","ronde",
    "rouge","sable","saint","salle","scène","séché","selon","serré",
    "seule","siège","signe","singe","sorte","souci","sourd","style",
    "suite","table","tâche","terre","tirer","titre","tombe","trace",
    "train","trame","triste","trois","usage","vague","valse","venir",
    "vente","verse","vider","ville","vivre","voile","voler",
])

# ╔═╡ a0000000-0000-0000-0000-000000000024
@show length(DICO_XS)

# ╔═╡ a0000000-0000-0000-0000-000000000025
md"""
## 4. Le filtre

Parmi toutes les variantes, seules certaines sont de vrais mots français.
"""

# ╔═╡ a0000000-0000-0000-0000-000000000026
function mots_reels(variantes::Vector{String}, dico::Set{String})
    uniques = unique(filter(v -> !isempty(v), variantes))
    return filter(mot -> mot ∈ dico, uniques)
end

# ╔═╡ a0000000-0000-0000-0000-000000000027
let
    toutes = substitutions("chein", ALPHABET_SIMPLE)
    reelles = mots_reels(toutes, DICO_XS)
    @show length(toutes) length(reelles)
    @show reelles
end

# ╔═╡ a0000000-0000-0000-0000-000000000028
md"""
## 5. Le correcteur complet

`mots_alternatifs(mot, dico, distance, alphabet)` combine tout de façon **récursive**.
"""

# ╔═╡ a0000000-0000-0000-0000-000000000029
function mots_alternatifs(
    mot::String,
    dico::Set{String},
    distance::Int,
    alphabet::Vector{Char},
)
    if distance <= 0
        return mot ∈ dico ? [mot] : String[]
    end
    toutes = unique(vcat(
        substitutions(mot, alphabet),
        echanges(mot),
        insertions(mot, alphabet),
        suppressions(mot),
    ))
    distance_1 = mots_reels(toutes, dico)
    if distance == 1
        return distance_1
    else
        plus_profonds = String[]
        for w in distance_1
            append!(plus_profonds, mots_alternatifs(w, dico, distance - 1, alphabet))
        end
        return unique(vcat(distance_1, plus_profonds))
    end
end

# ╔═╡ a0000000-0000-0000-0000-000000000030
md"""
## 6. Test : la phrase mystère
"""

# ╔═╡ a0000000-0000-0000-0000-000000000031
md"""
### `"chein"` → ?
"""

# ╔═╡ a0000000-0000-0000-0000-000000000032
mots_alternatifs("chein", DICO_XS, 1, ALPHABET_SIMPLE)

# ╔═╡ a0000000-0000-0000-0000-000000000033
md"""
### `"aboit"` → ?
"""

# ╔═╡ a0000000-0000-0000-0000-000000000034
mots_alternatifs("aboit", DICO_XS, 1, ALPHABET_SIMPLE)

# ╔═╡ a0000000-0000-0000-0000-000000000035
md"""
### `"for"` → ?
"""

# ╔═╡ a0000000-0000-0000-0000-000000000036
mots_alternatifs("for", DICO_XS, 1, ALPHABET_SIMPLE)

# ╔═╡ a0000000-0000-0000-0000-000000000037
md"""
### `"vossinage"` → ?
"""

# ╔═╡ a0000000-0000-0000-0000-000000000038
mots_alternatifs("vossinage", DICO_XS, 1, ALPHABET_SIMPLE)

# ╔═╡ a0000000-0000-0000-0000-000000000039
md"""
## 7. Testez vos propres mots !
"""

# ╔═╡ a0000000-0000-0000-0000-000000000040
@bind mot_a_tester PlutoUI.TextField(default="ecole")

# ╔═╡ a0000000-0000-0000-0000-000000000041
@bind distance_max PlutoUI.Slider(1:4; default=1, show_value=true)

# ╔═╡ a0000000-0000-0000-0000-000000000042
let
    mot = strip(mot_a_tester)
    if isempty(mot)
        md"*Entrez un mot ci-dessus…*"
    else
        r = mots_alternatifs(mot, DICO_XS, distance_max, ALPHABET_SIMPLE)
        if isempty(r)
            md"""**Aucun résultat** pour `"$mot"` à distance ≤ $distance_max."""
        else
            md"""**Suggestions** (distance ≤ $distance_max, $(length(r)) résultat(s)) : **$(join(r, ", "))**"""
        end
    end
end

# ╔═╡ a0000000-0000-0000-0000-000000000043
md"""
## 8. Même algorithme, données différentes
"""

# ╔═╡ a0000000-0000-0000-0000-000000000044
const DICO_TINY = Set([
    "chien","chat","oiseau","poisson","cheval",
    "vache","mouton","cochon","lapin","canard",
    "poule","aigle","serpent","tigre","lion",
    "force","forte","forêt","forme","forge",
])

# ╔═╡ a0000000-0000-0000-0000-000000000045
let
    mot = "chian"
    r_xs = mots_alternatifs(mot, DICO_XS, 1, ALPHABET_SIMPLE)
    r_tiny = mots_alternatifs(mot, DICO_TINY, 1, ALPHABET_SIMPLE)
    md"""
    **Correction de `"$mot"` :**

    | Dictionnaire | Taille | Résultats |
    |:-------------|:-------|:-----------|
    | DICO_XS | $(length(DICO_XS)) mots | $(join(r_xs, ", ")) |
    | DICO_TINY | $(length(DICO_TINY)) mots | $(join(r_tiny, ", ")) |

    > 💡 **Même algorithme, données différentes → résultats différents.**
    > C'est le principe fondamental des algorithmes pilotés par les données.
    """
end

# ╔═╡ a0000000-0000-0000-0000-000000000046
md"""
## 9. À retenir

1. **Algorithme piloté par les données** : sa qualité dépend de la représentativité des données.
2. **Distance d'édition** : nombre minimal de modifications pour passer d'un mot à un autre.
3. **Le français est plus difficile** que l'anglais : accents, lettres muettes, homophones.
4. **Même algorithme + données différentes = résultats différents.**

### 🤔 Pour aller plus loin
- Et si `e→é` coûtait moins cher que `e→x` (pondération des substitutions) ?
- Comment les correcteurs modernes combinent-ils distance d'édition et modèles de langue ?
- Pourquoi `a→à` ou `ou→où` sont-ils impossibles à corriger avec la seule distance d'édition ?
"""

# ╔═╡ a0000000-0000-0000-0000-000000000047
md"""
---

*Adapté de [Bootstrap World](https://www.bootstrapworld.org/) (Fall 2026), licence CC BY 4.0.*
*Notebook Pluto.jl — implémentation Julia autonome.*
"""

# ╔═╡ Cell order:
# ╠═a0000000-0000-0000-0000-000000000000
# ╟─a0000000-0000-0000-0000-000000000001
# ╟─a0000000-0000-0000-0000-000000000002
# ╠═a0000000-0000-0000-0000-000000000003
# ╠═a0000000-0000-0000-0000-000000000004
# ╠═a0000000-0000-0000-0000-000000000005
# ╟─a0000000-0000-0000-0000-000000000006
# ╟─a0000000-0000-0000-0000-000000000007
# ╟─a0000000-0000-0000-0000-000000000008
# ╟─a0000000-0000-0000-0000-000000000009
# ╟─a0000000-0000-0000-0000-000000000010
# ╠═a0000000-0000-0000-0000-000000000011
# ╠═a0000000-0000-0000-0000-000000000012
# ╟─a0000000-0000-0000-0000-000000000013
# ╠═a0000000-0000-0000-0000-000000000014
# ╠═a0000000-0000-0000-0000-000000000015
# ╟─a0000000-0000-0000-0000-000000000016
# ╠═a0000000-0000-0000-0000-000000000017
# ╠═a0000000-0000-0000-0000-000000000018
# ╟─a0000000-0000-0000-0000-000000000019
# ╠═a0000000-0000-0000-0000-000000000020
# ╠═a0000000-0000-0000-0000-000000000021
# ╟─a0000000-0000-0000-0000-000000000022
# ╠═a0000000-0000-0000-0000-000000000023
# ╠═a0000000-0000-0000-0000-000000000024
# ╟─a0000000-0000-0000-0000-000000000025
# ╠═a0000000-0000-0000-0000-000000000026
# ╠═a0000000-0000-0000-0000-000000000027
# ╟─a0000000-0000-0000-0000-000000000028
# ╠═a0000000-0000-0000-0000-000000000029
# ╟─a0000000-0000-0000-0000-000000000030
# ╟─a0000000-0000-0000-0000-000000000031
# ╠═a0000000-0000-0000-0000-000000000032
# ╟─a0000000-0000-0000-0000-000000000033
# ╠═a0000000-0000-0000-0000-000000000034
# ╟─a0000000-0000-0000-0000-000000000035
# ╠═a0000000-0000-0000-0000-000000000036
# ╟─a0000000-0000-0000-0000-000000000037
# ╠═a0000000-0000-0000-0000-000000000038
# ╟─a0000000-0000-0000-0000-000000000039
# ╟─a0000000-0000-0000-0000-000000000040
# ╟─a0000000-0000-0000-0000-000000000041
# ╟─a0000000-0000-0000-0000-000000000042
# ╟─a0000000-0000-0000-0000-000000000043
# ╠═a0000000-0000-0000-0000-000000000044
# ╟─a0000000-0000-0000-0000-000000000045
# ╟─a0000000-0000-0000-0000-000000000046
# ╟─a0000000-0000-0000-0000-000000000047
