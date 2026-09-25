# Gentoo overlay

The Omarchy packages, delivered to Gentoo Linux as a source-based ebuild
overlay. The Arch recipes are not part of this repository: they live in the
pinned `omarchy-pkgs/` submodule (omacom/omarchy-pkgs), and everything else here
— overlay, tooling, automation — is ours. This document is the contract for
humans and AI agents working on the overlay; `AGENTS.md` at the repository
root is the shorter entry point.

## Why a source-based overlay (and not a binhost)

The Arch repository ships binaries because pacman users share one profile.
Portage users do not: USE flags, profiles and abi differ per machine, so a
prebuilt package either explodes into combinatorics or silently mismatch.
An overlay compiles on the user's machine with the user's settings, which
also makes the nightly smoke-emerge meaningful. A binhost for the
`-bin` packages (which need no USE matching) can be layered on the same
ebuilds later.

## Using the overlay

The overlay lives in its own repository,
[Lax/omarchy-overlay](https://github.com/Lax/omarchy-overlay). On a Gentoo
machine:

```bash
eselect repository add omarchy git https://github.com/Lax/omarchy-overlay.git
emaint sync -r omarchy
```

Or hand-write the repository definition:

```ini
# /etc/portage/repos.conf/omarchy.conf
[omarchy]
location = /var/db/repos/omarchy
sync-type = git
sync-uri = https://github.com/Lax/omarchy-overlay.git
priority = 50
```

Either way, keep it current with plain `emaint sync -r omarchy`. Then
`emerge <category>/<package>`. Packages are keyworded `~amd64`/`~arm64`;
accept the unstable keyword as usual.

The `-bin` and vendor packages carry proprietary licenses (the
`all-rights-reserved` token). Accept them like any other proprietary
Gentoo package, e.g. in `/etc/portage/package.license`:

```
# /etc/portage/package.license/omarchy
*/* all-rights-reserved
```

(or list the specific `category/pkg` lines if you prefer narrower grants).

## Scope: what is ported, and what deliberately is not

Covered by the first waves: every `arch=any` package and the binary
repackages (`-bin` and friends), plus the legacy desktop stack — the
**`omarchy` / `omarchy-settings` meta-pair** ships Gentoo-adapted
(portage-ported bin scripts, CONFIG_PROTECT-guarded /etc drop-ins, the
Arch boot stack dropped). Out of scope for now, each with a recorded
reason in `helpers/gentoo-skip.tsv`:

- **Kernels** (`linux-omarchy*`) — a distro port, not a package port.
- **Packages Gentoo already ships** (yaru-icon-theme, nautilus-open-any-terminal,
  python-sounddevice) — no point shadowing the monorepo.
- **spotify** — blocked: no Gentoo package provides `libcurl-gnutls.so.4`;
  needs a dedicated compat package first.
- **Source-built packages** (ghostty, yay, DKMS drivers, ...) — real porting
  work, eclass by eclass.

`bin/ai-port --list-open` prints the live queue (open work vs skips vs
shipped); the nightly coverage job files the same list as a GitHub issue.

## Translation rules (PKGBUILD → ebuild)

| Arch | Gentoo |
| --- | --- |
| `arch=(any)` | `KEYWORDS="~amd64 ~arm64"` |
| `arch=(x86_64 aarch64)` | `KEYWORDS="~amd64 ~arm64"` (only declared arches) |
| `options=('!strip')` / binary repackage | `RESTRICT="strip mirror"` |
| `source_x86_64=()` | `SRC_URI` with `amd64? ( ... )` conditionals |
| `depends=(...)` | `RDEPEND` via `helpers/gentoo-deps.map` |
| `.install` post_install messages | `pkg_postinst` `elog` block |
| pacman `PreTransaction` hooks | `pkg_prerm` calling a helper in `files/` |
| sysusers lines | `enewgroup`/`enewuser` via the user eclass |
| unpinned floating sources | pinned to a commit (Manifest digests must be stable) |
| `pkgver` with epoch / lettered dot-components | epoch dropped; `1.2.r3` → `1.2_p3` style suffixes; pkgrel dropped |
| `omarchy-keyring`, Arch-channel shims | not ported (Arch-only payloads) |
| SPDX-style license tokens the tree lacks | map to the tree's tokens (`GPL-3.0-only`→`GPL-3`, `BSD-3-Clause`→`BSD`, ...) with a comment keeping the upstream truth |

Two tools encode the mechanical part:

- `bin/scaffold-ebuild <package>` — emits a marked UNREVIEWED skeleton
  (header fields, SRC_URI, RDEPEND skeleton, translated `package()` body)
  for a human or agent to finish. `--self-test` covers the rules.
- `bin/ai-port <package>` — the AI-first entry point: prints the complete
  task brief (house rules, PKGBUILD, aux files, dep map, target paths,
  definition of done, verify commands). `--run` hands the brief to a local
  agent CLI (`claude`, `codex`, `aider`, or `$AI_PORT_CMD`); `--verify`
  runs the local gates; `--list-open` prints the queue.
- `bin/sync-gentoo` — reconciles ebuilds with their Arch recipes: renames
  an ebuild when the PKGBUILD's version moved past the `# arch-pkgver:`
  baseline marker in the ebuild header (direction decided by vercmp;
  without it, the tool refuses to guess). `--check` reports drift only and
  is what the nightly `sync-check` job runs.
- `bin/gentoo-resolve` — the dependency-resolution gate, shared verbatim by
  CI and `--verify` so local and CI verdicts cannot drift. It classifies
  per package: plain resolution failures fail; "USE changes necessary"
  findings and closures blocked inside the Gentoo tree fixture (bare stage3
  is not a desktop profile; a few of the tree's newest ebuilds are
  keywordless) pass with a note, because neither is an overlay defect.

Ebuilds never carry checksums: `Manifest` files are generated by CI
(`pkgdev manifest`) at mirror time. Committing one is a CI conflict.

## The self-managed loop

Nobody shepherds the overlay by hand; the loop closes itself:

1. **Version bumps.** The `Upstream sync` workflow (every 3h) advances the
   `omarchy-pkgs/` submodule pin to omacom's master tip and runs
   `bin/sync-gentoo`, which renames any ebuild lagging its recipe (each
   ebuild carries a `# arch-pkgver:` baseline marker; the direction
   decision is made by vercmp). Clean mechanical renames are pushed
   straight to master; anything needing judgement files an
   agent-actionable issue. The nightly `sync-check` job re-verifies and
   files an issue on any drift that slipped through.
2. **PR gate** (`.github/workflows/gentoo.yml` → `lint`): `pkgcheck scan`
   (minus the Manifest check) and per-package `emerge --pretend`
   resolution, inside a stock stage3 container using repo-owned tooling
   only — the same trust model as the Arch PR builds. The offline tooling
   self-tests live in the separate `gentoo-tooling.yml` workflow.
3. **Nightly smoke emerge**: one rotating package per night is really
   emerged (Manifests generated, distfiles digested, build executed) in a
   fresh stage3 on the self-hosted runner, gated on the drift check and on
   its own inline pkgcheck scan. Small blast radius, real signal.
4. **Coverage backlog**: a nightly job files/updates a GitHub issue with
   the unported queue and the skip list — the work queue agents pick from.
5. **Failure path**: any gate failure on master or the nightly loop files a
   GitHub issue (`gentoo-overlay` label) with the run link. Fix, PR, next
   green run closes the loop.

## Maintenance notes

- `helpers/gentoo-deps.map` is the single mapping table for dependencies.
  When a port finds an Arch dependency with no Gentoo counterpart, add a
  `MANUAL:` row there and the skip entry — never guess an atom.
- `helpers/gentoo-packages.tsv` maps Arch names to overlay locations; it is
  what makes `bin/sync-gentoo` reconcile ebuilds and what makes the
  coverage queue complete. Add the row as part of any port.
- The published
  [omarchy-overlay](https://github.com/Lax/omarchy-overlay) repository is
  generated; never edit it directly. It is rewritten from `gentoo/` on
  every merge to master.
