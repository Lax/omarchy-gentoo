# omarchy-gentoo

Omarchy packages for Gentoo Linux, as a source-based ebuild overlay.

The Arch recipes live in the pinned [`omarchy-pkgs/` submodule](https://github.com/omacom/omarchy-pkgs); this repository turns them into ebuilds, validates them in a Gentoo stage3 container, and publishes the result as the `overlay` branch — which is what Portage users sync.

Maintained by automation and coding agents. `AGENTS.md` is the playbook; `docs/gentoo.md` is the full contract (translation rules, scope, the self-managed loop).

## Using the overlay

```ini
# /etc/portage/repos.conf/omarchy.conf
[omarchy]
location = /var/db/repos/omarchy
sync-type = git
sync-uri = https://github.com/Lax/omarchy-gentoo.git
sync-git-clone-extra-opts = --branch=overlay
priority = 50
```

Then `emaint sync -r omarchy` and `emerge <category>/<package>`. Keyword `~amd64`/`~arm64` as usual, and accept the proprietary licenses of the `-bin` packages, e.g. `*/* all-rights-reserved` in `/etc/portage/package.license`. See `docs/gentoo.md` for details.

## Layout

```
omarchy-pkgs/  submodule: omacom/omarchy-pkgs (the Arch recipes, pinned)
gentoo/        the ebuild overlay (mirrored to the `overlay` branch)
bin/           ai-port, sync-gentoo, scaffold-ebuild, gentoo-resolve
helpers/       conversion rules and ported/skipped bookkeeping
.github/       three workflows: gates, tooling self-tests, upstream sync
```

## How it maintains itself

- Every 3h, `Upstream sync` advances the submodule pin, reconciles ebuild versions against the new recipes, and pushes to master — filing an agent-actionable issue whenever a rename needs judgement.
- Nightly, the overlay loop really emerges one rotating package in a fresh Gentoo stage3, re-checks for drift, files the porting backlog as an issue, and mirrors `gentoo/` to the `overlay` branch.
- Any gate failure files an issue with the run link. Fix, push, and the next green run closes the loop.
