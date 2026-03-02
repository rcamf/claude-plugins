---
name: svelte-lsp
version: 0.1.0
description: >
  This skill should be used when working on Svelte or SvelteKit projects that
  have the Svelte language server available. Use when the user asks to "check
  Svelte errors", "fix Svelte component", "find references in Svelte", "rename
  symbol", "go to definition", "format Svelte file", "understand this Svelte
  component", or when investigating errors, performing code navigation, or
  refactoring across a Svelte codebase. Also use when the user mentions
  "svelteserver", "Svelte LSP", or "SvelteKit".
---

# Svelte LSP Integration

The Svelte language server runs natively via Claude Code's `lspServers` integration,
providing real-time analysis for `.svelte` files through the Language Server Protocol.
The server launches automatically when working with Svelte components.

## Capabilities

The Svelte LSP provides these capabilities through Claude Code's native LSP integration:

- **Diagnostics** — Real-time errors and warnings in Svelte components
- **Hover** — Type information and documentation at any position
- **Go to Definition** — Navigate to where symbols are defined
- **Find References** — Locate all usages of a symbol across the codebase
- **Rename** — Safely rename symbols across all files
- **Code Actions** — Quick fixes and refactorings
- **Completions** — Context-aware code completion for Svelte syntax, props, events, and slots
- **Signature Help** — Function parameter hints
- **Formatting** — Code formatting for Svelte components

## Svelte-Specific Considerations

### Component Structure

Svelte components combine `<script>`, markup, and `<style>` in a single `.svelte` file.
The language server understands all three sections and provides diagnostics across them.

### Reactivity

The LSP understands Svelte's reactivity model:
- `$:` reactive declarations
- `$state`, `$derived`, `$effect` runes (Svelte 5)
- Store auto-subscriptions with `$` prefix (Svelte 4)

### Props and Events

Use hover and completions to inspect component props, events, and slots.
Find references works across component boundaries — trace where a prop is
passed from parent components.

## Best Practices

### Debugging Component Errors

1. Check diagnostics for the current `.svelte` file
2. Use hover on error locations to understand types involved
3. Check code actions for automatic fixes
4. For cross-component issues, use find references to trace prop flow

### Safe Refactoring

1. Find all references before renaming to understand impact
2. Use LSP rename for symbols — it updates across `.svelte`, `.ts`, and `.js` files
3. Re-check diagnostics after to confirm no breakage

## Available Commands

- `/check-svelte [file]` — Run diagnostics on a Svelte file or the whole project
- `/svelte-overview` — Get a summary of the Svelte project structure

## Prerequisites

- `svelteserver` available in PATH (install via `npm install -g svelte-language-server`)
- A Svelte project with `svelte.config.js`
