#!/usr/bin/env bash
# Docker verification gates for the omarchy-gentoo overlay: pkgcheck scan +
# bin/gentoo-resolve, the same checks CI's lint job runs.
#
# Why this script exists: bin/ai-port --verify boots a stock gentoo/stage3 and
# runs emerge-webrsync, whose signature verification refreshes Gentoo's
# signing keys over WKD (gentoo.org). On proxied/blocked networks that fetch
# times out (gemato ReadTimeout after 180s) and the bootstrap dies silently
# under `set -eu`. This script instead keeps a once-built stage3 image with
# pkgcheck preinstalled and mounts the HOST's /var/db/repos/gentoo tree
# read-only in place of webrsync — same tree fixture, no sync. Verdicts were
# verified equivalent to a green CI run (2026-09-25).
#
# Usage:
#   docker-gates.sh [category/package]   # pkgcheck scoped to one package
#                                        # + the full resolve loop (default)
#   docker-gates.sh --all                # pkgcheck over the whole overlay
#   docker-gates.sh --canonical cat/pkg  # the CI-identical bin/ai-port path
#                                        # (needs gentoo.org reachable)
#   docker-gates.sh --rebuild [args]     # re-seed the cached gate image
set -uo pipefail

BUILD_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
IMAGE=omarchy-gates:latest
SEED=omarchy-gates-seed
HOST_TREE=/var/db/repos/gentoo

die() { echo "error: $*" >&2; exit 2; }

rebuild=false
mode=full
target=
while (($#)); do
  case "$1" in
    --rebuild) rebuild=true; shift ;;
    --canonical) mode=canonical; shift; target=${1:-}; [[ -n $target ]] || die "--canonical needs category/package"; shift ;;
    --all) mode=all; shift ;;
    --self-test)
      echo "BUILD_ROOT=$BUILD_ROOT"
      [[ -d $BUILD_ROOT/gentoo && -f $BUILD_ROOT/bin/gentoo-resolve ]] ||
        die "BUILD_ROOT resolution failed; fix the dirname depth in this script"
      echo "self-test ok"
      exit 0 ;;
    */*) mode=scope; target=$1; shift ;;
    *) die "unknown argument: $1" ;;
  esac
done

command -v docker >/dev/null || die "docker not available"
[[ -d $BUILD_ROOT/gentoo && -f $BUILD_ROOT/bin/gentoo-resolve ]] ||
  die "resolved BUILD_ROOT=$BUILD_ROOT has no gentoo/ overlay; run from the repository checkout"

if [[ $mode == canonical ]]; then
  exec bin/ai-port --verify "$target"
fi

# One-time image seed: pkgcheck (pulled in via dev-util/pkgcheck) is the only
# thing the gates need that a stock stage3 lacks; baking it in keeps runs to
# ~a minute instead of a compile. The host tree is mounted for the seed too —
# a stock stage3 has no ::gentoo tree (webrsync would be needed and that is
# exactly what fails on this network).
if $rebuild || ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  [[ -d $HOST_TREE/profiles ]] || die "no $HOST_TREE on this host; use --canonical"
  echo "== seeding gate image ($IMAGE): emerge dev-util/pkgcheck =="
  docker rm -f "$SEED" >/dev/null 2>&1 || true
  docker run --name "$SEED" -v "$HOST_TREE:$HOST_TREE:ro" gentoo/stage3 \
    bash -c '
      set -eu
      mkdir -p /etc/portage/repos.conf
      ln -sf /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
      emerge --quiet dev-util/pkgcheck
    ' || {
      docker rm -f "$SEED" >/dev/null 2>&1 || true
      die "image seed failed (network? distfiles unreachable from container)"
    }
  docker commit "$SEED" "$IMAGE" >/dev/null
  docker rm "$SEED" >/dev/null
fi

scan_target=/var/db/repos/omarchy
[[ $mode == scope ]] && scan_target="/var/db/repos/omarchy/$target"

echo "== pkgcheck $( [[ $mode == scope ]] && echo "on $target" || echo "on the overlay" ) + full resolve loop =="
docker run --rm \
  -v "$BUILD_ROOT/gentoo:/var/db/repos/omarchy" \
  -v "$BUILD_ROOT/bin/gentoo-resolve:/usr/local/bin/gentoo-resolve:ro" \
  -v "$HOST_TREE:$HOST_TREE:ro" \
  "$IMAGE" bash -c '
    set -eu
    mkdir -p /etc/portage/repos.conf
    ln -sf /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
    printf "[omarchy]\nlocation = /var/db/repos/omarchy\nmasters = gentoo\nauto-sync = off\n" > /etc/portage/repos.conf/omarchy.conf
    pkgcheck scan -k,-MissingManifest --cache-dir /tmp/pkgcheck-cache '"$scan_target"'
    gentoo-resolve
  '
