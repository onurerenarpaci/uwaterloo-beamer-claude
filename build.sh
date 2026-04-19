#!/usr/bin/env bash
set -euo pipefail

OUTDIR="slide-images"
DPI=150

cd "$(dirname "$0")"

# Optional argument: slide prefix, e.g. "02" to compile only slides/02-*.tex
SLIDE_PREFIX="${1:-}"

if [[ -n "$SLIDE_PREFIX" ]]; then
  # Find the matching slide file
  SLIDE_FILE=$(ls slides/${SLIDE_PREFIX}-*.tex 2>/dev/null | head -1)
  if [[ -z "$SLIDE_FILE" ]]; then
    echo "Error: no file matching slides/${SLIDE_PREFIX}-*.tex" >&2
    exit 1
  fi
  SLIDE_STEM="${SLIDE_FILE%.tex}"   # e.g. slides/02-problem-desc
  TEX_SRC="main-single.tex"

  # Build a minimal tex that includes only the preamble + that one slide
  sed "/^\\\\input{slides\//d" main.tex \
    | sed "s|^\\\\end{document}|\\\\input{${SLIDE_STEM}}\n\\\\end{document}|" \
    > "$TEX_SRC"

  echo "Compiling single slide: $SLIDE_FILE ..."
  xelatex -interaction=nonstopmode "$TEX_SRC" > /dev/null
  xelatex -interaction=nonstopmode "$TEX_SRC" > /dev/null

  PDF_SRC="main-single.pdf"
else
  TEX_SRC="main.tex"
  PDF_SRC="main.pdf"

  echo "Compiling..."
  xelatex -interaction=nonstopmode main.tex > /dev/null
  xelatex -interaction=nonstopmode main.tex > /dev/null
fi

echo "Converting slides to images..."
mkdir -p "$OUTDIR"
rm -f "$OUTDIR"/slide-*.png

pdftoppm -r "$DPI" -png "$PDF_SRC" "$OUTDIR/slide"

# pdftoppm names files slide-1.png, slide-2.png, etc. — zero-pad for sorting
for f in "$OUTDIR"/slide-*.png; do
  base="${f##*/}"           # slide-3.png
  num="${base#slide-}"      # 3.png
  num="${num%.png}"         # 3
  padded=$(printf "%03d" "$num")
  new="$OUTDIR/slide-${padded}.png"
  [[ "$f" != "$new" ]] && mv "$f" "$new"
done

count=$(ls "$OUTDIR"/slide-*.png | wc -l | tr -d ' ')
echo "Done — $count slides in $OUTDIR/"
