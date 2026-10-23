# GitHub Actions quota — profile, policy, degradation runbook

The policy this document backs lives in AGENTS.md ("Actions quota
policy"). This page records the numbers the policy was derived from and
the exact steps to take if the free tier ever disappears.

## The billing facts

- Both repositories (`Lax/omarchy-gentoo`, `Lax/omarchy-overlay`) are
  **public**: GitHub-hosted *standard* runners are free and unmetered on
  public repos. The Actions minutes these workflows consume never
  reached a bill.
- The self-hosted runner (`[self-hosted, omarchy-smoke]`) never bills.
- The Pro plan's included 3,000 min/month applies to **private repos
  only**. A repo going private is the one event that turns this usage
  into spend.

## Usage profile (measured 2026-09-25 → 2026-10-23, before scoping)

| Workflow | Runs / 4 wk | Wall clock total | Avg / run |
|---|---|---|---|
| gentoo.yml | 110 | ~10,400 min (incl. self-hosted nightly) | ~95 min |
| upstream-sync.yml | 113 | ~57 min | ~0.5 min |
| gentoo-tooling.yml | 55 | ~50 min | ~0.9 min |

The gentoo.yml average was dominated by the lint job's
whole-tree resolve of every package on every run (~40-70 min) plus
uncached cold starts (webrsync + pkgdev install + pkgcheck).

## Measures in place (2026-10-23)

1. **Scoped resolution** — `bin/gentoo-resolve-scope` decides, per
   change set, which packages `gentoo-resolve` must check: the touched
   packages plus their in-overlay reverse dependents, with umbrella
   metapackages excluded from the expansion and a 20-atom budget that
   falls back to the whole tree. Push/PR runs derive the scope from the
   git range; the upstream-sync dispatch passes the atoms it bumped via
   the `resolve_atoms` input; an atoms-less manual dispatch and every
   ambiguity resolve the whole tree (fail safe).
2. **Nightly whole-tree resolve** — moved into the smoke job on the
   self-hosted runner, which already ran a tree-wide pkgcheck scan.
   The safety net is intact and off the cloud.
3. **pkgcheck cache** — the lint job persists its cache via
   `actions/cache` (weekly key); the smoke job persists its cache in
   `/data/cache/omarchy-runner/pkgcheck`.
4. **Timeouts on every cloud job** — lint 90, sync-check/coverage 15,
   report/close-loop 10, tooling self-tests 15; smoke 420 on the
   self-hosted runner (unguarded hangs were observed: a 1,441-minute
   run in the measurement window).
5. **No artifacts, no larger runners** — nothing uploads artifacts, no
   runner label outside `ubuntu-24.04` and the self-hosted pair.

Expected effect: a typical upstream-bump lint drops from ~95 to
~15-25 minutes; monthly cloud usage from ~6-9k to ~1.5-2.5k minutes.

## Monitoring

A monthly automation re-checks the invariants: both repos still public,
no artifacts present, no runner labels outside the allowlist, billing
API reachable with a `user`-scoped token (reports rather than fails
when the token lacks the scope). Any billed Actions minute, any
non-public repo, any new runner type is a regression to investigate the
same day.

## Degradation runbook

Trigger: a repo went (or must go) private, GitHub changes public-repo
pricing, or the monthly check reports billed minutes.

1. **Move lint/resolve to the self-hosted runner.** The lint job is a
   `docker run` of a stock stage3; the self-hosted machine already runs
   the same pattern (smoke, mirror) with persistent caches and the
   host-synced ::gentoo tree mounted read-only. Change `runs-on` to
   `[self-hosted, omarchy-smoke]`, drop the `actions/cache` step in
   favor of a `/data/cache/omarchy-runner/pkgcheck` mount, and swap
   `emerge-webrsync` for the host-tree branch the smoke job uses.
   `bin/gentoo-resolve-scope` and all repo-owned tooling work unchanged.
2. **Keep PR checks cloud-side or gate them.** The trust model forbids
   fork PR code from reaching the self-hosted machine (smoke and mirror
   are schedule/dispatch-only for this reason). If lint moves
   self-hosted, run PR checks on `ubuntu-24.04` with the offline self
   tests only, and let master pushes carry the full gate — or adopt a
   maintainer-dispatch ("label to build") flow.
3. **Move the mirror if it is not already self-hosted** — it already is
   (`[self-hosted, omarchy-smoke]`); nothing to do.
4. **What stays on the cloud:** `upstream-sync.yml` (an Arch container
   doing a submodule bump, a push and a dispatch) and
   `gentoo-tooling.yml` (offline self-tests) — together ~115 min/month,
   under 4% of the 3,000-minute private-repo allowance.
5. **Re-measure after the move** with the same
   `gh run list --json startedAt,updatedAt` aggregation used for the
   profile above, and update this page.

Failure mode to avoid: silently letting a private-repo cutover burn the
3,000 minutes on unscoped resolves. If minutes show up in the bill
before the runbook runs, the quickest stopgap is forcing
`bin/gentoo-resolve-scope --full` calls down to nightly-only by
short-circuiting the lint job's resolve step — one-line change, restores
the old behavior at the old cost profile, and the nightly still owns the
whole tree.
