#!/usr/bin/env bash
# Installs a skill from this repo into a destination directory, optionally
# limited to a subset of its references/ files.
#
# Any line in SKILL.md that links only to excluded reference files is dropped;
# lines with no reference link, or with at least one included reference link,
# are kept as-is. When --refs is omitted, all references are installed.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: install-skill.sh <skill> <dest-dir> [--refs ref1,ref2,...]

Example:
  install-skill.sh csharp-standards ~/proj/.claude/skills --refs writing-tests,persistence
EOF
}

if [[ $# -lt 2 || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 1
fi

SKILL_NAME="$(basename "$1")"
DEST_DIR="$2"
REFS=""

shift 2
while [[ $# -gt 0 ]]; do
  case "$1" in
    --refs)
      REFS="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_DIR="$REPO_ROOT/$SKILL_NAME"
SKILL_MD="$SKILL_DIR/SKILL.md"
REFS_DIR="$SKILL_DIR/references"

if [[ ! -f "$SKILL_MD" ]]; then
  echo "No SKILL.md found at $SKILL_MD" >&2
  exit 1
fi

# Build the newline-separated list of reference ids to include.
if [[ -n "$REFS" ]]; then
  INCLUDE_LIST="$(echo "$REFS" | tr ',' '\n' | sed 's/\.md$//')"
elif [[ -d "$REFS_DIR" ]]; then
  INCLUDE_LIST="$(ls "$REFS_DIR"/*.md 2>/dev/null | xargs -n1 basename | sed 's/\.md$//')"
else
  INCLUDE_LIST=""
fi

if [[ -n "$REFS" && -d "$REFS_DIR" ]]; then
  while IFS= read -r r; do
    [[ -z "$r" ]] && continue
    if [[ ! -f "$REFS_DIR/$r.md" ]]; then
      echo "Warning: reference '$r' not found in $REFS_DIR" >&2
    fi
  done <<< "$INCLUDE_LIST"
fi

OUT_DIR="$DEST_DIR/$SKILL_NAME"
mkdir -p "$OUT_DIR"

awk -v inc_list="$INCLUDE_LIST" '
  BEGIN {
    n = split(inc_list, arr, "\n")
    for (i = 1; i <= n; i++) if (arr[i] != "") include[arr[i]] = 1
  }
  {
    line = $0
    rest = line
    has_ref = 0
    match_count = 0
    while (match(rest, /references\/[A-Za-z0-9_-]+\.md/)) {
      has_ref = 1
      ref = substr(rest, RSTART, RLENGTH)
      sub(/^references\//, "", ref)
      sub(/\.md$/, "", ref)
      if (ref in include) match_count++
      rest = substr(rest, RSTART + RLENGTH)
    }
    if (!(has_ref && match_count == 0)) print line
  }
' "$SKILL_MD" > "$OUT_DIR/SKILL.md"

if [[ -d "$REFS_DIR" && -n "$INCLUDE_LIST" ]]; then
  mkdir -p "$OUT_DIR/references"
  while IFS= read -r r; do
    [[ -z "$r" ]] && continue
    if [[ -f "$REFS_DIR/$r.md" ]]; then
      cp "$REFS_DIR/$r.md" "$OUT_DIR/references/$r.md"
    fi
  done <<< "$INCLUDE_LIST"
  if [[ -z "$(ls -A "$OUT_DIR/references" 2>/dev/null)" ]]; then
    rmdir "$OUT_DIR/references"
  fi
fi

echo "Installed '$SKILL_NAME' to $OUT_DIR"
if [[ -d "$OUT_DIR/references" ]]; then
  echo "References included: $(ls "$OUT_DIR/references" | sed 's/\.md$//' | paste -sd, -)"
fi
