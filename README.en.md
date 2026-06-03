# ccs — Claude Code Sessions dashboard

> One command to see **all** your Claude Code sessions across every project
> directory — status, age, folder, and title — and resume any of them by number.

*[中文](README.md) · English*

> ⚠️ Unofficial tool. Not affiliated with Anthropic. It reads Claude Code's
> local files, whose format is undocumented and may change between releases.

---

If you run many Claude Code sessions at once — across different repos and
worktrees — `claude --resume` only shows the current directory by default, and
it's easy to lose track of what's running where. `ccs` gives you a single
cross-directory list, sorted with the busy and most-recent sessions on top, and
lets you jump straight back in.

## Demo

```text
$ ccs
 1  🟢    2m  web-app               Fix login redirect loop
 2  🟢   11m  web-app               Add Redis rate limiter
 3  ⚪   34m  api-gateway           Investigate flaky CI test
 4  ⚪    3h  api-gateway           Refactor auth middleware
 5  ⚪    6h  mobile-app            修复支付回调超时
 6  ⚪    1d  infra                 Bump deps and run codemod
(live only — 'ccs -a' includes exited sessions)
Resume #? (enter to skip) 3
# → cd's into api-gateway and runs `claude --resume` on that session
```

Include sessions whose process has already exited:

```text
$ ccs -a
 1  🟢    2m  web-app               Fix login redirect loop
 2  ⚪   34m  api-gateway           Investigate flaky CI test
 3  ⚫    2d  web-app               Wire up password reset email
 4  ⚫    5d  infra                 Migrate logging to OpenTelemetry
```

> The titles above are fictional examples.

Status icons: 🟢 busy · ⚪ live (idle) · ⚫ exited

## Install

Requires [`jq`](https://jqlang.github.io/jq/download/). Works in **bash** and
**zsh**, on **Linux** and **macOS**.

```bash
git clone https://github.com/nilevols/ccs.git
cd ccs
./install.sh            # installs to ~/.local/bin
```

Or drop the single `ccs` script anywhere on your `PATH` and `chmod +x` it.

## Usage

| Command                       | What it does                                              |
| :---------------------------- | :-------------------------------------------------------- |
| `ccs`                         | List live sessions, newest first; pick a number to resume |
| `ccs -a`                      | Also include exited sessions (from on-disk transcripts)   |
| `ccs [-a] -- <claude-args>`   | Forward args to `claude --resume` on the picked session   |
| `ccs -h`                      | Help                                                      |
| `ccs -V`                      | Version                                                   |

Pressing a row number resumes that session (`cd`s to its directory and runs
`claude --resume`). Press Enter to do nothing.

Anything after `--` is passed straight through to `claude` when resuming:

```bash
ccs -- --dangerously-skip-permissions
ccs -a -- --model opus
```

## How it works

Claude Code stores everything locally under `~/.claude` (or `$CLAUDE_CONFIG_DIR`):

- **Live session registry** — `~/.claude/sessions/<pid>.json`, one per running
  session, holding its directory, status, and the **name you set with
  `/rename`**. `ccs` reads this directly, because `claude agents --json` omits
  the name field.
- **Transcripts** — `~/.claude/projects/<dir>/<session-id>.jsonl`. Each contains
  an auto-generated `ai-title`. `ccs -a` scans these for sessions that have
  already exited.

Title priority for each row: your manual `/rename` name → Claude's auto title →
`(untitled)`.

`ccs` is **read-only** — it never modifies sessions, only lists and resumes.

## Caveats

- Relies on Claude Code's local file layout, which is **undocumented** and may
  change. If a release breaks `ccs`, please open an issue.
- `ccs -a` lists the 25 most recently active exited sessions to keep output sane.
- Honors `CLAUDE_CONFIG_DIR` if you've relocated your Claude config.

## Uninstall

```bash
rm "$(command -v ccs)"
```

## License

[MIT](LICENSE)
