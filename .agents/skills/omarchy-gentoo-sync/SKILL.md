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

0. **Coordinate with the automation first.** The `Upstream sync` automation
   pushes pin bumps to master every 3h; a shared checkout can be days behind
   it. `git fetch origin && git pull --rebase`, then take the old pin from
   `git ls-tree origin/master omarchy-pkgs` — the recorded pin, not the
   submodule checkout's HEAD (a stale local clone reported pin 592c85c on
   2026-09-30 while master was already at 5a49a3f via 11 automation bumps).
   Align the checkout to that pin with `git submodule update omarchy-pkgs`
   before any delta analysis, and read the open `gentoo-overlay` issues —
   each non-mechanical bump filed one.
1. `git status --short` must show no unexpected modifications. This checkout
   is shared by concurrent agent sessions; if files you did not touch are
   modified (README, assets/logo, …), leave them alone and commit only your
   own paths.
2. Record the current pin for the delta analysis:
   `old=$(git -C omarchy-pkgs rev-parse HEAD)`.
3. Confirm docker is present (`docker info`) — the heavy gates need it. If
   absent, everything except Step 6 still runs.
4. **Synced-repo discipline**: `/var/db/repos/omarchy` (the user's portage
   copy) is maintained by `emaint sync` — it is production state, not a
   second dev tree. Hotfixes for local testing (e.g. copying a fixed
   ebuild in with sudo) are temporary: once the fix is committed and
   published, restore the state — `git -C /var/db/repos/omarchy status
   --short` must be empty and everything owned by `portage:portage`. Root-owned
   files planted there break the next `emaint sync` with code 128 (the
   git child runs as the repo owner). Recovery, then re-sync:

   ```
   sudo chown -R portage:portage /var/db/repos/omarchy
   sudo emaint sync -r omarchy
   ```

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

Exit 0 with a `note gum: ...` line is a known-harmless status note (gum has
an ebuild but no upstream recipe; leave it). `skip` lines, by contrast, are
work orders — the upstream-sync automation files an issue when it sees one
(which is why that line is a note).

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
- **go-module ebuilds** (elephant, gum): the `-deps.tar.xz` lives in the
  mirror's `distfiles` release and is regenerated by hand at every bump —
  the automation renames the ebuild but cannot build the tarball, so the
  mirror's Manifest step 404s until it is uploaded (see the recipe in the
  elephant ebuild header).
- **Migrations are a follow-up surface**: after the package update,
  `omarchy-migrate` runs pending `migrations/<id>.sh` scripts and the first
  failure kills the whole `omarchy update` (`set -e`). A migration calling
  `omarchy-pkg-add` needs the Gentoo atom to exist and be installable, so
  when upstream ships new packages the backlog has not queued yet, expect
  the workstation update to die on them (omacalc/herdr, 2026-10). Dispositions:
  port the package; unmask a guru `~amd64` provider via
  `/etc/portage/package.accept_keywords/<name>`; or, when the migration does
  not apply to the machine at all (Arch `linux-omarchy` kernel + Limine
  edits, herdr's network-fetching zig build), mark it done machine-locally:
  `touch /var/lib/omarchy/migrations/<id>`. Skipped-for-cause packages still
  get a `gentoo-skip.tsv` row documenting the blocker.

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

Read the WHOLE pkgcheck findings for every package you touched in one
pass — not just the `FAIL`/`resolved` lines. A first run greps only for
failures, misses the fixable warnings (deprecated insinto, over-long
SRC_URI lines, a BDEPEND unkeyworded on an arch you declared), and buys
two extra full scans per finding. Filter to "warning exists in my new
package but in no existing one" — the overlay tolerates some known noise
(sys-apps/systemd profile findings, HomepageInSrcUri on pre-existing
packages), so the precedent, not the warning count, decides what to fix.

Gate classifications to read correctly:
- `ok <atom> (USE changes needed)` — fine: bare stage3 profile lacks desktop
  USE; the overlay's declarations are what's being checked.
- `ok <atom> (graph blocked by tree fixture; atom ok via --nodeps)` — fine.
- `FAIL` + `masked by: corruption` — the ebuild file name does not parse as
  a PMS version at all (portage cannot see the package; the 2026-09
  automation renames `…+build89647`/`…_23.BETA` were exactly this), or a
  stale root-owned `gentoo/metadata/md5-cache` from an earlier container run
  is poisoning the read. Check the file name first, then remove any
  root-owned md5-cache. `gentoo_version`/`is_pms_version` in
  `helpers/gentoo.sh` are the arbiters; `bin/sync-gentoo <pkg>` repairs the
  name. Same verdict can also mean global-scope `usex` in an ebuild — portage
  metadata generation runs without it; dispatch per-arch `S=` with
  `if [[ ${ARCH} == amd64 ]]` instead.
- `FAIL` on a package you didn't touch — investigate before assuming it's
  yours; check CI (`gh run list --workflow gentoo.yml`) for master parity.

Known gate blindness: **the resolve pass never checks that an atom exists**.
A dependency naming a package that is in no configured repo passes CI green
and only dies on a real emerge (2026-10: `x11-misc/sddm` in omarchy-base,
`gui-libs/xdg-desktop-portal` in three ebuilds — both stale after the tree
moved the packages). After any upstream sync that smells like a tree
reorganization, sweep by hand:

    grep -rhoE '\b[a-z0-9]+(-[a-z0-9]+)+/[A-Za-z0-9+_][A-Za-z0-9+_.-]*' \
      gentoo/*/*/*.ebuild helpers/gentoo-deps.map | sort -u

then check each `cat/pn` against `/var/db/repos/*/<cat>/<pn>` and
`gentoo/<cat>/<pn>`. Expect ~60 URL/path fragments in the output
(`releases/`, `squashfs-root/`, `github.com/...`) — only real
category/package shapes are hits. Moves recorded 2026-10: `sddm` →
`gui-apps`, `xdg-desktop-portal` → `sys-apps`, `libdrm` → `x11-libs`,
`libnotify` → `x11-libs`, `libsecret` → `app-crypt`, `which` → `sys-apps`.
Fix `helpers/gentoo-deps.map` rows in the same change; they go stale too.

## Step 7 — Commit and push

- Two commits, matching repo style (terse, lowercase, area-prefixed):
  1. `omarchy-pkgs: bump submodule to <short> (<one-line theme>)`
  2. `overlay: port <name>` / `overlay: drop <name>` / `overlay: fix <what>`
- Commit with explicit pathspecs (`git commit -m ... -- omarchy-pkgs`):
  the renames `git mv` stages make a bare `git commit` sweep them into
  the first commit (two sessions in a row lost clean history to this).
  But pathspec commits see only tracked paths — `git add` new package
  dirs first, or the commit records the rename as a bare deletion and
  strands the new file untracked. Verify with `git log --stat` before
  pushing.
- Never commit `Manifest` files or `metadata/md5-cache` — CI generates them.
- Multi-paragraph issue comments go through `gh issue comment --body-file`,
  never a double-quoted `--comment`: backticks inside one are one shell
  accident away from command substitution.
- Push straight to `master`. If rejected, `git pull --rebase` and retry.
- Nightly CI confirms the fix; check `gh run list --workflow gentoo.yml`
  after the nightly runs if you want closure.

## Step 8 — Report

End with: submodule `old → new`; drift status; adds/deletes/renames and what
was done with each; ports/skips/tooling changes made; gate results; backlog
(`bin/ai-port --list-open` OPEN items); CI status. In Chinese when the user
writes Chinese.

## Machine ops — running omarchy update for the user

The workstation's `omarchy update` is a user-facing wrapper that agents are
sometimes asked to debug. Traps hit on 2026-10-27/28, in order of appearance:

- It needs `OMARCHY_PATH=/usr/share/omarchy` forwarded
  (`sudo env OMARCHY_PATH=/usr/share/omarchy omarchy update -y`): the var is
  set by the graphical session only, and `omarchy-update-dev` dies on the
  unbound variable otherwise.
- **Every sudo run leaves root-owned `/tmp/omarchy-update.log` and
  `/tmp/omarchy-update.lock`**; sticky-bit /tmp then breaks the user's own
  next run (`script: cannot open ...: Permission denied`, then a dead lock).
  The update flow is over only after
  `sudo rm -f /tmp/omarchy-update.log /tmp/omarchy-update.lock`.
- Unattended (`-y`) does not cover everything: mise's config-trust question
  and the final gum "Reboot?" confirm both hang. Kill the run at the reboot
  prompt — never answer it on the user's behalf. Trust is recorded once via
  `sudo mise trust <config path>` (entries are symlinks under
  `<home>/.local/state/mise/trusted-configs/`; mise refuses to create them
  if a stale file occupies that path). Fresh npm releases additionally need
  `allow_low_downloads = true` on the tool entry in the user's
  mise config, and sit behind a 24h `minimum_release_age` after which the
  upgrade attempt resumes — pin the tool version in that config to ride out
  a flaky download window.
- Migration failures surface here too (see Step 5); a dead atom in any
  scheduled-to-merge ebuild (omarchy-base) aborts emerge with "no ebuilds to
  satisfy" and a spurious "run emaint --check world" hint.
- `pkill -f <pattern>` matches your own `bash -c` command line: bracket one
  character (`pkill -f "omarchy-updat[e]"`) and never mention the plain
  string anywhere else in the same command — including a log path.

## Tooling and skill maintenance

`bin/sync-gentoo`, `bin/scaffold-ebuild`, `bin/ai-port` and
`helpers/gentoo.sh` are the single source of truth for conversion rules.
When upstream's structure moves (Step 2.4), extend the tooling there — never
work around it ad hoc in an ebuild — and run all three `--self-test`s. If
this flow changed, update this SKILL.md in the same change so the skill
never drifts from reality.

New bash blocks destined for a workflow YAML get executed locally before
they are pushed — `bash -n` proves nothing about logic. An early orphan
check shipped with `$1 !~ /^(|#)/`, a regex that matches the empty string
and filtered out every row; a local dry-run caught it, the push would not
have. Paste the block into a shell, run it against the real tree, and only
then move it into the workflow.

And a local dry-run can still lie once: the steps run under
`set -euo pipefail`, your shell may not. `grep ... | head -1` passed
locally and failed CI on every large file — grep got SIGPIPE when head
closed the pipe, pipefail turned 141 into a failed pipeline. Under
pipefail, never put a early-exiting reader (head, grep -q) downstream of
a writer; capture through command substitution instead.
