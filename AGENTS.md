# AGENTS.md — working on omarchy-gentoo with coding agents

This repository is maintained by AI coding agents alongside humans. Every
workflow an agent is expected to perform has: a machine-readable source of
truth, a deterministic self-verification gate, and a scheduled automation
that keeps the tree healthy without human prompting. Read this file first;
it tells you which gate proves your work.

## What this repository is

A Gentoo ebuild overlay for Omarchy packages, published to the
[omarchy-overlay](https://github.com/Lax/omarchy-overlay) repository
(whose tree root IS the overlay; CI republishes it on every merge to
master). The Arch recipes it is derived from are **not** part of this
repository: they live in the pinned `omarchy-pkgs/` submodule
(omacom/omarchy-pkgs, tracked to its master branch). This is a two-root project:

- `BUILD_ROOT` — this repository (overlay, tooling, docs, workflows).
- `upstream/` — the submodule; `omarchy-pkgs/pkgbuilds/<name>/PKGBUILD` is the
  source of truth for what our ebuilds must match. Override its location
  with `OMARCHY_UPSTREAM` for odd checkouts.

Every Arch→Gentoo conversion rule lives in `helpers/gentoo.sh` so the
tooling cannot disagree with itself.

## Repository layout

- `gentoo/` — the overlay. Never commit `Manifest` files; CI generates them.
  The published omarchy-overlay repository carries a root `PROVENANCE` file
  recording the master commit it was generated from and the `omarchy-pkgs`
  commit its recipes reflect; both ids are also in every mirror commit
  message.
- `omarchy-pkgs/` — submodule (named after the upstream repo). Update it
  via the `Upstream sync` automation, or by hand:
  `git submodule update --remote omarchy-pkgs`.
- `helpers/gentoo-packages.tsv` — which Arch packages have an ebuild, and
  where (`arch-name → category → gentoo-name`).
- `helpers/gentoo-deps.map` — Arch dependency → Gentoo atom mapping.
- `helpers/gentoo-skip.tsv` — packages intentionally not ported, with reasons.
- `bin/ai-port` — the agent entry point (see below).
- `bin/sync-gentoo` — reconciles ebuilds with the recipes; safe to re-run.
- `bin/scaffold-ebuild` — mechanical PKGBUILD→ebuild skeleton generator.
- `bin/gentoo-resolve` — the per-package resolution gate (docker stage3).

## The automation (what maintains itself)

- **Upstream sync** (`upstream-sync.yml`, every 3h): advances the submodule
  pin, runs `bin/sync-gentoo`, and pushes the result to master. When a
  rename is not purely mechanical it files a `gentoo-overlay` issue —
  that issue is your work order.
- **Gentoo overlay** (`gentoo.yml`): nightly smoke emerge of one rotating
  package (self-hosted runner, gated on the drift check), the nightly
  porting-backlog issue (the queue of unported packages, from
  `bin/ai-port --list-open`), `sync-check` (fails on ebuild drift), the
  omarchy-overlay publish, and automatic issue filing on any gate failure.
- **Gentoo tooling** (`gentoo-tooling.yml`): offline self-tests on every
  PR/push touching the overlay or tooling.

## Agent workflows

### Pick up a work order (issue)

Issues labelled `gentoo-overlay` are the maintenance queue. Read the issue,
do what it says, verify with the gates below, and push to master (or open a
PR if the change is judgement-heavy). Typical work orders:

- "upstream sync needs follow-up": a rename left a pinned URL naming the
  old release. Update `SRC_URI`/commit pins in the named ebuild(s), then
  `bin/ai-port --verify <category>/<name>`.
- "automated gates failing": a gate failed on master. Reproduce locally
  (see below), fix, push.

### Port a new package

```
bin/ai-port <package>          # prints the complete task brief (rules,
                               # PKGBUILD, dep map, target paths, checklist)
bin/ai-port --run <package>    # same brief, handed to a local agent CLI
bin/ai-port --list-open        # the unported queue — pick from here
```

Do the work described in the brief, then self-verify with the same gates
CI runs:

```
bash -n gentoo/<category>/<name>/*.ebuild
bin/ai-port --verify <category>/<name>    # docker stage3: pkgcheck + resolve
```

Do not commit Manifest files. Do not invent dependency atoms that are not
in `helpers/gentoo-deps.map` — if no Gentoo package exists, record the
blocker in `helpers/gentoo-skip.tsv` instead.

### Bump an ebuild by hand (rare)

Normally `Upstream sync` does this. By hand:

```
git submodule update --remote omarchy-pkgs
bin/sync-gentoo <package>      # or with no arguments, every table row
bin/sync-gentoo --check        # report-only; exits 1 on drift
```

### Sync the whole overlay (skill)

The full cycle — submodule bump, delta analysis, ports/skips, gates,
commit+push — is codified in `.agents/skills/omarchy-gentoo-sync/`. Invoke it
(`/omarchy-gentoo-sync`) or follow its SKILL.md directly for a hand-run sync;
its `scripts/docker-gates.sh` is the local gate runner with the host-tree
fallback for networks where the stock webrsync path cannot reach gentoo.org.

### Tooling changes

All scripts carry self-tests; run them plus the mapping-table walk:

```
bin/scaffold-ebuild --self-test
bin/ai-port --self-test
bin/sync-gentoo --self-test
```

## Local setup

```
git clone --recurse-submodules https://github.com/Lax/omarchy-gentoo.git
cd omarchy-gentoo
```

The full overlay gates need docker (gentoo/stage3) and take a while;
`bin/ai-port --verify <category>/<name>` scopes them to one package.

## The gates (what CI runs)

- `gentoo-tooling.yml`: the self-tests above, mapping-table/overlay
  consistency, baseline markers present on every ebuild.
- `gentoo.yml` → `lint`: `pkgcheck scan` (Manifest check excluded — CI
  generates Manifests) and per-package resolution via `bin/gentoo-resolve`
  inside a stock gentoo/stage3 container, repo-owned tooling only.
- `gentoo.yml` → nightly: `sync-check` (drift) gates the smoke emerge (a
  real build of one rotating package on the self-hosted runner); the
  mirror (publishes to Lax/omarchy-overlay) runs on push; issue filing on
  failure.

If a gate fails on master, the automation files a GitHub issue
(`gentoo-overlay` label). Fix the issue, push, and the nightly loop
confirms the fix. Humans review what automation cannot judge; agents and
gates do the rest.
