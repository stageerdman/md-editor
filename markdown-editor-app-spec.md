# Technical App Description: MiniMD

## 1. Purpose

A minimal, single-purpose macOS application that becomes the **default handler for `.md` files**. Its only job is to **open, edit, and save** a single Markdown file at a time, with **live formatting behavior identical to Obsidian's "Live Preview" mode** — no vaults, no plugins, no file browser, no graph view, no extra chrome.

Think of it as "TextEdit for Markdown, rendered like Obsidian."

---

## 2. Platform & Distribution

- **OS:** macOS 13 (Ventura) or later
- **Architecture:** Universal binary (Apple Silicon + Intel)
- **Distribution:** Signed & notarized `.app`, either via direct download (`.dmg`) or Mac App Store
- **Language/Framework:** Swift + SwiftUI (AppKit interop where needed for text rendering performance)
- **App type:** Document-based app using `NSDocument` / SwiftUI's `DocumentGroup`

---

## 3. Default `.md` Handler Registration

To make macOS treat this app as the default opener for `.md` files:

```xml
<!-- Info.plist -->
<key>CFBundleDocumentTypes</key>
<array>
  <dict>
    <key>CFBundleTypeName</key>
    <string>Markdown Document</string>
    <key>LSItemContentTypes</key>
    <array>
      <string>net.daringfireball.markdown</string>
    </array>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>LSHandlerRank</key>
    <string>Owner</string>
  </dict>
</array>
```

- User sets the app as default via Finder → Get Info → "Open with" → "Change All…" (standard macOS UTI mechanism; the app cannot force this itself, only declare eligibility).
- App exports the UTI `net.daringfireball.markdown` (conforms to `public.plain-text`) so it's a recognized candidate.

---

## 4. Core Functionality (and only this)

| Action | Behavior |
|---|---|
| **Open** | Double-click a `.md` file in Finder, or `File > Open…` → loads raw text into the editor |
| **Edit** | Type directly into a single-pane live-rendered view |
| **Save** | `⌘S` writes plain UTF-8 text back to the same file; `⌘⇧S` for Save As |
| **New** | `⌘N` opens an untitled `.md` document |
| **Close/Quit** | Standard macOS document lifecycle; prompts to save unsaved changes |

Explicitly **out of scope**: file trees, tabs across multiple vaults, search-across-files, tags/backlinks, plugins, themes marketplace, graph view, sync, export to PDF/HTML, settings panels beyond basic font/size.

---

## 5. Editing & Formatting Behavior (Obsidian Live Preview parity)

The core technical challenge is replicating Obsidian's **WYSIWYG-while-editing** style, not a split preview pane. Key behaviors:

1. **Syntax is hidden until the cursor touches it.**
   - `# Heading` renders as large bold text; syntax marks (`#`) are invisible while the cursor is elsewhere on that line.
   - Placing the cursor on that line reveals the raw `#` marker again for editing.
2. **Inline formatting renders live:**
   - `**bold**` → renders bold, hides asterisks when cursor is off-line
   - `*italic*` / `_italic_` → renders italic
   - `` `code` `` → renders in monospace with subtle background
   - `~~strikethrough~~` → renders struck through
3. **Block elements render live:**
   - `- ` / `* ` / `1. ` → real bullet/numbered list glyphs, with indentation-based nesting
   - `- [ ]` / `- [x]` → interactive checkboxes (togglable by click, updates underlying text)
   - `> ` → blockquote with left border and indent
   - Fenced code blocks (```` ``` ````) → monospace block with background, syntax-highlighted by language tag if present
   - `---` / `***` → renders as horizontal rule
   - `[text](url)` → renders as a clickable/styled link, raw markup shown on cursor focus
   - Tables (`| a | b |`) → rendered as an actual aligned table grid while editing
4. **Cursor-aware toggling** is per-line (or per-inline-span for bold/italic/links), matching Obsidian's exact interaction model — this is the trickiest part to implement well.

### Implementation approach
- Build on `NSTextView` / `TextKit 2` (not a WebView) for native performance and correct cursor/selection behavior.
- Maintain the **document as raw Markdown text at all times** (single source of truth) — rendering is a presentation layer via custom `NSTextStorage`/attribute application, not a separate rendered model.
- On each text change or selection/cursor move, re-run a lightweight Markdown tokenizer (e.g., a Swift port of `cmark` or a hand-rolled incremental parser) scoped to the affected line(s), then apply/remove `NSAttributedString` attributes (font, weight, color, hidden-range folding) accordingly.
- Use **text attribute "folding"** (zero-width rendering of syntax characters via `NSTextAttachment` or `.kern`/color tricks) rather than literally deleting characters, so the raw text buffer stays byte-identical to what's saved.

---

## 6. File I/O

- Reads/writes **plain UTF-8 text**, no transformation, no added frontmatter, no line-ending changes beyond what the user typed.
- No autosave-to-different-format; the file on disk is always valid standalone Markdown, editable in any other text editor too (important: no lock-in).
- Standard macOS versioning/autosave (`NSDocument` built-in) for crash recovery, but explicit `⌘S` remains the primary save action per your requirement.

---

## 7. Non-Goals (explicit)

- ❌ No vault/workspace concept
- ❌ No plugin system
- ❌ No multi-file sidebar or search
- ❌ No sync (iCloud Drive/Finder handles file location; app doesn't manage sync)
- ❌ No export formats
- ❌ No settings beyond maybe font family/size and light/dark theme

---

## 8. Minimal Settings

- Editor font (default: system monospace or a serif/sans reading font, user choice)
- Font size
- Light / Dark / System appearance
- That's it.

---

## 9. Summary

MiniMD is a **single-window, single-file, no-frills Markdown editor** for macOS that owns the `.md` file type and renders formatting inline exactly like Obsidian's Live Preview — bold renders bold, headers render large, checkboxes are clickable — while guaranteeing the underlying file always stays plain, portable Markdown text with nothing added or changed beyond what you typed.
