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
MSG="${1:-Update progress report}"     # first argument, or a default

# A unique temporary directory to hold the gh-pages checkout.
WORKTREE="$(mktemp -d)/ghp"

cd "$REPO_ROOT"

# Always tidy up the temporary worktree, even if the script fails partway.
cleanup() { git worktree remove "$WORKTREE" --force 2>/dev/null || true; }
trap cleanup EXIT

# --- Step 1: commit the source to main -----------------------------------
echo "==> Committing source to main..."
git add -f "$QMD"                      # -f: report/ is gitignored, so force it
if git diff --cached --quiet; then
  echo "    (no source changes)"
else
  git commit -m "$MSG"
fi
git push origin main

# --- Step 2: render one self-contained HTML file -------------------------
# embed-resources:true inlines all CSS/JS/figures into a single .html,
# so the website is just one file with nothing else to carry around.
echo "==> Rendering report..."
quarto render "$QMD" --to html -M embed-resources:true

# --- Step 3: publish that HTML to gh-pages as index.html -----------------
echo "==> Publishing to gh-pages..."
git fetch origin gh-pages                          # get the latest remote state
git worktree add "$WORKTREE" gh-pages              # check out gh-pages elsewhere
git -C "$WORKTREE" reset --hard origin/gh-pages    # make it match the remote exactly
cp "$RENDERED" "$WORKTREE/index.html"              # Pages serves index.html at the root
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
