# uwaterloo-beamer-claude

Beamer presentation template with the University of Waterloo color theme,
typography, and a Claude Code workflow for slide-by-slide iteration.

## Quick start

1. Use this repository as a template (or clone it).
2. Edit metadata (`\title`, `\author`, ...) at the top of `main.tex`.
3. Add slide files under `slides/` named `NN-topic.tex` and `\input` them
   from `main.tex` in presentation order.
4. Build the deck and per-slide PNGs:

   ```bash
   ./build.sh           # full deck
   ./build.sh 02        # only slides/02-*.tex
   ```

   Requires `xelatex` and `pdftoppm` (poppler).

## What's included

- `beamercolorthemeuwaterloo.sty` — UW gold/black color palette.
- `components/uw-fonts.tex` — UW typography (Barlow Condensed, Georgia, Verdana).
- `components/uw-headline.tex` — UW four-segment gold stripe at the top of every slide.
- `components/graph-styles.tex` — TikZ node/edge styles for graph visuals.
- `components/drawings.tex` — `\drawing` / `\drawingnode` macros for Simon Oya's
  character/object illustrations (`simon-drawings/`).
- `fonts/` — bundled Barlow Condensed TTFs (no system install needed).

## Attribution

Images by Simon Oya: https://simonoya.com/drawings/

## Working with Claude Code

`CLAUDE.md` contains the full agent context: project structure, conventions,
the drawing catalog, and rules for adding new slides or components. Open this
repo with Claude Code and it will follow that guide automatically.

## Optional: image-generation MCP server

`CLAUDE.md` instructs the agent to generate missing icons via the
[openai-gpt-image-mcp](https://github.com/SureScaleAI/openai-gpt-image-mcp)
server. To enable it:

1. Clone and build the server:

   ```bash
   git clone https://github.com/SureScaleAI/openai-gpt-image-mcp.git
   cd openai-gpt-image-mcp
   npm install
   npm run build
   ```

2. Export the required environment variables in your shell profile:

   ```bash
   export OPENAI_API_KEY=sk-...                                # your OpenAI key
   export OPENAI_GPT_IMAGE_MCP_PATH=/absolute/path/to/openai-gpt-image-mcp
   ```

3. Launch Claude Code from this directory — it will pick up the server from
   `.mcp.json`, which references both env vars.

If you don't need icon generation, delete `.mcp.json`.
