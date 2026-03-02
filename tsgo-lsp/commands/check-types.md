---
name: check-types
description: Run full TypeScript type checking on the project using tsgo LSP
allowed-tools:
  - mcp__tsgo-lsp__lsp_get_all_diagnostics
  - mcp__tsgo-lsp__lsp_get_diagnostics
  - mcp__tsgo-lsp__lsp_get_code_actions
  - mcp__tsgo-lsp__lsp_get_hover
  - Read
  - Glob
argument-hint: "[file path]"
---

Run TypeScript type checking using the tsgo LSP server.

If a file path argument is provided, check only that file using `lsp_get_diagnostics`.
Otherwise, run `lsp_get_all_diagnostics` for a full project check.

For each error found:
1. Report the file, line, and error message
2. Use `lsp_get_hover` to show the types involved if the error is unclear
3. Use `lsp_get_code_actions` to check for auto-fixable issues
4. Summarize findings with a count of errors and warnings

Group results by file. Present errors before warnings.
