#!/usr/bin/env bash

set -e

TEMP_CSPELL_CONFIG=".cspell.json"
TEMP_FILE=$(mktemp)
CSPELL_CONFIG_URL="https://raw.githubusercontent.com/NovoNordisk-OpenSource/r.workflows/main/.github/linters/.cspell-wordlist.json"
WORDLIST_FILE="inst/WORDLIST"

echo "Fetching cspell config..."
curl --output "$TEMP_CSPELL_CONFIG" \
  --location \
  --silent \
  "$CSPELL_CONFIG_URL"

echo "Running cspell..."
npx \
  --no-update-notifier \
  --yes \
  --quiet \
cspell@9.4.0 lint \
  --config "$TEMP_CSPELL_CONFIG" \
  --words-only \
  --unique \
  --no-progress \
  --no-exit-code \
  --exclude "sample_toolbox_inputs/*" \
  "./**/*.md" \
  "./**/*.mdx" \
  "./**/*.markdown" \
  "./**/*.html" \
  "./**/*.htm" \
  "./**/*.rst" \
  "./**/*.txt" \
  "./**/*.json" \
  "./**/*.jsonc" \
  "./**/*.json5" \
  "./**/*.yaml" \
  "./**/*.yml" \
  "./**/*.qmd" \
  "./**/*.R" \
  "./**/*.r" \
  "./**/*.Rmd" \
  "./**/*.rmd" > "$TEMP_FILE"


echo "Updating inst/WORDLIST..."
cat "$WORDLIST_FILE" >> "$TEMP_FILE"

sort --unique "$TEMP_FILE" > "$WORDLIST_FILE"

rm "$TEMP_FILE" "$TEMP_CSPELL_CONFIG"

echo "inst/WORDLIST has been updated with sorted unique words."
