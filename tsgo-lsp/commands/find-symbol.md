---
name: find-symbol
description: Search for a symbol across the TypeScript project and show its details
allowed-tools:
  - mcp__tsgo-lsp__search_symbols
  - mcp__tsgo-lsp__get_symbol_details
  - mcp__tsgo-lsp__lsp_find_references
  - mcp__tsgo-lsp__lsp_get_definitions
  - mcp__tsgo-lsp__lsp_get_hover
  - Read
argument-hint: "<symbol name>"
---

Search for a symbol in the TypeScript project and present detailed information.

1. Use `search_symbols` with the provided symbol name
2. For each match, use `get_symbol_details` to show:
   - Full type signature
   - Definition location
   - Number of references
3. If there are few matches, also show key references using `lsp_find_references`

Present results grouped by kind (types, functions, variables, classes).
