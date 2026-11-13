# Changelog

Notable changes to the omarchy-gentoo overlay itself: ports, skips and
drops, tooling and gate changes, operational incidents worth remembering.
Routine upstream pin bumps and per-nightly drift reconciliation are the
automation's work and are not recorded here. Updated by hand when such a
change lands; newest month first.

## 2026-11

- The theme/plugin compatibility round: audited upstream's theme and
  plugin machinery script by script (all of it is git + file operations —
  zero pacman, zero sudo — and the omarchy ebuild ships bin/* unpatched,
  so the command surface is identical by construction). Ported the two
  gaps: x11-themes/aether-bin (the theme editor GUI; upstream ships
  release binaries) and x11-themes/yaru-icon-theme (the icon split of
  ubuntu/yaru, configured -Dicons-only because dev-util/sassc is gone
  from the ::gentoo 2026 tree); both now RDEPENDed by omarchy-base, the
  stale skip.tsv yaru row removed. ai-port --verify mounts the provider
  allowlist now, matching CI's lint job — local verifies of umbrella-
  scoped packages no longer false-FAIL on the hyproverlay providers.
  The manual grew upstream's layout (left sidebar) and two pages —
  Themes and Plugins — documenting the Gentoo side: the commands are
  upstream's unmodified, here is what ships around them, and here is
  the honest pending list.
- Follow-up on the recipes' org move: omarchy-themes-intros SRC_URI/HOMEPAGE
  and the overlay README's upstream link retargeted from basecamp/omarchy to
  omacom/omarchy (fetches worked via GitHub redirect until now); once-bin
  keeps basecamp/once — upstream's own recipe still names it. The
  upstream-sync bump job got its policy timeout-minutes (every cloud job,
  AGENTS.md); the stale bin/gentoo-coverage pointer in gentoo-skip.tsv now
  names the real readers.
- Documentation site: `site/` + `bin/site-build` (vendored python-markdown,
  zero external deps) + `site.yml` — deployed to GitHub Pages on every
  push; coverage/news/install-command pages are generated from the tree at
  build time (counts cross-checked against `bin/ai-port --list-open`), so
  the site cannot drift from the overlay. The Pages artifact is the repo's
  first artifact (retention-days: 7); the monthly quota check's baseline
  moved accordingly.
- Omarchy 4.5.0 wave: regenerated patches, ported omasnap, replaced tensaku
  per upstream, triaged the migration surface (Limine, titlebars, signed:
  skip-for-cause), shipped the full omarchy-settings /etc set.
- New gates: the resolve pass verifies every dep atom exists (dead-atom
  gate with a third-party provider allowlist, 11-03);
  gentoo-base-packages-audit diffs omarchy-base against upstream
  base.packages; gentoo-etc-audit diffs the upstream etc tree against
  OMARCHY_ETC_KEEP.
- Ports: gridcraft-bin, wordcraft-bin, hex-bin, amp-desktop-bin, omasnap,
  yt-dlp (zipapp with bundled ejs, node runtime), plain (Qt Quick editor).
- Skips: herdr family (vendored zig build cannot fetch offline);
  slack-desktop deferred (per-arch electron swap needs a dedicated wave).
- ::gentoo last-rited app-arch/p7zip: swapped the dead atom for
  app-arch/7zip across the tree along with the 7zz invocation; fixed the
  bambustudio-bin distfile rename the mirror job surfaced.
- sync-gentoo falls back to portage's vercmp when pacman's is absent (the
  self-hosted runner has no Arch tooling).
- Nightly smoke stabilized after the 11-08..11-12 failure streak (issue
  #57): rerun emerge once after autounmask writes USE changes; pull a fresh
  stage3 per run; mask the openssl 3→4 tree-side transition that the
  image-era slot pins cannot cross.
- Overlay at 95 packages; submodule tracks omacom/omarchy-pkgs master.

## 2026-10

- Ports: omacalc, the browser quartet (brave-bin, brave-origin-bin,
  microsoft-edge-stable-bin, zen-browser-bin), t3code-bin +
  t3code-nightly-bin, disktree-bin, tmog-bin, cua-driver-bin, dropbox-cli,
  rawmakase-bin, dingtalk-bin, feishu-bin, wechat-bin, maplemono-nf-cn.
- omarchy-base reconciled to upstream 4.0.6; an orphan gate closed the
  no-row blind spot (upstream packages that had no packages.tsv row).
- sync-gentoo: git-revision counters fold to PMS `_p` suffixes; opaque
  pins re-read from the PKGBUILD at bump time; missing-upstream-recipe
  demoted to a status note.
- CI: automation bumps publish via explicit dispatch only; the docker
  scripts in gentoo.yml are linted for quote safety; smoke distfile
  fetches retry and fail fast (vendor CDN stalls cost the 10-04/10-05
  nightlies).

## 2026-09

- Project start (09-23): two-root layout — this repo is overlay + tooling +
  docs, the Arch recipes live in the pinned omarchy-pkgs submodule; the
  Arch→Gentoo conversion rules live in helpers/ and bin/ so tooling cannot
  disagree with itself.
- Initial ports: the legacy desktop stack plus the mechanical -bin batch.
- Automation established: upstream-sync (3h pin advances + sync-gentoo),
  nightly drift-gated smoke emerge on the self-hosted runner, sync-check,
  mirror publishing to Lax/omarchy-overlay, issue-filing close-loop on gate
  failures, and the omarchy-gentoo-sync skill.
- Branded packages gathered into omarchy/ and omarchy-extra/; the full
  install set ships as app-misc/omarchy-base.
- First gate incidents fixed: two distfile breaks the mirror caught, and
  the SDDM session pick.
