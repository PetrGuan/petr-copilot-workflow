# Petr Copilot Workflow

A lightweight shared workbench for running three interactive GitHub Copilot CLI windows with different responsibilities:

1. Architect: understands the request and writes the implementation plan.
2. Implementer: follows the plan and changes code.
3. Reviewer: reviews the diff and approves or requests changes.

The goal is to avoid manually copying context between windows. Each role reads and writes the same project-specific workflow files.

## Requirements

- GitHub Copilot CLI installed and authenticated.
- `git` available on PATH.
- macOS or Linux shell environment.

## Install

Clone this repository, then run:

```bash
./install.sh
```

By default, projects are expected under:

```text
$HOME/Documents/GitHub
```

Override this if your projects live elsewhere:

```bash
export COPILOT_WORKFLOW_GITHUB_ROOT="/path/to/projects"
```

## Quick start

From any project directory under your GitHub root:

```bash
copilot-flow init
```

Open three terminal windows in that project and run:

```bash
copilot-architect
copilot-implementer
copilot-reviewer
```

Submit a request:

```bash
copilot-flow new "Implement the feature or fix the bug described here."
```

The three role windows share state through:

```text
$COPILOT_WORKFLOW_GITHUB_ROOT/.copilot-workflow/projects/<project-id>/
```

## Commands

```bash
copilot-flow init
copilot-flow new "request text"
copilot-flow status
copilot-flow where
copilot-flow start architect
copilot-flow start implementer
copilot-flow start reviewer
```

Shortcuts:

```bash
copilot-architect
copilot-implementer
copilot-reviewer
```

Automation is also available:

```bash
copilot-flow run architect
copilot-flow watch architect
```

## Workflow files

Each project gets these files:

```text
REQUEST.md
PLAN.md
IMPLEMENTATION.md
REVIEW.md
STATUS.md
PROJECT.md
```

`STATUS.md` drives the handoff:

```text
idle
new-request
planning
ready-for-implementation
implementing
ready-for-review
reviewing
approved
changes-requested
blocked
failed-architect
failed-implementer
failed-reviewer
```

## Default models

- Architect: `gpt-5.5`
- Implementer: `gpt-5.3-codex`
- Reviewer: `gpt-5.5`

Override them:

```bash
export COPILOT_WORKFLOW_ARCHITECT_MODEL=gpt-5.5
export COPILOT_WORKFLOW_IMPLEMENTER_MODEL=gpt-5.3-codex
export COPILOT_WORKFLOW_REVIEWER_MODEL=gpt-5.5
```

## Permissions

Interactive role windows do not use `--allow-all` by default. They add the shared workflow directory with `--add-dir` and otherwise keep Copilot interactive.

Unattended automation uses `--allow-all` by default so it does not stop at permission prompts. Override automation flags:

```bash
export COPILOT_WORKFLOW_COPILOT_FLAGS="--allow-all-tools --allow-all-paths"
```

Enable auto-approval for interactive role windows:

```bash
export COPILOT_WORKFLOW_INTERACTIVE_FLAGS="--allow-all"
```

## License

MIT

