# arch-pkgver: 4.0.4
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

EAPI=8

inherit desktop systemd

DESCRIPTION="Omarchy user defaults, skel content, fonts, and helpers (Gentoo port)"
HOMEPAGE="https://github.com/omacom/omarchy"

# Mirrors the pin block of upstream omacom/omarchy-pkgs pkgbuilds/omarchy-settings.
# _tag is provenance only; _commit is the single source of truth. Must stay in
# lockstep with app-misc/omarchy — scripts/bump-omarchy.sh rewrites both.
OMARCHY_TAG="v4.0.4"
OMARCHY_COMMIT="c668141e9c42b13c80c9ca4ea108e11708c5e8a5"
SRC_URI="https://github.com/omacom/omarchy/archive/${OMARCHY_COMMIT}.tar.gz -> omarchy-${PV}.tar.gz"
S="${WORKDIR}/omarchy-${OMARCHY_COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-shells/bash
	app-shells/gum
	net-misc/curl
	x11-themes/hicolor-icon-theme
"
BDEPEND="
	media-gfx/imagemagick
"

# /etc drop-ins we install for real (portage CONFIG_PROTECT guards user edits,
# the Gentoo equivalent of pacman's backup=() array). Deliberate allowlist, not
# a denylist: new upstream /etc files must be reviewed before they ship.
# Filtered out as Arch-specific: mkinitcpio.conf.d, limine-entry-tool.d,
# nsswitch.conf, security/faillock.conf, plymouth/plymouthd.conf (upstream
# stages the last four as etc-overrides; a Gentoo port never clobbers them),
# sysusers.d/omarchy-cups-browsed.conf (creates a user for cups we don't ship)
# and tmpfiles.d/omarchy-zswap.conf (disables zswap, which only makes sense
# with the always-zram Arch kernel).
OMARCHY_ETC_KEEP=(
	NetworkManager/conf.d/omarchy-wifi-powersave.conf
	docker/daemon.json
	fastfetch/config.jsonc
	gnupg/dirmngr.conf
	mise/conf.d/omarchy.toml
	modprobe.d/omarchy-usb-autosuspend.conf
	profile.d/omarchy.sh
	sddm.conf.d/10-theme.conf
	sddm.conf.d/10-wayland.conf
	sudoers.d/omarchy-dns
	sudoers.d/omarchy-passwd-tries
	sudoers.d/omarchy-theme-browser
	sudoers.d/omarchy-tzupdate
	sysctl.d/90-omarchy-file-watchers.conf
	sysctl.d/99-omarchy-sysctl.conf
	systemd/logind.conf.d/10-ignore-power-button.conf
	systemd/logind.conf.d/20-inhibit-delay.conf
	systemd/oomd.conf.d/10-omarchy.conf
	systemd/resolved.conf.d/10-disable-multicast.conf
	systemd/resolved.conf.d/20-docker-dns.conf
	systemd/system.conf.d/10-faster-shutdown.conf
	systemd/system.conf.d/20-omarchy-nofile.conf
	systemd/system/docker.service.d/no-block-boot.conf
	systemd/system/plocate-updatedb.service.d/ac-only.conf
	systemd/system/user@.service.d/10-faster-shutdown.conf
	systemd/user.conf.d/20-omarchy-nofile.conf
	tmpfiles.d/omarchy-nopasswd-sudo.conf
	xdg/kitty/kitty.conf
)

src_configure() { :; }
src_compile() { :; }

# The three support helpers this package ships in common with upstream are
# patched for portage here too (the patch set lives on the omarchy meta
# package; these two files target the helpers only).
src_prepare() {
	default
	eapply \
		"${FILESDIR}"/omarchy-gentoo-debug.patch \
		"${FILESDIR}"/omarchy-gentoo-upload-log.patch
}

src_install() {
	local om=/usr/share/omarchy

	# config/** — /etc/skel seeds NEW users; the same tree ships at
	# /usr/share/omarchy/config as the source of truth that
	# omarchy-refresh-config / omarchy-reinstall-configs re-sync against.
	insinto /etc/skel/.config
	doins -r config/.
	insinto "${om}/config"
	doins -r config/.

	# Package-owned defaults in real system/XDG locations; user config in
	# ~/.config still overrides all of these.
	insinto /usr/share/uwsm/env.d
	doins default/uwsm/env.d/10-omarchy
	insinto /usr/lib/environment.d
	doins default/environment.d/10-omarchy-fcitx.conf
	insinto /usr/share/fontconfig/conf.avail
	doins default/fontconfig/conf.avail/50-omarchy.conf
	dosym -r /usr/share/fontconfig/conf.avail/50-omarchy.conf /etc/fonts/conf.d/50-omarchy.conf
	insinto /usr/share/xdg-terminal-exec
	doins default/xdg-terminal-exec/hyprland-xdg-terminals.list
	domenu default/applications/mimeapps.list

	# systemd user units. No unit is enabled from pkg_postinst — upstream wires
	# autostart through user config; elog tells the user how.
	systemd_douserunit \
		default/systemd/user/bt-agent.service \
		default/systemd/user/omarchy-sleep-lock.service \
		default/systemd/user/omarchy-recover-internal-monitor.service \
		default/systemd/user/omarchy-migrate-notify.service \
		default/systemd/user/omarchy-tailscale-receive.service \
		default/systemd/user/omarchy-fcitx5.service \
		default/systemd/user/omarchy-crash-watch.service
	# Compatibility alias for pre-rename installs (mirrors upstream).
	dosym omarchy-migrate-notify.service /usr/lib/systemd/user/omarchy-update-user-notify.service
	insinto /usr/lib/systemd/user/app.slice.d
	doins default/systemd/user/app.slice.d/10-oomd.conf
	insinto /usr/lib/systemd/zram-generator.conf.d
	doins default/systemd/zram-generator.conf.d/90-omarchy.conf
	if [[ -f default/systemd/system/plocate-updatedb.service.d/10-omarchy.conf ]]; then
		insinto /usr/lib/systemd/system/plocate-updatedb.service.d
		doins default/systemd/system/plocate-updatedb.service.d/10-omarchy.conf
	fi
	# systemd system-sleep hook (unmounts gvfsd-fuse before suspend).
	exeinto /usr/lib/systemd/system-sleep
	doexe default/systemd/system-sleep/unmount-fuse

	# /etc tree, filtered through OMARCHY_ETC_KEEP.
	local f
	for f in "${OMARCHY_ETC_KEEP[@]}"; do
		insinto "/etc/${f%/*}"
		doins "etc/${f}"
	done
	# sudoers.d: 0440 files in a 0750 directory or sudo refuses them.
	fperms 0750 /etc/sudoers.d
	fperms 0440 /etc/sudoers.d/omarchy-dns /etc/sudoers.d/omarchy-passwd-tries \
		/etc/sudoers.d/omarchy-theme-browser /etc/sudoers.d/omarchy-tzupdate
	# Snapper config template (data; only consumed if the user runs btrfs+snapper).
	insinto /etc/snapper/config-templates
	doins default/snapper/root

	# applications/** as refreshable data, minus the raw icons dir; icons get
	# normalized into the standard freedesktop hicolor paths below.
	insinto "${om}/applications"
	doins -r applications/.
	rm -rf "${ED}${om}/applications/icons"
	if [[ -d applications/icons ]]; then
		local icon icon_id
		dodir /usr/share/icons/hicolor/256x256/apps /usr/share/icons/hicolor/48x48/apps /usr/share/icons/hicolor/scalable/apps
		for icon in applications/icons/*; do
			[[ -f ${icon} ]] || continue
			icon_id=$(printf '%s\n' "${icon##*/}" \
				| tr '[:upper:]' '[:lower:]' \
				| sed 's/[^[:alnum:]]\+/-/g; s/^-//; s/-$//')
			case "${icon}" in
				*.svg)
					insinto /usr/share/icons/hicolor/scalable/apps
					newins "${icon}" "${icon_id}.svg"
					;;
				*)
					magick "${icon}" -thumbnail 256x256 -background transparent -gravity center -extent 256x256 \
						"PNG32:${ED}/usr/share/icons/hicolor/256x256/apps/${icon_id}.png"
					magick "${icon}" -thumbnail 48x48 -background transparent -gravity center -extent 48x48 \
						"PNG32:${ED}/usr/share/icons/hicolor/48x48/apps/${icon_id}.png"
					;;
			esac
		done
	fi

	# default/** ships whole as reference/data (themed templates, bash env,
	# SDDM/Plymouth sources, pacman channel configs read by the Gentoo stubs…).
	insinto "${om}/default"
	doins -r default/.

	# SDDM theme, session file and Hyprland session wrapper.
	insinto /usr/share/sddm/themes
	doins -r default/sddm/omarchy
	fperms -R 0755 /usr/share/sddm/themes/omarchy
	fperms -R 0644 /usr/share/sddm/themes/omarchy
	insinto /usr/share/sddm
	doins default/sddm/hyprland.lua
	# Upstream drops this in /usr/local/share (ISO orchestrator territory);
	# /usr/share/wayland-sessions is the package-owned location on Gentoo.
	insinto /usr/share/wayland-sessions
	doins default/wayland-sessions/omarchy.desktop

	# Plymouth theme as inert data — activates only if sys-boot/plymouth is
	# installed. plymouthd.conf is Arch-specific and intentionally not shipped.
	insinto /usr/share/plymouth/themes/omarchy
	doins -r default/plymouth/.
	fperms -R 0755 /usr/share/plymouth/themes/omarchy
	fperms -R 0644 /usr/share/plymouth/themes/omarchy

	# System fallback font (used by boot/lock screens).
	insinto /usr/share/fonts/omarchy
	doins default/fonts/omarchy/omarchy.ttf

	# Branding assets.
	insinto "${om}"
	doins logo.txt logo.svg icon.txt icon.png
	insinto /usr/share/pixmaps
	newins icon.png omarchy.png
	dosym ../../../pixmaps/omarchy.png /usr/share/icons/hicolor/256x256/apps/omarchy.png

	# Per-user defaults seeded via /etc/skel for NEW users only (existing users
	# re-sync with omarchy-reinstall-configs).
	insinto /etc/skel/.config/omarchy/branding
	newins logo.txt screensaver.txt
	newins icon.txt about.txt
	insinto /etc/skel/.local/state/omarchy/toggles/hypr
	doins default/hypr/toggles/flags.lua
	insinto /etc/skel/.local/share/nautilus-python/extensions
	doins default/nautilus-python/extensions/localsend.py
	doins default/nautilus-python/extensions/transcode.py
	insinto /etc/skel/.local/state/tensaku
	doins default/tensaku/state.toml
	insinto /etc/skel/.local/share/applications
	doins applications/*.desktop
	if [[ -d applications/hidden ]]; then
		doins applications/hidden/*.desktop
	fi

	# Files whose /etc paths are owned by other packages (faillock, nsswitch,
	# cups, plymouth, bash) ship as reference copies; nothing copies them into
	# place behind the user's back. Upstream's os-release override is dropped
	# entirely — a Gentoo box reports Gentoo.
	insinto "${om}/etc-overrides"
	newins default/bashrc dot.bashrc

	# Support binaries that must exist before app-misc/omarchy (ISO/recovery
	# flows upstream; on Gentoo they complement the meta package's set).
	dobin bin/omarchy-upload-log bin/omarchy-debug bin/omarchy-debug-idle
}

pkg_postinst() {
	elog "Omarchy settings ${PV} installed."
	elog "  config source of truth : /usr/share/omarchy/config"
	elog "  new users get it via /etc/skel; existing users re-sync with:"
	elog "    rsync -a --exclude=.bashrc /usr/share/omarchy/config/ ~/.config/"
	elog "  /etc drop-ins landed under CONFIG_PROTECT; merge updates with dispatch-conf."
	elog "  Units shipped but not enabled; wire per user via, e.g.:"
	elog "    systemctl --user enable --now omarchy-crash-watch.service"
	if ! has_version sys-boot/plymouth; then
		elog "  sys-boot/plymouth is not installed; the shipped boot theme stays inert until it is."
	fi
}
