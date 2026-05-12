#!/usr/bin/env bash
set -u

skills=(
  "anthropics/skills@frontend-design"
  "anthropics/skills@webapp-testing"
  "github/awesome-copilot@markdown-to-html"
  "jimliu/baoyu-skills@baoyu-markdown-to-html"
  "obra/superpowers@requesting-code-review"
  "obra/superpowers@receiving-code-review"
  "wshobson/agents@code-review-excellence"
)

failed=0

for skill in "${skills[@]}"; do
  printf '\n==> Installing %s\n' "$skill"
  if ! npx --yes skills add "$skill" -g -y; then
    printf 'Failed to install %s\n' "$skill" >&2
    failed=1
  fi
done

printf '\nNote: pbakaus/impeccable@frontend-design is a strong optional alternative, but it uses the same skill name as anthropics/skills@frontend-design. The default bundle keeps the Anthropic official frontend-design skill to avoid overwriting it.\n'

printf '\n==> Installed skill directories\n'
find "$HOME/.agents/skills" -maxdepth 1 -mindepth 1 -type d -print 2>/dev/null | sort || true

exit "$failed"
