# cft — Chrome for Testing, per project

A small bash wrapper around Google's [Chrome for Testing](https://developer.chrome.com/blog/chrome-for-testing)
so that agents (and humans) can open, screenshot and inspect web pages **without touching your own Chrome**:
no personal logins, tabs or extensions are involved.

- **One browser for every project**: installed once in `~/.chrome-for-testing/browsers/` via `@puppeteer/browsers`.
- **One profile per project**: `<project>/.chrome-for-testing/` (the project = the git root of the current
  directory). `profile/` for the visible browser, `headless/` for screenshots, `shots/` for the pictures.
  Created on first use and kept out of git (added to `.git/info/exclude` if not already ignored).
- **One DevTools port per project** (9300–9999, derived from the project path): several projects can have
  their browser open at the same time.

## Install

Requires macOS (or Linux), `git`, `curl`, and `npx` (Node.js) for downloading the browser.

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
cft profile | port | bin | version       # where things are
cft run --flag …                         # the binary on the project's profile with your own flags
cft prune                                # remove older installed browser versions
CFT_WAIT_MS=6000 cft shot …              # wait longer before shooting (default 3000 ms)
CFT_PROJECT=/path cft …                  # act on another project than the current directory's
```

After `cft open`, drive the page over the Chrome DevTools Protocol at `http://127.0.0.1:$(cft port)`:
`/json/list` lists the tabs and their `webSocketDebuggerUrl`; puppeteer / playwright can
`connectOverCDP("http://127.0.0.1:<port>")`. Logins and local storage stay in the project's profile between runs.

`cft shot` and `cft dom` use a separate headless profile, so they work while `cft open` has a window up.

## For coding agents

[`docs/AGENTS.md`](docs/AGENTS.md) is a ready-to-paste section for a global `~/AGENTS.md` / `~/.claude/CLAUDE.md`
telling an agent to test pages with `cft` instead of the user's own browser.

## Layout

```
bin/cft          the script
install.sh       symlink bin/cft → ~/.local/bin/cft
docs/AGENTS.md   agent instructions snippet
```
