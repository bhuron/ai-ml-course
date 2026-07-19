# AGENTS.md

French translation/adaptation of [Bootstrap World](https://www.bootstrapworld.org/) Fall 2026 AI / CS lessons. All content is in French; license is **CC BY 4.0 (Bootstrap Community)** — preserve the license header and `\fancyfoot` notice in every `.tex`.

## Layout

Each lesson lives in its own directory with one or more `.tex` sources plus an `images/` subfolder referenced by relative path in `\includegraphics`.

- `intro-ia-bootstrap.tex` (root) — *Introduction à l'IA* lesson + `images/`
- `simple-types/` — *Types de données simples* + `cahier-exercices.tex` (workbook) + `images/`
- `spell-checker/` — *Algorithmes pilotés par les données* lesson. Also contains:
  - `algorithmes-pilotés-donnees.tex` — main handout
  - `correcteur-orthographique.jl` — Pluto.jl notebook (v1.0.1), self-contained Julia implementation
  - `Spell Checker Starter File.arr` — original Pyret starter that loads Bootstrap's remote library (kept for reference)
  - `dictionaries/` — French dictionaries in **paired** formats: `WORDS-{XS,S,M,L}-FR.txt` (raw, one word per line) and `WORDS-{...}-FR.arr` (Pyret `[list: ...]` literal). Both must stay in sync and reuse the same `WORDS-<size>-FR` identifier. Sourced from Hunspell `fr_FR`, filtered to lowercase + accents.
  - `correcteur-orthographique backup 1.jl`, `... backup 1 backup 1.jl` — stale backups; do not edit or rely on them.
- The `.tex` references a self-contained `Correcteur-Orthographique-Starter.arr` (pure-Pyret reimplementation) and `simple-types-workbooks.pdf` — verify these exist before quoting them; flag if missing rather than silently inventing.

## Build

LaTeX only — no `package.json`, no test suite, no CI.

```sh
pdflatex -interaction=nonstopmode <file>.tex   # run from the file's own directory
pdflatex -interaction=nonstopmode <file>.tex   # second pass for TOC / cross-refs
```

Run from the lesson directory: `\includegraphics{images/...}` and `\img{images/...}` use relative paths, so building from elsewhere breaks image inclusion.

Required LaTeX packages (install via `tlmgr`): `libertine`, `microtype`, `babel` (french), `hyperref`, `geometry`, `enumitem`, `tabularx`, `xcolor`, `tcolorbox`, `booktabs`, `fancyhdr`, `titlesec`, `amsmath`, `amssymb`, `wrapfig` (intro-ia), `listings` (spell-checker).

`.gitignore` excludes `*.aux *.log *.out *.toc *.synctex.gz` only. **PDFs are committed** — after editing any `.tex`, recompile and commit the updated `.pdf` alongside the source.

## Running the Julia notebook

`spell-checker/correcteur-orthographique.jl` is a **Pluto.jl notebook**, not a plain script. Run it through the Pluto server (`using Pluto; Pluto.run()` then open the file), not `julia correcteur-orthographique.jl`. Only `DICO_XS` / `DICO_TINY` are inlined in the notebook; the larger dictionaries in `dictionaries/` are referenced from the lesson text but not loaded by the notebook.

## Pyret gotchas (learned the hard way — see git history)

- `string-append` takes exactly 2 args — nest calls for more.
- `import lists as L` is required for `L.filter`, `L.member`, etc. `L.flatten` does not exist — chain `L.append`.
- `for-map` returns `List<List>`; use `for-fold` to flatten.
- A fold accumulator named `all` shadows a builtin — use `acc`.
- Multi-statement function bodies and multi-statement `cases` branches must be wrapped with `block:`.
- In starter files, the `use context url-file(...)` line must stay at the very top of the file — several fixes in history are about import ordering / providing `T`, `SD` via Bootstrap `core.arr`. Don't reorder imports.

## Conventions

- Commit messages: short single line; use the `Fix: <description>` prefix for bug fixes (matches recent history).
- Section styling uses Bootstrap-derived colors (`bsblue`, `bsgreen`, `bsorange`, `bsgray`) and the custom `\img{}{}{}` macro — keep consistent across lessons.