---
name: tsgo-lsp
version: 0.1.0
description: >
  This skill should be used when working on TypeScript or JavaScript projects
  that have the tsgo LSP server available. It covers type checking, code
  navigation, refactoring, diagnostics, and code analysis via the native tsgo
  language server. Use when the user asks to "check types", "find type errors",
  "refactor TypeScript", "rename symbol", "find references", "go to definition",
  "format code", "fix TypeScript errors", "get diagnostics", "show code actions",
  "understand this TypeScript code", or when investigating type-related bugs,
  performing code navigation, or doing safe refactoring across a TypeScript
  codebase. Also use when the user mentions "tsgo", "typescript-go",
  "TypeScript 7", or "tsgo LSP".
---

# tsgo LSP Integration

The tsgo language server runs natively via Claude Code's `lspServers` integration,
providing real-time TypeScript analysis through the Language Server Protocol. The
server launches automatically when working with `.ts`, `.tsx`, `.js`, or `.jsx` files.

## Capabilities

The tsgo LSP provides these capabilities through Claude Code's native LSP integration:

- **Diagnostics** — Real-time type errors and warnings
- **Hover** — Type information and documentation at any position
- **Go to Definition** — Navigate to where symbols are defined
- **Find References** — Locate all usages of a symbol across the codebase
- **Rename** — Safely rename symbols across all files
- **Code Actions** — Quick fixes and refactorings suggested by the compiler
- **Completions** — Code completion with type-aware suggestions
- **Signature Help** — Function parameter hints
- **Document Symbols** — List all symbols in a file
- **Formatting** — Code formatting via the language server

## Core Workflow

Follow the **Understand → Investigate → Act** pattern:

1. **Understand** — Use diagnostics and hover to see what the compiler knows
2. **Investigate** — Use definitions and references to trace code paths
3. **Act** — Apply fixes, renames, or refactorings with confidence

## Best Practices

### Type Checking Workflow

When investigating type errors:

1. Check diagnostics to see all errors in the current file or project
2. Use hover on error locations to understand the types involved
3. Check code actions for automatic fixes suggested by the compiler
4. Apply fixes using Edit tools, then re-check diagnostics to verify

### Safe Refactoring Workflow

When renaming or restructuring:

1. Find all references to understand the blast radius before changing anything
2. Use the LSP rename capability for symbol renames — it updates all references across files
3. Re-check diagnostics after to confirm no breakage was introduced

### Exploring Unfamiliar Code

When first encountering a TypeScript project:

1. Check document symbols on key files to understand their shape
2. Use hover on important types and functions for their signatures
3. Use go-to-definition to trace type hierarchies and implementations
4. Find references on exports to understand how modules connect

### CLI Type Checking

For full project type checking, run tsgo directly:

```bash
tsgo --project tsconfig.json
```

This performs a complete type check and reports all errors. Useful for CI-style
validation or checking the entire project at once.

## Available Commands

- `/check-types [file]` — Run type checking on a file or the whole project
- `/project-overview` — Get a summary of project structure and types
- `/find-symbol <name>` — Search for a symbol and show its details

## Prerequisites

- `tsgo` binary available in PATH (install via `npm install -g @typescript/native-preview` or build from [microsoft/typescript-go](https://github.com/microsoft/typescript-go))
- A `tsconfig.json` in the project root

## Troubleshooting

If the LSP server fails to start:
- Verify `tsgo` is in PATH: `which tsgo`
- Ensure `tsconfig.json` exists in the project
- Check that the file being edited has a supported extension (`.ts`, `.tsx`, `.js`, `.jsx`)
