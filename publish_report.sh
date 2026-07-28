#!/usr/bin/env bash
#
# publish_report.sh — update the progress report everywhere in one command.
#
# It does two things that live on two different branches:
#   1. commits report/progress_report.qmd (the source)      -> main
#   2. renders it to a self-contained HTML and publishes it -> gh-pages (the website)
#
# Usage:
#   ./publish_report.sh                       # uses a default commit message
#   ./publish_report.sh "Rewrote the results section"
#
set -euo pipefail   # stop on any error, unset var, or failed pipe

# --- Config --------------------------------------------------------------
# Resolve the repo root from this script's own location, so it works no
# matter which directory you run it from.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QMD="report/progress_report.qmd"
RENDERED="report/progress_report.html"
FIGS="report/figs"
MSG="${1:-Update progress report}"     # first argument, or a default

# A unique temporary directory to hold the gh-pages checkout.
WORKTREE="$(mktemp -d)/ghp"

cd "$REPO_ROOT"

# Always tidy up the temporary worktree, even if the script fails partway.
cleanup() { git worktree remove "$WORKTREE" --force 2>/dev/null || true; }
trap cleanup EXIT

# --- Step 1: commit the source to main -----------------------------------
# The figures are tracked too, so a fresh clone can render the report; add them
# alongside the source or main drifts out of sync with what the report needs.
echo "==> Committing source to main..."
git add "$QMD" "$FIGS"
if git diff --cached --quiet; then
  echo "    (no source changes)"
else
  git commit -m "$MSG"
fi
git push origin main

# --- Step 2: render the HTML ---------------------------------------------
# embed-resources:true inlines the CSS/JS and any figure referenced by a plain
# <img src="...">. It CANNOT inline the extrapolation examples, because those
# are chosen at runtime by the slider's JavaScript (img.src = `..._${n}.svg`)
# and Pandoc has no way to resolve that statically. Step 3 therefore ships the
# figs/ directory next to index.html so those relative paths resolve.
echo "==> Rendering report..."
quarto render "$QMD" --to html -M embed-resources:true

# --- Step 3: publish that HTML to gh-pages as index.html -----------------
echo "==> Publishing to gh-pages..."
git fetch origin gh-pages                          # get the latest remote state
git worktree add "$WORKTREE" gh-pages              # check out gh-pages elsewhere
git -C "$WORKTREE" reset --hard origin/gh-pages    # make it match the remote exactly
cp "$RENDERED" "$WORKTREE/index.html"              # Pages serves index.html at the root
rm -rf "$WORKTREE/figs"                            # drop figures deleted since last publish
cp -R "$FIGS" "$WORKTREE/figs"                     # runtime-loaded figures (see step 2)
git -C "$WORKTREE" add -A
if git -C "$WORKTREE" diff --cached --quiet; then
  echo "    (site already up to date)"
else
  git -C "$WORKTREE" commit -m "$MSG"
  git -C "$WORKTREE" push origin gh-pages
fi

echo ""
echo "==> Done. Live at https://su-jai.github.io/player_forecasting/"
echo "    Allow ~30-60s for GitHub Pages to rebuild, then hard-refresh (Cmd+Shift+R)."
