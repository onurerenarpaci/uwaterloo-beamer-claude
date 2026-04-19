# Beamer Presentation — Agent Context

## Project structure

```
uwaterloo-beamer-claude/
├── main.tex                            # Root document: preamble, metadata, \input chain
├── beamercolorthemeuwaterloo.sty       # Color theme — edit here to retheme everything
├── build.sh                            # Compile PDF and export slide-images/
├── slides/                             # One file per section/topic (NN-name.tex)
├── components/                         # Reusable TikZ/LaTeX definitions
│   ├── uw-fonts.tex                 # UW typography — fontspec config, requires XeLaTeX
│   ├── graph-styles.tex             # Node and edge styles for all graphs
│   ├── uw-headline.tex             # UW four-segment gold stripe at top of every slide
│   └── drawings.tex                # \drawing / \drawingnode macros for Simon Oya art
├── drawings/                        # Simon Oya character & object PNGs (see catalog below)
├── generated-icons/                 # AI-generated icons (transparent PNG, monochrome flat art)
└── slide-images/                    # Auto-generated PNGs (one per slide)
    ├── slide-001.png
    └── ...
```

## How the files connect

- `main.tex` is the only compilable entry point (`pdflatex main.tex`).
- Every slide file lives in `slides/` and is pulled in via `\input{slides/NN-name}` in `main.tex`, in presentation order.
- Every component file lives in `components/` and is pulled in via `\input{components/name}` in the **preamble** of `main.tex`, before `\begin{document}`.

## Modifying the presentation

### Adding a new slide section
1. Create `slides/NN-topic.tex` (use a two-digit prefix to keep order explicit).
2. Add `\input{slides/NN-topic}` to `main.tex` in the desired position.
3. Start the file with `\section{...}` then one or more `\begin{frame}...\end{frame}` blocks.

### Adding a new reusable component
1. Create `components/my-component.tex` with `\tikzset{...}`, macros, or environments.
2. Add `\input{components/my-component}` to the preamble of `main.tex`.
3. Use the defined styles/macros in any slide file.

### Modifying an existing component
- Edit the relevant file in `components/`. The change propagates to every slide that uses it automatically on the next compile.
- Do **not** redefine styles inline inside a slide file — keep all shared definitions in `components/`.

## Typography

All font configuration lives in `components/uw-fonts.tex`. The project uses **XeLaTeX** (not pdflatex) to access system fonts via `fontspec`. Build with `./build.sh`.

| UW Brand Font | System font used | Role in slides |
|---|---|---|
| Bureau Grotesque | **Barlow Condensed ExtraBold** (local `fonts/`) | Frame titles, presentation title, section TOC, block titles |
| Le Monde Livre | **Georgia** | Body text, author, institute, date |
| Typ1451 | **Verdana** (`\uwcaption`) | Captions, footnotes, small labels |

**Usage in slides:**
- Frame titles and the title slide automatically use Avenir Next Condensed Heavy — no extra commands needed.
- For Verdana captions inline: wrap text with `{\uwcaption\small Caption text}`.
- Do **not** load `fontenc`, `inputenc`, or `lmodern` — these conflict with fontspec/XeLaTeX.
- Barlow Condensed TTF files live in `fonts/` (downloaded from Google Fonts) — no system installation needed.
- Do **not** use `pdflatex` — it cannot load system fonts. The build script uses `xelatex`.

## Color theme

All colors live in `beamercolorthemeuwaterloo.sty`. To change the look of the entire presentation, edit only the six palette colors at the top of that file:

| Variable | Default | Role |
|---|---|---|
| `primary` | `#FED34C` | UW gold — accents, blocks, title bg |
| `secondary` | `#000000` | Black — frametitle, footer |
| `accent` | `#F2EDA8` | Pale gold — light highlights |
| `success` | `#5CB85C` | Green — example blocks |
| `neutral` | `#AAAAAA` | Gray — muted elements |
| `bg` | `#F5F6FA` | Off-white — block body backgrounds |

Graph component colors (`nodeblue`, `nodered`, `nodegreen`, `nodegray`, `edgecolor`) are aliased to the palette — changing `secondary` or `accent` above automatically updates graph node colors too.

Do **not** add `\definecolor` calls to `main.tex` or slide files — all color definitions belong in `beamercolorthemeuwaterloo.sty`.

### `components/uw-headline.tex`
Replaces the default Madrid navigation headline with the UW four-segment gold stripe that appears at the top of every slide. The stripe colors (`uw stripe 1`–`4`) are defined as Beamer color slots in `beamercolorthemeuwaterloo.sty`, so adjusting the palette there automatically updates the stripe.

| Segment | Color | Hex |
|---|---|---|
| 1 (leftmost) | Dark gold | `#C49A00` |
| 2 | UW gold | `#FED34C` |
| 3 | Light gold | `#F5E07A` |
| 4 (rightmost) | Pale yellow | `#FAF0B0` |

To adjust stripe height, change the `ht=5pt` value in each `\begin{beamercolorbox}` line.

## Existing components

### `components/drawings.tex`
Provides `\drawing` and `\drawingnode` macros for Simon Oya's character/object illustrations (source: https://simonoya.com/drawings/). All image files live in `drawings/` at the project root.

**Rule: whenever a slide depicts a participant, character, or adversary, use a Simon Oya drawing instead of a plain text label or node.**

**Sprite sheet:** `drawings/sprites-v0.png` contains every drawing in one image — read it with the Read tool to visually browse and decide which file to use before writing any slide code.

#### Macros

| Macro | Signature | Purpose |
|---|---|---|
| `\drawing` | `[height=1.2cm]{file-stem}` | Inline image, `file-stem` is the filename without `.png` |
| `\drawingnode` | `[height=1.2cm]{node-name}{(x,y)}{file-stem}` | TikZ node wrapping a drawing |

**Size guidance:** The drawings are low-resolution pixel art. Keep them small — `height=1.2cm` (the default) is the right scale for most uses. Do not exceed `height=1.8cm` or they will appear blurry and pixelated on the slide. When in doubt, use the default and omit the optional size argument entirely.

**Example:**
```latex
% Inline — use default size, no size argument needed
\drawing{a01-alice}

% In a TikZ picture — use default size
\begin{tikzpicture}
  \drawingnode{alice}{(0,0)}{a01-alice}
  \drawingnode{bob}{(4,0)}{a02-bob}
  \draw[gedge directed] (alice) -- (bob);
\end{tikzpicture}
```

#### Character catalog

**Named characters** — use these for protocol participants and role-play scenarios:

| File stem | Character | Suggested use |
|---|---|---|
| `a01-alice` | Alice (neutral) | Party A / initiator |
| `a02-bob` | Bob (neutral) | Party B |
| `a03-carol` | Carol | Party C |
| `a04-dave` | Dave | Party D |
| `a05-ca` | Certificate Authority | Trusted third party |
| `a06-eve` | Eve | Passive eavesdropper |
| `a07-mallory` | Mallory | Active adversary |
| `a08-ca-evil` | Evil CA | Corrupt authority |
| `a09-other` | Generic other party | Additional participants |
| `a24-adv` | Adversary (neutral) | Generic attacker |
| `a25-adv-doubt` | Adversary (doubting) | Uncertain attacker |
| `a25-adv-evil` | Adversary (evil) | Malicious attacker |
| `a26-adv-hood` | Adversary (hooded) | Anonymous/hidden attacker |
| `a27-oracle` | Oracle | Ideal functionality / trusted oracle |
| `a50-provider` | Service provider | Server-side entity |
| `a51-provider-blind` | Blind provider | Provider who cannot see data |
| `a52-provider-happy` | Happy provider | Cooperative provider |
| `a53-provider-evil` | Evil provider | Malicious server |

**Character emotional states** (Alice variants):

| File stem | State |
|---|---|
| `a10-alice-happy` | Happy / success |
| `a11-alice-sad` | Sad / failure |
| `a12-alice-thief` | Alice as thief (dishonest party) |
| `a13-alice-evil` | Alice as adversary |
| `a14-alice-hidden` | Alice hiding information |
| `a19-alice-yay` | Alice celebrating |

**Team variants** (red = attacker, blue = defender):

| File stem | Character |
|---|---|
| `a15-dave-redteam` | Dave (red team / attacker) |
| `a16-alice-redteam` | Alice (red team) |
| `a17-bob-blueteam` | Bob (blue team / defender) |
| `a18-carol-blueteam` | Carol (blue team) |

**Generic expressive characters** (use when no named role is needed):

| File stem | Expression |
|---|---|
| `a40-char-confused` | Confused |
| `a41-char-excited` | Excited |
| `a42-char-phone` | On the phone |
| `a43-char-scared` | Scared |
| `a44-char-happy` | Happy |
| `a45-char-lookingdown` | Looking down |
| `a46-char-thinking` | Thinking |
| `a47-chars-agree` | Two characters agreeing |
| `a48a-people1` / `a48b-people2` / `a49-people3` | Groups of people |

**Celebrating variants** (post-protocol success):
`a19-alice-yay`, `a20-bob-yay`, `a21-carol-yay`, `a22-dave-yay`, `a23-mallory-yay`

#### Object/icon catalog (selected)

| File stem | Object |
|---|---|
| `b01-key-pri-a` … `b16-key-kdc` | Cryptographic keys (private, public, signing, etc.) |
| `c01-msg1` … `c16-msg8op` | Message scrolls / protocol messages |
| `d01-server` … `d05-honeypot` | Servers and network devices |
| `d06-computer` / `d07-smartphone` | End-user devices |
| `d10-router` / `d22-firewall` | Network infrastructure |
| `d52-cloud` | Cloud / remote service |
| `e01-lock` | Lock (encryption) |
| `e20-shield` | Security / protection |
| `e03-virus_happy` / `e04-virus_sad` | Malware |
| `d43-dataset-psi1` … `d50-dataset-matched` | Dataset and PSI result visualisations |

### Generated icons (`generated-icons/`)

When Simon Oya's library lacks a needed icon, generate one with the `mcp__openai-gpt-image-mcp__create-image` MCP tool and save it to `generated-icons/`.

**Rules for generated icons:**
- Always use `background: transparent` and `output_format: png`.
- Prompt for **monochrome** (black and white only, no gradients, no color fills).
- Request **clean flat vector-art style** — smooth geometric shapes, no pixel art.
- Save to `generated-icons/<descriptive-name>.png`.
- Use `\includegraphics[height=Xcm]{generated-icons/my-icon}` in slides — the `\drawing` macro is for Simon's files only.

**Standard prompt template:**
```
A clean minimal flat icon of [SUBJECT]. Monochrome, black and white only. Smooth crisp vector-art style,
clean geometric shapes, no gradients, no text, no shadows. Transparent background. Square canvas, centered.
```

**Generated icon catalog:**

| Filename | Subject | Used for |
|---|---|---|
| `venn-intersection.png` | Two overlapping circles, filled intersection | Private Set Intersection concept |
| `institution-university.png` | Classical columned building | University target in attack diagrams |
| `institution-hospital.png` | Hospital building with cross | Hospital target in attack diagrams |
| `institution-bank.png` | Bank building with vault/dollar | Bank target in attack diagrams |
| `server-rack.png` | Server rack with three units and stand | Aggregator / data server icon |

### `components/graph-styles.tex`
Defines TikZ styles for graph visualisations. Use these in every graph rather than inline styles.

| Style | Purpose |
|---|---|
| `gnode` | Default circular node (blue) |
| `gnode highlight` | Active / target node (red) |
| `gnode visited` | Processed / inactive node (gray) |
| `gedge` | Undirected edge |
| `gedge directed` | Directed edge with arrowhead |
| `gedge highlight` | Emphasised edge (red, thicker) |
| `elabel` | Small white-background label on an edge |
| `graph canvas` | Environment style — apply to `tikzpicture` for consistent defaults |

**Example usage:**
```latex
\begin{tikzpicture}[graph canvas, node distance=1.8cm]
  \node (A) {A};
  \node (B) [right of=A] {B};
  \node[gnode highlight] (C) [right of=B] {C};
  \draw[gedge directed] (A) -- (B);
  \draw[gedge highlight, ->] (B) -- node[elabel]{5} (C);
\end{tikzpicture}
```

## Viewing slide output

Run `./build.sh` to compile the PDF and export every slide as a PNG:

```
slide-images/
├── slide-001.png   # title page
├── slide-002.png   # outline
├── slide-003.png   # first content slide
└── ...
```

Slide numbers in `slide-images/` match PDF page order. To inspect a specific slide, read the corresponding PNG with the Read tool — e.g. to see slide 3:

```
Read: slide-images/slide-003.png
```

After any edit, re-run `./build.sh` (or the faster single-slide variant below) before reading images so they reflect the latest source.

### Fast single-slide compilation

When editing one section, pass its two-digit prefix to avoid recompiling the entire deck:

```bash
./build.sh 02   # compiles only slides/02-*.tex
```

The script generates a temporary `main-single.tex` (full preamble + title frame + that one slide), compiles it, and exports images to `slide-images/` exactly as the full build does. Use this for iterative work; run the full `./build.sh` before treating any slide count or numbering as authoritative, since single-slide output starts at `slide-001.png`.

## Keeping CLAUDE.md up to date

**After every change, update this file.** Specifically:
- **New component file:** add an entry to the "Existing components" section with its filename, a one-line description, and a style/macro reference table.
- **New style or macro inside an existing component:** add a row to that component's table.
- **Removed or renamed style/macro:** remove or update the corresponding row.
- **New slide section:** no entry needed here, but if the section introduces a pattern others should follow, document it.

The goal is that this file always reflects the current state of `components/` so any agent or contributor can know what is available without reading the source.

## Rules for all modifications

1. **Reuse before creating.** Check `components/` for an existing style or macro before writing a new one.
2. **No inline style definitions.** If a style will be used more than once, or could plausibly be reused, it belongs in `components/`.
3. **One concern per component file.** `graph-styles.tex` owns graph visuals. A new concern (e.g. pseudocode formatting, timeline diagrams) gets its own file.
4. **Slides contain only content.** No `\tikzset`, `\newcommand`, or package imports inside `slides/` files.
5. **Compile with pdflatex.** The project is configured for `pdflatex`. Do not add packages or libraries that require LuaLaTeX (e.g. `graphdrawing`, `\usegdlibrary`) without switching the engine in `main.tex` and documenting it here.
6. **Preserve slide order.** The numeric prefix in `slides/NN-name.tex` determines presentation order. Keep prefixes consistent and gapless when inserting new sections.
