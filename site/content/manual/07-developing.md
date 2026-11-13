---
title: Developing
desc: The two-tree architecture, the automations, the gates, and how to port a package into the omarchy overlay.
---
This page is the human-readable tour. The operative documents live in the
repository: [`AGENTS.md`](https://github.com/Lax/omarchy-gentoo/blob/master/AGENTS.md)
(the agent playbook — this overlay's primary maintainers are automation
and coding agents), [`docs/gentoo.md`](https://github.com/Lax/omarchy-gentoo/blob/master/docs/gentoo.md)
(the full Arch→Gentoo conversion contract), and
[`.agents/skills/omarchy-gentoo-sync/`](https://github.com/Lax/omarchy-gentoo/tree/master/.agents/skills/omarchy-gentoo-sync)
(the full sync workflow).

## Two trees

- **Lax/omarchy-gentoo** — this repository, the build root: the overlay,
  the tooling, the docs. Everything happens here.
- **`omarchy-pkgs/`** — a submodule pinned to omacom/omarchy-pkgs master:
  upstream's Arch recipes, the source of truth every ebuild must match.
- **Lax/omarchy-overlay** — the published tree users add to Portage. CI
  regenerates it from `gentoo/` on every merge to master, writes a
  `PROVENANCE` file naming the generating commits, and puts both ids in
  the mirror commit message. Never edit it directly.

Every Arch→Gentoo conversion rule lives in `helpers/gentoo.sh`, so the
tooling cannot disagree with itself. The bookkeeping tables say what
ships and why not everything does: `helpers/gentoo-packages.tsv` (rows),
`helpers/gentoo-deps.map` (dependency atoms), `helpers/gentoo-skip.tsv`
(skips with cause).

## The automations

| Workflow | Cadence | What it does |
| --- | --- | --- |
| `upstream-sync.yml` | every 3h | advances the submodule pin, reconciles drift, pushes, dispatches the overlay gates with the bumped atoms, files follow-up issues when a rename needs judgement |
| `gentoo.yml` | nightly, plus push/PR | the drift check gates: pkgcheck and scoped dependency resolution in a stock stage3 container, the nightly real emerge of one rotating package on the self-hosted runner, the whole-tree resolve, the overlay publish, and the porting-backlog issue; gate failures become `gentoo-overlay` issues, closed by the next green run |
| `gentoo-tooling.yml` | push/PR | offline self-tests for every tool, ebuild syntax, and the mapping tables' consistency with the tree |
| `site.yml` | push/PR | builds this site from the tree and deploys it to GitHub Pages |

Issues labelled `gentoo-overlay` are the maintenance queue: read the
issue, do what it says, verify with the gates, push.

## The gates

- `bin/sync-gentoo --check` — ebuild-vs-recipe drift (version pins and
  metadata), the gate that guards every bump.
- `pkgcheck scan` — the standard ebuild linter over the tree.
- `bin/gentoo-resolve` — dependency resolution of the touched packages
  (scoped by `bin/gentoo-resolve-scope`) inside a stock gentoo/stage3
  container; it classifies USE-change findings and verifies every
  dependency atom actually exists in resolution (the dead-atom gate,
  with a third-party provider allowlist).
- The nightly smoke — one rotating package is really emerged on the
  self-hosted runner, catching what resolution cannot see.
- This site's build — the coverage numbers must agree with
  `bin/ai-port --list-open`, the install commands must match the overlay
  README, and every internal link must resolve, or the build fails.

## Porting a package

```bash
bin/ai-port <package>               # the complete task brief: rules,
                                    # PKGBUILD, dep map, targets, checklist
bin/ai-port --list-open             # the unported queue
bin/ai-port --verify <cat>/<name>   # the CI gates, locally, one package
```

Do the work the brief describes, `bash -n` the ebuild, and run the verify
gate. Two hard rules: never commit `Manifest` files (CI generates them),
and never invent dependency atoms — if no Gentoo package exists, record
the blocker in `helpers/gentoo-skip.tsv` instead. The mechanical skeleton
comes from `bin/scaffold-ebuild`; the judgement (patches, USE handling,
the Gentoo shape) is the port.

## The tooling

- `bin/ai-port` — task briefs, the port queue, the local verify gate.
- `bin/sync-gentoo` — reconciles ebuilds with the pinned recipes.
- `bin/scaffold-ebuild` — mechanical PKGBUILD→ebuild skeletons.
- `bin/gentoo-resolve` / `bin/gentoo-resolve-scope` — the resolution
  gate and its scoping calculator.
- `bin/gentoo-runtime-map` — single-sources the runtime rename table
  between `helpers/gentoo.sh` and the shipped `omarchy-pkg-add`.
- `bin/gentoo-base-packages-audit`, `bin/gentoo-etc-audit`,
  `bin/gentoo-migration-audit` — diff omarchy-base, the `/etc` set and
  the migration surface against upstream, so nothing silently disappears.
- `bin/site-build` — this site: markdown in, static HTML out, every
  count generated from the tree.
