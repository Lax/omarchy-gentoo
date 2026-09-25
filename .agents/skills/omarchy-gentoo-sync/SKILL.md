---
name: omarchy-gentoo-sync
description: Full upstream-sync workflow for the omarchy-gentoo overlay — advance the omarchy-pkgs submodule, detect version bumps / package adds-deletes-renames / upstream structure changes, do the follow-up work (port, skip, bump ebuilds, update tooling), run the verification gates, commit and push. Use whenever the user asks to 同步子模块/同步上游, sync or update omarchy-pkgs, check overlay drift, 更新软件版本/软件增删, port new packages, or in this repo says anything like "submodule 更新同步，以及后续跟进" — even a bare "sync and follow up".
---

# omarchy-gentoo upstream sync

Run the repository's whole upstream-sync cycle by hand: submodule pin → delta
analysis → follow-up work → gates → commit+push → report. The `Upstream sync`
automation does the mechanical part every 3h; this skill is the catch-up and
the judgement layer it cannot do (ports, skips, renames, structure changes).

Everything here runs from the repository root (BUILD_ROOT). The Arch recipes
live in the `omarchy-pkgs/` submodule; `upstream-sync.yml`'s issue filings and
`bin/ai-port --list-open` are the work queues when you need something to do.

## Step 0 — Preflight

1. `git status --short` must show no unexpected modifications. This checkout
   is shared by concurrent agent sessions; if files you did not touch are
   modified (README, assets/logo, …), leave them alone and commit only your
   own paths.
2. Record the current pin for the delta analysis:
   `old=$(git -C omarchy-pkgs rev-parse HEAD)`.
3. Confirm docker is present (`docker info`) — the heavy gates need it. If
   absent, everything except Step 6 still runs.

## Step 1 — Sync the submodule

```
git submodule update --remote omarchy-pkgs
new=$(git -C omarchy-pkgs rev-parse HEAD)
```

If `old == new`, upstream hasn't moved: still run Step 3 (drift check) and
Step 6 (gates) as a health pass, then report "already current" and stop.

## Step 2 — Analyze the delta (`old..new` in omarchy-pkgs)

Four questions, in this order:

1. **Version updates of already-ported packages** — for every row of
   `helpers/gentoo-packages.tsv`, compare the PKGBUILD `pkgver` against the
   ebuild PV. Don't do this by eye: `bin/sync-gentoo --check` (Step 3)
   reports drift per row.
2. **Package adds / deletes / renames**:
   `git -C omarchy-pkgs diff --name-status "$old..$new" -- pkgbuilds/ | grep -E '^(A|D|R)'`.
   Every A/D/R needs a disposition (Step 5); a silent diff is not done.
3. **Recipe changes inside existing packages**:
   `git -C omarchy-pkgs diff --stat "$old..$new" -- pkgbuilds/`.
   Read the actual diffs of anything touched: an `arch=()` change can silently
   move a package in/out of scope, a `source=`/commit-pin change needs the
   ebuild's SRC_URI updated by hand, dep changes may need new
   `helpers/gentoo-deps.map` rows.
4. **Structure changes** — new auxiliary file patterns (`.omarchy/` metadata,
   `.install` scripts, vendored patches/configs), new packaging models, new
   architectures. These are tooling work orders: if `bin/` or `helpers/`
   misclassifies or can't translate the new shape, update the tooling (with
   its self-tests) and, when the *flow itself* changes, update this SKILL.md.

## Step 3 — Mechanical drift

```
bin/sync-gentoo --check     # report-only; exit 1 on drift
bin/sync-gentoo             # apply what it can mechanically
```

Exit 0 with a `skip gum: ...` line is a known-harmless note (gum has an
ebuild but no upstream recipe; leave it).

## Step 4 — Classify new packages

`bin/ai-port --list-open` prints the unported queue with skip annotations.
Classification logic lives in `bin/ai-port` (`package_class`) — trust it:

- `arch=(any)` or `x86_64` in `arch=()` → in scope → port (or skip with a
  reason row in `helpers/gentoo-skip.tsv`).
- `-bin` packages with only `aarch64` → stay OPEN as future work orders (the
  overlay carries `~arm64` KEYWORDS on ~36 ebuilds; aarch64 is in scope).
- Non-bin packages that are `aarch64`-only → class wave3, silently out of the
  queue; no table row needed.
- Before porting, check the skip table: `in-gentoo` (Gentoo monorepo has it),
  `arch-only`, `blocked` (hard blocker), `wave3`.

## Step 5 — Follow-up work

- **Port a package**: `bin/ai-port <package>` prints the complete brief
  (house rules, dep map, target paths, checklist) — follow it. Scaffold with
  `bin/scaffold-ebuild <package>` (needs the packages.tsv row first), then
  hand-finish. Delete the UNREVIEWED banner only after the ebuild is real.
  Table row + dep-map rows are part of the port, not an afterthought.
- **Delete a package** (upstream removed it): remove the ebuild directory,
  its `gentoo-packages.tsv` row, and add a `gentoo-skip.tsv` row when the
  removal has a reason future agents should know. Then check for **empty
  leftover directories** — git doesn't track them, so they survive on disk,
  get mounted into gate containers, and fail the full resolve loop
  (this actually happened with `gentoo/sys-process/tmog-bin/`).
- **Rename / re-pin**: update SRC_URI and commit pins in the named ebuilds,
  then verify just that package.
- **Version bump of an existing ebuild**: rename `-<old>.ebuild` →
  `-<new>.ebuild` only when the package moved (otherwise sync-gentoo handles
  in-place fields); update `# arch-pkgver:` header comment.

## Step 6 — Gates

Light (always, seconds): the three tooling self-tests, `bash -n` on every
touched ebuild, `bin/sync-gentoo --check` exit 0.

Heavy (docker, minutes) — use the bundled script:

```
.agents/skills/omarchy-gentoo-sync/scripts/docker-gates.sh [category/package]
```

It builds (once) a gentoo/stage3 image with pkgcheck preinstalled (`--rebuild`
refreshes it), mounts the overlay, runs `pkgcheck scan` + `bin/gentoo-resolve`
— the same checks CI's lint job runs. `--all` scans the whole overlay instead
of one package. Verify the script's path resolution with `--self-test` after
moving it. Why not plain `bin/ai-port --verify`: inside a stock
stage3 the container runs `emerge-webrsync`, whose signature verification
does a WKD key refresh against gentoo.org; on proxied/blocked networks that
times out (ReadTimeout after 180s) and the script dies silently under
`set -eu`. The bundled script instead mounts the host's `/var/db/repos/gentoo`
read-only — same tree fixture, no webrsync. Verdicts were verified equivalent
to a green CI run on 2026-09-25. Pass `--canonical` to run the CI-identical
path anyway (needs gentoo.org reachable).

Gate classifications to read correctly:
- `ok <atom> (USE changes needed)` — fine: bare stage3 profile lacks desktop
  USE; the overlay's declarations are what's being checked.
- `ok <atom> (graph blocked by tree fixture; atom ok via --nodeps)` — fine.
- `FAIL` on a package you didn't touch — investigate before assuming it's
  yours; check CI (`gh run list --workflow gentoo.yml`) for master parity.

## Step 7 — Commit and push

- Two commits, matching repo style (terse, lowercase, area-prefixed):
  1. `omarchy-pkgs: bump submodule to <short> (<one-line theme>)`
  2. `overlay: port <name>` / `overlay: drop <name>` / `overlay: fix <what>`
- Never commit `Manifest` files or `metadata/md5-cache` — CI generates them.
- Push straight to `master`. If rejected, `git pull --rebase` and retry.
- Nightly CI confirms the fix; check `gh run list --workflow gentoo.yml`
  after the nightly runs if you want closure.

## Step 8 — Report

End with: submodule `old → new`; drift status; adds/deletes/renames and what
was done with each; ports/skips/tooling changes made; gate results; backlog
(`bin/ai-port --list-open` OPEN items); CI status. In Chinese when the user
writes Chinese.

## Tooling and skill maintenance

`bin/sync-gentoo`, `bin/scaffold-ebuild`, `bin/ai-port` and
`helpers/gentoo.sh` are the single source of truth for conversion rules.
When upstream's structure moves (Step 2.4), extend the tooling there — never
work around it ad hoc in an ebuild — and run all three `--self-test`s. If
this flow changed, update this SKILL.md in the same change so the skill
never drifts from reality.
