# arch-pkgver: 4.0.4
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

EAPI=8

inherit shell-completion

DESCRIPTION="Omarchy desktop runtime CLI, themes and shell (Gentoo meta package)"
HOMEPAGE="https://github.com/omacom/omarchy"

# Mirrors the pin block of upstream omacom/omarchy-pkgs pkgbuilds/omarchy.
# _tag is provenance only; _commit is the single source of truth. Must stay in
# lockstep with app-misc/omarchy-settings — scripts/bump-omarchy.sh rewrites both.
OMARCHY_TAG="v4.0.4"
OMARCHY_COMMIT="c668141e9c42b13c80c9ca4ea108e11708c5e8a5"
SRC_URI="https://github.com/omacom/omarchy/archive/${OMARCHY_COMMIT}.tar.gz -> omarchy-${PV}.tar.gz"
S="${WORKDIR}/omarchy-${OMARCHY_COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Translation of the upstream PKGBUILD depends array: "only packages whose
# removal would brick the desktop" plus what the omarchy-* scripts require.
#   omarchy-keyring     -> n/a (portage verifies Manifest hashes)
#   omarchy-settings    -> lockstep pin, mirrors upstream's =omarchy-settings
#   fakeroot/pacman-contrib -> the portage toolbelt (eix/gentoolkit/portage-utils)
#   limine*/snapper     -> Gentoo boots via grub/systemd-boot; no bootloader here
#   ttf-jetbrains-mono-nerd-basic -> media-fonts/jetbrains-mono-nerd-basic
# tensaku -> upstream base.packages line 114 and the default screenshot
#   editor: omarchy-capture-screenshot hands captures to tensaku-edit
#   unless $OMARCHY_SCREENSHOT_EDITOR is set
RDEPEND="
	~app-misc/omarchy-settings-${PV}
	app-misc/jq
	app-portage/eix
	app-portage/gentoolkit
	app-portage/portage-utils
	app-shells/bash-completion
	app-shells/fzf
	app-shells/gum
	dev-lang/perl
	dev-vcs/git
	gnome-base/gnome-keyring
	gui-apps/grim
	gui-apps/slurp
	gui-apps/tensaku
	gui-apps/quickshell
	gui-apps/uwsm
	gui-apps/wl-clipboard
	gui-libs/xdg-desktop-portal-hyprland
	gui-wm/hyprland
	media-fonts/jetbrains-mono-nerd-basic
	media-gfx/imagemagick
	media-video/pipewire
	media-video/wireplumber
	net-misc/networkmanager
	x11-misc/sddm
"

# bin/ scripts re-authored for portage (pacman/yay are Arch-only).
# scripts/bump-omarchy.sh checks upstream bin/ against this list and flags
# anything that started depending on pacman elsewhere.
OMARCHY_PORTED_BIN=(
	omarchy-pkg-present
	omarchy-pkg-missing
	omarchy-pkg-add
	omarchy-pkg-drop
	omarchy-pkg-install
	omarchy-pkg-remove
	omarchy-pkg-aur-accessible
	omarchy-pkg-aur-add
	omarchy-pkg-aur-install
	omarchy-update-system-pkgs
	omarchy-update-system-pkgs-when-conflicted
	omarchy-update-keyring
	omarchy-update-aur-pkgs
	omarchy-update-orphan-pkgs
	omarchy-update-pkg-prune
	omarchy-update-available
	omarchy-version-pkgs
	omarchy-version
	omarchy-channel-current
	omarchy-channel-set
	omarchy-refresh-pacman
	omarchy-reinstall-pkgs
	omarchy-update-pacman-guard
	omarchy-upgrade-to-quattro
	omarchy-dev-pkg-test
)

src_prepare() {
	default
	# Small in-place patches to otherwise portable upstream scripts.
	eapply "${FILESDIR}"/omarchy-gentoo-*.patch
}

src_install() {
	local om=/usr/share/omarchy

	# Runtime binaries: everything in bin/ except the three helpers that ship
	# from omarchy-settings, and except the pacman-bound scripts replaced by
	# the portage adaptations in files/gentoo-bin/.
	exeinto /usr/bin
	local bin base skip
	for bin in bin/*; do
		[[ -f ${bin} ]] || continue
		base=${bin##*/}
		case "${base}" in
			omarchy-debug|omarchy-debug-idle|omarchy-upload-log) continue ;;
		esac
		for skip in "${OMARCHY_PORTED_BIN[@]}"; do
			[[ ${base} == "${skip}" ]] && continue 2
		done
		dobin "${bin}"
	done
	dobin "${FILESDIR}"/gentoo-bin/*

	# The legacy-only omarchy-completions atom, folded here (upstream ships the
	# completion inside the omarchy repo at default/bash/completions but never
	# packages it): standard lazy-load lookup path, named after the command.
	newbashcomp default/bash/completions omarchy

	# /usr/share/omarchy/bin symlink farm (scripts invoke through it). The
	# bare `omarchy` entry has no dash, so it needs its own glob term.
	insinto "${om}"
	dodir "${om}/bin"
	for bin in "${ED}"/usr/bin/omarchy "${ED}"/usr/bin/omarchy-*; do
		dosym -r "/usr/bin/${bin##*/}" "${om}/bin/${bin##*/}"
	done

	# Target-side setup scripts and package lists (used by refresh/reinstall
	# commands and as documentation of the upstream default package set).
	insinto "${om}"
	doins -r install
	# Theme bundles for theme switching.
	doins -r themes
	# Versioned migrations runner reads from this tree.
	doins -r migrations
	# Quickshell desktop shell tree.
	doins -r shell
	# Runtime version file.
	doins version

	# Migrations that cannot work on Gentoo (Arch-only snapshot stack etc.)
	# are listed here; the patched bin/omarchy-migrate skips and marks them
	# done. See files/gentoo-migrate-skip for the per-entry reasons.
	# NOTE: insinto is sticky for subsequent doins, so this block must stay
	# after every other doins above.
	insinto "${om}/gentoo"
	newins "${FILESDIR}"/gentoo-migrate-skip migrate-skip

	# Fresh users start with all shipped migrations marked done; existing users
	# keep their own state (mirrors upstream).
	local migration
	dodir /etc/skel/.local/state/omarchy/migrations
	for migration in migrations/*.sh; do
		[[ -e ${migration} ]] || continue
		touch "${ED}/etc/skel/.local/state/omarchy/migrations/${migration##*/}"
	done
}

pkg_postinst() {
	elog "Omarchy runtime ${PV} installed (${OMARCHY_TAG})."
	elog "  emerge app-misc/omarchy installs the whole desktop dependency set;"
	elog "  the omarchy-* CLI is on PATH and /usr/share/omarchy/bin."
	elog "  pacman-bound scripts are ported to portage (omarchy update, omarchy pkg ...)."
	elog "  libalpm hooks (update guard, Hyprland reload pause) have no portage"
	elog "  equivalent and are not shipped; run 'omarchy update' instead of raw emerge."
	elog "  Bash completion loads lazily on the first omarchy completion; upstream"
	elog "  sources it at shell startup instead."
}
