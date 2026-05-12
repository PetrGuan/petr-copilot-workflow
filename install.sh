#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
GITHUB_ROOT="${COPILOT_WORKFLOW_GITHUB_ROOT:-$HOME/Documents/GitHub}"
WORKFLOW_ROOT="${COPILOT_WORKFLOW_ROOT:-$GITHUB_ROOT/.copilot-workflow}"
BIN_DIR="${COPILOT_WORKFLOW_BIN_DIR:-$HOME/.local/bin}"
COPILOT_DIR="${COPILOT_WORKFLOW_COPILOT_DIR:-$HOME/.copilot}"

mkdir -p "$WORKFLOW_ROOT/templates" "$WORKFLOW_ROOT/projects" "$BIN_DIR" "$COPILOT_DIR"

cp "$REPO_ROOT/templates/"*.md "$WORKFLOW_ROOT/templates/"
cp "$REPO_ROOT/README.md" "$WORKFLOW_ROOT/README.md"

ln -sf "$REPO_ROOT/bin/copilot-flow" "$BIN_DIR/copilot-flow"
ln -sf "$REPO_ROOT/bin/copilot-flow" "$BIN_DIR/copilot-architect"
ln -sf "$REPO_ROOT/bin/copilot-flow" "$BIN_DIR/copilot-implementer"
ln -sf "$REPO_ROOT/bin/copilot-flow" "$BIN_DIR/copilot-reviewer"

INSTRUCTIONS="$COPILOT_DIR/copilot-instructions.md"
if [ -f "$INSTRUCTIONS" ] && ! grep -q "Petr Copilot Workflow" "$INSTRUCTIONS"; then
  cp "$INSTRUCTIONS" "$INSTRUCTIONS.bak.$(date -u +%Y%m%d%H%M%S)"
fi

cat > "$INSTRUCTIONS" <<EOF
# Petr Copilot Workflow

When the current working directory is under \`$GITHUB_ROOT\`, use the shared workflow at:

\`$WORKFLOW_ROOT\`

Preferred interactive role launch commands:

\`\`\`bash
copilot-architect
copilot-implementer
copilot-reviewer
\`\`\`

These are equivalent to:

\`\`\`bash
copilot-flow start architect
copilot-flow start implementer
copilot-flow start reviewer
\`\`\`

Each command starts an interactive Copilot session, automatically injects the role, and points the session at the project workbench.

For each project, resolve the project root with \`git rev-parse --show-toplevel\` when possible. The project workbench is:

\`$WORKFLOW_ROOT/projects/<project-id>\`

Use these files as shared state between windows:

- \`REQUEST.md\`: user request
- \`PLAN.md\`: Architect output
- \`IMPLEMENTATION.md\`: Implementer output
- \`REVIEW.md\`: Reviewer output
- \`STATUS.md\`: first line is the current workflow status

Status flow:

\`\`\`text
idle -> new-request -> planning -> ready-for-implementation -> implementing -> ready-for-review -> reviewing -> approved
\`\`\`

If review finds blocking issues:

\`\`\`text
ready-for-review -> reviewing -> changes-requested -> implementing -> ready-for-review
\`\`\`

Role rules:

- Architect uses GPT-5.5, reads \`REQUEST.md\`, inspects the codebase, writes \`PLAN.md\`, and sets status to \`ready-for-implementation\`. Architect must not modify project source code.
- Implementer uses Codex, reads \`REQUEST.md\`, \`PLAN.md\`, and \`REVIEW.md\` when relevant, modifies project code, writes \`IMPLEMENTATION.md\`, and sets status to \`ready-for-review\`.
- Reviewer uses GPT-5.5, reads all workflow files and the current git diff, writes \`REVIEW.md\`, and sets status to \`approved\` or \`changes-requested\`. Reviewer must not modify project source code.

Do not ask the user to manually paste context between role windows. Read the workflow files instead.

Do not ask the user to manually run \`copilot-flow new\`. If the user gives a new top-level task in plain language, capture it yourself by running:

\`\`\`bash
copilot-flow new <<'REQUEST'
<full user request>
REQUEST
\`\`\`

If running the command is not appropriate, update \`REQUEST.md\` directly, reset \`PLAN.md\`, \`IMPLEMENTATION.md\`, and \`REVIEW.md\` from the workflow templates, and set \`STATUS.md\` to \`new-request\`.

Architect should continue directly into planning after capturing a new request. Implementer and Reviewer should capture new top-level requests and set status to \`new-request\` unless the user explicitly asks to bypass planning.

All three roles may be interactive. If the user gives feedback in a role window, treat it as role-specific guidance and update the relevant workflow file or project code according to that role's rules.
EOF

chmod +x "$REPO_ROOT/bin/copilot-flow"

printf 'Installed Petr Copilot Workflow\n'
printf 'Workflow root: %s\n' "$WORKFLOW_ROOT"
printf 'Commands linked in: %s\n' "$BIN_DIR"
