# Internal Contract: GenUI Chatbot Catalog

**Feature**: 005-genui-chatbot  
**Type**: Catalog component schema contract  
**Date**: 2026-05-08

---

## Catalog Identity

| Property | Value |
|----------|-------|
| `catalogId` | `'com.deploytalks.genui_chatbot_catalog'` |
| Function | `buildGenuiChatbotCatalog()` in `app/lib/features/genui_chat/catalog/genui_chatbot_catalog.dart` |
| Components | `TextCard`, `ItemList`, `CodeBlock`, `StatHighlight` |

---

## Component Schemas

### TextCard

Gemini uses this for conceptual explanations, summaries, and prose answers.

```json
{
  "type": "object",
  "required": ["title", "body"],
  "properties": {
    "title":  { "type": "string", "description": "Short heading" },
    "body":   { "type": "string", "description": "Main prose content" },
    "emoji":  { "type": "string", "description": "Optional decorative emoji" }
  }
}
```

---

### ItemList

Gemini uses this for enumerations, rankings, step-by-step instructions, or any multi-item answer.

```json
{
  "type": "object",
  "required": ["items"],
  "properties": {
    "title":   { "type": "string",  "description": "Optional heading for the list" },
    "items":   { "type": "array",   "items": { "type": "string" }, "description": "The list items" },
    "ordered": { "type": "boolean", "description": "True for numbered list, false for bullets" }
  }
}
```

---

### CodeBlock

Gemini uses this when the answer involves code, terminal commands, or syntax examples.

```json
{
  "type": "object",
  "required": ["code"],
  "properties": {
    "language": { "type": "string", "description": "Language label, e.g. 'dart', 'bash'" },
    "code":     { "type": "string", "description": "The code or command text" },
    "caption":  { "type": "string", "description": "Optional explanation below the block" }
  }
}
```

---

### StatHighlight

Gemini uses this for a single key fact, metric, number, or date.

```json
{
  "type": "object",
  "required": ["label", "value"],
  "properties": {
    "label":   { "type": "string", "description": "Short description of the stat" },
    "value":   { "type": "string", "description": "The prominent number or fact" },
    "unit":    { "type": "string", "description": "Optional unit, e.g. 'km', '%'" },
    "context": { "type": "string", "description": "Optional one-line context sentence" }
  }
}
```

---

## System Prompt Fragment Contract

The catalog's `systemPromptFragments` list MUST instruct Gemini to:

1. Always respond using exactly one `createSurface` call using the most appropriate catalog component
2. Use `TextCard` for conceptual explanations and prose answers
3. Use `ItemList` for any enumeration, ranking, or step-by-step content
4. Use `CodeBlock` for code, commands, or syntax
5. Use `StatHighlight` for a single prominent fact, number, or metric
6. Never respond with plain text — the output must always be a GenUI surface

---

## Widget Rendering Guarantees

Each `CatalogItem.widgetBuilder` MUST:
- Handle all optional fields gracefully (null check before rendering)
- Use `AppColors` and `AppTheme` typography for visual consistency
- Never throw for missing optional fields — render sensible defaults
- Respect `BoxConstraints(maxWidth: 520)` to avoid overflow on wide screens
