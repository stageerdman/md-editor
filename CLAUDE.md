# CLAUDE.md — MiniMD

Guidance for Claude Code when working in this repository.

## What this is

MiniMD: a minimal macOS Markdown editor with Obsidian-style live preview.
Full spec: `markdown-editor-app-spec.md`. Built as a Swift Package (no Xcode.app
installed in this environment — only Command Line Tools), packaged into a real
`.app` bundle by `Scripts/build.sh`.

## Modularization — the primary code-quality bar

Every change should leave the codebase *more* modular, not less. Concretely:

- **One responsibility per file.** If a file starts doing two distinct jobs
  (e.g. tokenizing markdown *and* rendering attributes), split it before adding
  more to it.
- **Folder = layer.** Keep the existing structure and put new code where it
  belongs:
  - `Sources/MiniMD/App` — app entry point, scene/window wiring only
  - `Sources/MiniMD/Document` — file I/O / `FileDocument` conformance only
  - `Sources/MiniMD/Editor` — tokenizer, attribute/folding engine, the
    `NSTextView` wrapper. Parsing logic and rendering logic stay in separate
    files even though they cooperate closely.
  - `Sources/MiniMD/Views` — SwiftUI views/scenes, no parsing or file I/O
  - `Sources/MiniMD/Settings` — user-facing preferences only
- **No god-files.** If a file crosses ~250-300 lines, look for a seam to
  extract (e.g. one file per inline-syntax rule, one file per block-syntax
  rule) rather than letting it grow.
- **Small, composable functions** over long ones with branching flags.
- **New features get their own file(s)**, not appended to an existing
  unrelated one, even if it's just a few lines.
- Prefer protocols/small structs over singletons; avoid global mutable state
  outside `AppSettings`.

When in doubt, favor an extra small file over a bigger shared one.

## Workflow — after every edit

This applies after **every** code change, however small, not just at the end
of a task:

1. **Build the app**: run `Scripts/build.sh`. This compiles via `swift build`
   and assembles a real `MiniMD.app` bundle (Info.plist, ad-hoc codesign) in
   `build/MiniMD.app`. Fix any build errors before doing anything else.
2. **Make sure the user has the newest build open**: `Scripts/build.sh`
   already quits any running `MiniMD` instance and relaunches the freshly
   built `.app` at the end. Always let it finish (don't background/skip this
   step) so what's on screen is never a stale build. If you edit files but
   don't run the script, the user is looking at stale code — treat that as
   an unfinished task.
3. **Always be committing and pushing**: once the build succeeds, `git add`
   the relevant files, commit with a short message describing the change, and
   `git push`. Don't batch up many unrelated edits into one commit — commit
   per logical change, frequently. Never leave work uncommitted/unpushed at
   the end of a turn if the build is green.

If the build fails, fix it first — don't commit/push broken code, and don't
leave a stale `.app` open without telling the user the latest edit didn't
build.

## Environment notes

- No full Xcode — `xcodebuild` is unavailable, only `swift build` via SPM.
  Signing is ad-hoc (`codesign --sign -`); there's no notarization or DMG
  pipeline here. If real distribution (notarized `.dmg` / App Store) is ever
  needed, that requires an Apple Developer account and Xcode, outside this
  environment.
- GitHub remote is authenticated via `gh`. Push to `main` directly unless told
  otherwise.
