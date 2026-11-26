# Changelog

All notable changes to cft. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versions follow [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-11-26

First tagged release.

### Added

- `cft install`, `open`, `close`, `shot`, `dom`, `run`, `profile`, `port`, `bin`, `version`, `prune`, `help`.
- One Chrome for Testing for every project (`~/.chrome-for-testing/`), one profile per project
  (`<project>/.chrome-for-testing/`, kept out of git via `.git/info/exclude`).
- A preferred DevTools port per project (9300–9999, from the project path); if it is taken, `open` uses the
  next free one and `port` reports the one in use.
- The project's browser is tracked by a pid file, so `close` never touches other Chromes.
- `cft --version`.
- `CFT_FLAGS` for extra Chrome flags on every launch (headless or `--no-sandbox` on Linux CI and containers);
  `CFT_PROJECT`, `CFT_WAIT_MS`, `CFT_HOME`.
- Every launch passes `--use-mock-keychain --password-store=basic`, so first launch never blocks on a
  Keychain or keyring prompt.
- Chrome's stderr from `shot` and `dom` is kept in `.chrome-for-testing/headless.log`.
- `install.sh`, `test/smoke.sh`, CI on macOS and Ubuntu, MIT license.

[0.1.0]: https://github.com/heeatw/cft/releases/tag/v0.1.0
