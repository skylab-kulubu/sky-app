# CLAUDE.md

Guidance for Claude Code when working in this repository.

## Read these first

- **[AGENTS.md](AGENTS.md)** — what the project is, its architecture, the theme/color rules, the icon system and the known pitfalls. Read it end to end before writing code.
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — binding coding rules: folder structure, the Page/PageModel split, widget extraction, constant usage.

Both files are the single source of truth; do not duplicate their content here.

@AGENTS.md

## Non-negotiables

- **Never run `git commit` or `git push`.** Summarize the changed files and stop; the user commits.
- **Write in Turkish.** Answers, in-code comments and user-facing strings are Turkish; identifiers stay English.
- **Run `flutter analyze --no-pub` after every change** and leave it clean. A clean analyze means "it compiles", not "it looks right".
- **The user does the visual verification.** If you changed anything visual, say explicitly that you did not verify it on screen and point out what to look at.
- **No tests unless asked.** The project has no `test/` folder on purpose.
- **Do not add new dependencies or invent new patterns** — reuse what is in `core/constants` and `core/widgets` first.

## Permissions

`.claude/settings.json` is committed and shared by the team: it pre-approves the safe read-only commands and **denies** `git commit`, `git push`, `git reset`, `git checkout`, `flutter build ios` and `pod install/update`. Personal overrides go in `.claude/settings.local.json`, which is gitignored. If a denied command is genuinely needed, ask the user to run it — do not work around the rule.

## Commands

```bash
flutter analyze --no-pub
dart format lib/
flutter pub get
```

Do not run `flutter build ios`: it triggers CocoaPods and breaks the Swift Package Manager setup of the iOS project.
