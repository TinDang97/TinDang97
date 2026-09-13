#!/usr/bin/env bash
# Build both CV variants from the single source in main.tex.
#
#   main.pdf          with photo    -- Vietnam, SEA, and most of continental Europe
#   main-nophoto.pdf  without photo -- US, UK, Canada, Australia, and any employer
#                                      running blind or bias-reduced screening
#
# There is no local TeX install, so this runs pdflatex in a container.
# Requires Docker (OrbStack) to be running.
set -euo pipefail
cd "$(dirname "$0")"

run_tex() { docker run --rm -v "$PWD":/w -w /w texlive/texlive:latest pdflatex -interaction=nonstopmode "$@"; }

echo "==> main.pdf (with photo)"
run_tex main.tex >/dev/null

echo "==> main-nophoto.pdf (without photo)"
run_tex -jobname=main-nophoto '\def\nophoto{1}\input{main.tex}' >/dev/null

rm -f main.aux main.log main.out main.bcf main.run.xml \
      main-nophoto.aux main-nophoto.log main-nophoto.out main-nophoto.bcf main-nophoto.run.xml
git checkout -- pdfa.xmpi 2>/dev/null || true

for f in main.pdf main-nophoto.pdf; do
  printf '%-20s %s page(s)\n' "$f" "$(pdfinfo "$f" 2>/dev/null | awk '/^Pages:/{print $2}')"
done
