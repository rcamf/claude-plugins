---
name: check-svelte
description: Run diagnostics on Svelte components
allowed-tools:
  - Bash
  - Read
  - Glob
argument-hint: "[file path]"
---

Run Svelte diagnostics using the language server.

If a file path argument is provided, focus diagnostics on that file.
Otherwise, check all `.svelte` files in the project.

For each error found:
1. Report the file, line, and error message
2. Summarize findings with a count of errors and warnings

Group results by file. Present errors before warnings.
