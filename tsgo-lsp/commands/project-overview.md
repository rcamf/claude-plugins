---
name: project-overview
description: Get an overview of the TypeScript project structure, key types, and dependencies
allowed-tools:
  - mcp__tsgo-lsp__get_project_overview
  - mcp__tsgo-lsp__lsp_get_document_symbols
  - mcp__tsgo-lsp__get_typescript_dependencies
  - mcp__tsgo-lsp__get_symbols_overview
  - Read
  - Glob
---

Analyze the TypeScript project structure using the tsgo LSP.

1. Run `get_project_overview` for the high-level structure
2. Use `get_typescript_dependencies` to list key dependencies
3. Use `get_symbols_overview` on entry point files to show key exports
4. Present a concise summary:
   - Project structure (directories and their purpose)
   - Key types and interfaces
   - Main dependencies
   - Entry points
