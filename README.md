<p align="center">
  <img src="Resources/icon-preview.png" width="128" height="128" alt="MiniMD icon">
</p>

<h1 align="center">MiniMD</h1>

<p align="center">
  A minimal macOS Markdown editor with Obsidian-style live preview.<br>
  Open a <code>.md</code> file, type, save. Nothing else.
</p>

---

## What it is

MiniMD is a single-window, single-file Markdown editor for macOS. It aims to
be the default handler for `.md` files: no vaults, no plugins, no file
browser, no graph view — just a text buffer that renders formatting inline as
you type, the way Obsidian's "Live Preview" mode does.

- `# Heading` renders large and bold; the `#` fades back in only when your
  cursor is on that line.
- `**bold**`, `*italic*`, `` `code` ``, and `~~strikethrough~~` render live,
  hiding their markers until you touch them.
- `- [ ]` / `- [x]` checklists are clickable.
- `[text](url)` links open in your browser with a cmd-click.
- Blockquotes, fenced code blocks, horizontal rules, and tables get
  lightweight live styling too.
- The file on disk is always plain, portable UTF-8 Markdown — nothing is
  added, transformed, or reformatted beyond what you typed. Formatting is a
  presentation layer on top of the raw text, not a separate model.

Full behavioral spec: [`markdown-editor-app-spec.md`](markdown-editor-app-spec.md).

## Status / limitations

This is a v1 built without a full Xcode install (see below), so a few things
are intentionally simplified rather than pixel-perfect:

- Checklists are clickable but rendered as styled bracket text, not a true
  checkbox glyph.
- Horizontal rules and tables get an approximate rendering, not a real
  drawn rule / grid.
- The whole document is re-parsed on every keystroke (fine at the
  single-file scale this targets; not tuned for huge files).
- No fenced-code syntax highlighting by language.
- Ad-hoc code-signed only — no notarization or `.dmg` pipeline. That needs
  an Apple Developer account and full Xcode, neither of which this was built
  with.

## Requirements

- macOS 13 (Ventura) or later
- Xcode Command Line Tools (`xcode-select --install`) — a full Xcode.app is
  **not** required; this project builds via Swift Package Manager.

## Build & run

```sh
git clone https://github.com/stageerdman/md-editor.git
cd md-editor
Scripts/build.sh
```

This compiles the package, assembles a real `MiniMD.app` bundle at
`build/MiniMD.app` (Info.plist + ad-hoc codesign), quits any running copy,
and launches the fresh build. Pass `release` for an optimized build:

```sh
Scripts/build.sh release
```

To make MiniMD the default handler for `.md` files: select a `.md` file in
Finder → <kbd>⌘I</kbd> → "Open with" → choose MiniMD → "Change All…".

## Project structure

```
Sources/MiniMD/
├── App/            App entry point, scene wiring only
├── Document/       FileDocument conformance — plain UTF-8 read/write
├── Editor/
│   ├── Tokenizer/  Line + inline markdown parsing (no rendering)
│   └── Rendering/  Parsed tokens → NSAttributedString folding/styling
├── Views/          SwiftUI views — no parsing or file I/O
└── Settings/       Font / size / appearance preferences
```

See [`CLAUDE.md`](CLAUDE.md) for the modularization conventions this project
follows (one responsibility per file, no god-files, folder = layer).

## Icon

Regenerated from a small AppKit drawing script rather than a static asset —
see `Scripts/generate_icon.swift` / `Scripts/generate_icon.sh`. It draws a
bold "M" with a small down-caret accent on an indigo-to-navy gradient.

## License

MIT — see [`LICENSE`](LICENSE).
