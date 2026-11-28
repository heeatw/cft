> Paste this section into your global `~/AGENTS.md` or `~/.claude/CLAUDE.md`.

# Testing pages in a browser: Chrome for Testing (`cft`)

Never test with the user's own Chrome or Safari (their logins, tabs, extensions). Use **Chrome for Testing**, through
the `cft` command (on PATH: `brew install heeatw/tap/cft`, or `install.sh` from a clone):

- **One browser for every project**: `~/.chrome-for-testing/browsers/` (installed with `@puppeteer/browsers`).
- **One profile per project**: `<project>/.chrome-for-testing/` (the project = the git root of the current
  directory; outside git, the nearest parent that already has a `.chrome-for-testing/profile/`, else the directory
  itself). `profile/` for the visible browser, `headless/` for screenshots, `shots/` for the pictures. It's made
  on first use and kept out of git: if the project doesn't ignore `.chrome-for-testing/`, cft adds it to
  `.git/info/exclude` (local only; the project's `.gitignore` isn't touched).
- **One DevTools port per project** (`cft port`, 9300–9999, from the project's path): several projects can have their
  browser open at once. If the port is taken, `cft open` uses the next free one; `cft port` always prints the one in use.

```sh
cft install                              # first time on a Mac, or to update to the newest stable
cft shot http://localhost:3000 [out.png] [1440x900]   # headless screenshot → prints the file; look at it
cft dom http://localhost:3000            # the HTML after scripts ran
cft open http://localhost:3000           # a visible window on the project's profile (the user can watch)
cft close
cft profile | port | bin | version       # where things are
cft run --flag …                         # the binary on the project's profile with your own flags
CFT_WAIT_MS=6000 cft shot …              # wait longer before shooting (default 3000 ms)
```

- After `cft open`, drive the page over the Chrome DevTools Protocol at `http://127.0.0.1:$(cft port)`
  (`/json/list` for the tabs and their `webSocketDebuggerUrl`; puppeteer / playwright
  `connectOverCDP("http://127.0.0.1:<port>")`). Logins and local storage stay in the project's profile between runs.
- `cft shot` and `cft dom` use the separate headless profile, so they work while `cft open` has a window up.
- A screenshot proves what's on screen: take one after a UI change and read the image before saying it works.
- Show the user screenshots by path (absolute). Delete old ones in `.chrome-for-testing/shots/` when done if many.
- New project: nothing to set up. Run `cft shot …` (or `cft profile`) inside it and the profile appears.
- Screen capture of the real desktop (`screencapture`) needs Screen Recording permission for the terminal and an
  unlocked screen; prefer `cft shot` for pages.
