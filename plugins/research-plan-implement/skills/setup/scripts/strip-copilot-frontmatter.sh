#!/usr/bin/env bash
# Strip `model:` and `effort:` from the YAML frontmatter of generated skills and
# agents. Required when VS Code Copilot chat is a target: a SKILL.md carrying
# `model:` hangs Copilot on invocation, with no output and no error, and the
# session stays dead until VS Code is restarted.
#
# Run this in the target project AFTER writing the generated files. It is a
# setup-time tool — do not copy it into the project (unlike
# reference/scripts/herdr-phase.sh, which is copied verbatim).
#
#   bash "${CLAUDE_SKILL_DIR}/scripts/strip-copilot-frontmatter.sh"
#
# Defaults to .claude/skills and .claude/agents; pass directories to override.
# Idempotent, and safe to run when nothing needs stripping. Only the leading
# frontmatter block is touched — body text is never rewritten.
#
# Exit codes: 0 = clean, 1 = a field survived (bug), 2 = bad usage.

set -euo pipefail

dirs=("$@")
if [ ${#dirs[@]} -eq 0 ]; then
  dirs=(".claude/skills" ".claude/agents")
fi

present=()
for d in "${dirs[@]}"; do
  [ -d "$d" ] && present+=("$d")
done

if [ ${#present[@]} -eq 0 ]; then
  echo "strip-copilot-frontmatter: none of these directories exist: ${dirs[*]}" >&2
  echo "Run this from the project root, after the files are written." >&2
  exit 2
fi

stripped=0
scanned=0

while IFS= read -r -d '' f; do
  scanned=$((scanned + 1))
  awk '
    NR == 1 && $0 == "---" { in_fm = 1; print; next }
    in_fm && $0 == "---"   { in_fm = 0; print; next }
    in_fm && /^[[:space:]]*(model|effort)[[:space:]]*:/ { dropped++; next }
    { print }
    END { exit (dropped > 0 ? 10 : 0) }
  ' "$f" > "$f.rpi-tmp" && rc=0 || rc=$?

  if [ "$rc" -eq 10 ]; then
    mv "$f.rpi-tmp" "$f"
    stripped=$((stripped + 1))
    echo "  stripped  $f"
  elif [ "$rc" -eq 0 ]; then
    rm -f "$f.rpi-tmp"
  else
    rm -f "$f.rpi-tmp"
    echo "strip-copilot-frontmatter: awk failed on $f" >&2
    exit 1
  fi
done < <(find "${present[@]}" -type f -name '*.md' -print0)

echo "strip-copilot-frontmatter: $stripped of $scanned file(s) stripped"

# Self-check: prove no field survived anywhere in a frontmatter block.
survivors=$(
  while IFS= read -r -d '' f; do
    awk '
      NR == 1 && $0 == "---" { in_fm = 1; next }
      in_fm && $0 == "---"   { in_fm = 0; next }
      in_fm && /^[[:space:]]*(model|effort)[[:space:]]*:/ { print FILENAME ": " $0 }
    ' "$f"
  done < <(find "${present[@]}" -type f -name '*.md' -print0)
)

if [ -n "$survivors" ]; then
  echo "strip-copilot-frontmatter: FAILED — these still carry the field:" >&2
  echo "$survivors" >&2
  exit 1
fi

echo "strip-copilot-frontmatter: verified — no model:/effort: in any frontmatter"
