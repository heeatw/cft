# cft — Chrome for Testing, per project

[![CI](https://github.com/heeatw/cft/actions/workflows/ci.yml/badge.svg)](https://github.com/heeatw/cft/actions/workflows/ci.yml)

A small bash wrapper around Google's [Chrome for Testing](https://developer.chrome.com/blog/chrome-for-testing)
so that agents (and humans) can open, screenshot and inspect web pages **without touching your own Chrome**:
no personal logins, tabs or extensions are involved.

- **One browser for every project**: installed once in `~/.chrome-for-testing/browsers/` via `@puppeteer/browsers`.
- **One profile per project**: `<project>/.chrome-for-testing/` (the project = the git root of the current
  directory). `profile/` for the visible browser, `headless/` for screenshots, `shots/` for the pictures.
  Created on first use and kept out of git (added to `.git/info/exclude` if not already ignored).
- **One DevTools port per project** (9300–9999, derived from the project path): several projects can have
  their browser open at the same time. If that port happens to be taken, `cft open` takes the next free one
  and `cft port` reports the one actually in use.
- **Only its own browser**: the project's browser is tracked by a pid file in `.chrome-for-testing/`, so
  `cft close` never touches your other Chromes. The DevTools port listens on 127.0.0.1 only.

## Why not Playwright or Puppeteer?

Those are libraries: you write a script, in a project that has them installed, and the browser lives inside
that script's lifetime. `cft` is for the other situation, which is most of a coding agent's day:

- **No code, no project setup.** `cft shot http://localhost:3000` works in any directory, in any language's
  project, with nothing added to it. An agent that has read [docs/AGENTS.md](docs/AGENTS.md) knows how to use it.
- **A browser that stays open.** `cft open` leaves a real window up, logged in, with its DevTools port known.
  The agent (or you) can look at it, and any CDP client can attach to it later.
- **Never your own Chrome.** Agent tooling that drives "the browser" often means your browser, with your
  sessions, extensions and tabs. Chrome for Testing is a separate binary with a separate profile per project.
- **It composes with them.** `cft open` plus `connectOverCDP("http://127.0.0.1:$(cft port)")` gives a
  Playwright or Puppeteer script the same browser, when a script is what you need.

## Install

Requires `bash`, `git`, `curl`, and Node.js: `cft install` downloads the browser with Google's own
[`@puppeteer/browsers`](https://github.com/puppeteer/puppeteer/tree/main/packages/browsers) via `npx`.

### Homebrew

```sh
brew trust heeatw/tap       # Homebrew 7+ asks you to trust a third-party tap once
brew install heeatw/tap/cft
cft install                 # downloads the newest stable Chrome for Testing
```

### From a clone

Platforms: macOS is the primary target. Linux works and is covered by CI; on a display-less machine run the
visible browser headless, and in containers or on Ubuntu 24.04+ (unprivileged user namespaces are blocked, so
Chrome's sandbox can't start) add `--no-sandbox`: see `CFT_FLAGS` below. Windows isn't supported.

```sh
git clone git@github.com:heeatw/cft.git ~/dev/heeatw/cft
~/dev/heeatw/cft/install.sh        # symlinks bin/cft into ~/.local/bin (must be on PATH)
cft install                 # downloads the newest stable Chrome for Testing
```

## Usage

```sh
cft install                              # first time, or to update to the newest stable
cft shot http://localhost:3000 [out.png] [1440x900]   # headless screenshot → prints the file path
cft dom http://localhost:3000            # the HTML after scripts ran
cft open http://localhost:3000           # a visible window on the project's profile
cft close
cft profile | port | bin | version       # where things are (version: the browser's)
cft --version                            # this tool's version
cft run --flag …                         # the binary on the project's profile with your own flags
cft prune                                # remove older installed browser versions
CFT_WAIT_MS=6000 cft shot …              # wait longer before shooting (default 3000 ms)
CFT_PROJECT=/path cft …                  # act on another project than the current directory's
CFT_FLAGS="--headless=new --no-sandbox" cft open   # extra Chrome flags for every launch (Linux CI, containers)
```

After `cft open`, drive the page over the Chrome DevTools Protocol at `http://127.0.0.1:$(cft port)`:
`/json/list` lists the tabs and their `webSocketDebuggerUrl`; puppeteer / playwright can
`connectOverCDP("http://127.0.0.1:<port>")`. Logins and local storage stay in the project's profile between runs.

`cft shot` and `cft dom` use a separate headless profile, so they work while `cft open` has a window up.

## For coding agents

[`docs/AGENTS.md`](docs/AGENTS.md) is a ready-to-paste section for a global `~/AGENTS.md` / `~/.claude/CLAUDE.md`
telling an agent to test pages with `cft` instead of the user's own browser.

## Development

```sh
shellcheck -S warning bin/cft install.sh test/smoke.sh
test/smoke.sh      # exercises every command against a throwaway project (needs `cft install` done)
```

CI runs both on macOS and Ubuntu for every push and pull request.

## Layout

```
bin/cft            the script
install.sh         symlink bin/cft → ~/.local/bin/cft
test/smoke.sh      smoke test
docs/AGENTS.md     agent instructions snippet
```

## License

[MIT](LICENSE)
