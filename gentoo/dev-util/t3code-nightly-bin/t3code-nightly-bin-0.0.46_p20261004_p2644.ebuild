# arch-pkgver: 0.0.46_nightly.20261004.2644
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Ported from pkgbuilds/t3code-nightly-bin; twin of dev-util/t3code-bin on
# the nightly channel, installed alongside it under separate names. The
# AppImage is unpacked at build time (never executed); only the Electron
# tree, its icons and upstream's desktop entry are kept.
EAPI=8

inherit desktop

DESCRIPTION="Open-source control plane for coding agents (nightly)"
HOMEPAGE="https://t3.codes"
# The release tag spells the version "N.N.N-nightly.DATE.SERIAL"; PV's PMS
# fold ("_pDATE_pSERIAL") is reversed here with parameter expansion only, so
# the automation's renames keep the SRC_URI in lockstep instead of
# hand-carrying a version every nightly would silently strand.
_upstream_version="${PV%%_p*}-nightly.${PV#*_p}"
_upstream_version="${_upstream_version/_p/.}"
SRC_URI="
	amd64? ( https://github.com/pingdotgg/t3code/releases/download/v${_upstream_version}/T3-Code-${_upstream_version}-x86_64.AppImage
		-> ${P}-x86_64.AppImage )
	arm64? ( https://github.com/pingdotgg/t3code/releases/download/v${_upstream_version}/T3-Code-${_upstream_version}-arm64.AppImage
		-> ${P}-arm64.AppImage )
"

S="${WORKDIR}/squashfs-root"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	media-libs/alsa-lib
	app-accessibility/at-spi2-core
	x11-libs/cairo
	sys-apps/dbus
	dev-libs/expat
	dev-libs/glib
	x11-libs/gtk+:3
	x11-themes/hicolor-icon-theme
	net-print/cups
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	media-libs/mesa
	dev-libs/nspr
	dev-libs/nss
	x11-libs/pango
	sys-apps/systemd
	x11-misc/xdg-utils
"
BDEPEND="app-arch/p7zip"
RESTRICT="strip mirror"
QA_PREBUILT="usr/lib/t3code-nightly/.*"

src_unpack() {
	local appimage=${P}-$([[ ${ARCH} == amd64 ]] && echo x86_64 || echo arm64).AppImage
	# Extract without executing the runtime: AppImage's ELF magic does not
	# match QEMU's binfmt registration when building ARM packages on an
	# x86_64 host.
	mkdir -p "${S}" || die
	7z x "${DISTDIR}/${appimage}" -o"${S}" >/dev/null || die
}

src_install() {
	# The AppImage's usr/ tree is compatibility libraries for distributions
	# that lack them, and Gentoo is not one; its icons are the only part
	# worth keeping. A release that starts shipping something else there
	# stops the build rather than having it deleted quietly on the way past.
	local unexpected
	unexpected=$(find usr \( -type f -o -type l \) | grep -vE \
		'^usr/share/icons/hicolor/[0-9]+x[0-9]+/apps/t3code\.png$|^usr/lib/lib(Xss\.so\.1|Xtst\.so\.6|appindicator\.so\.1|gconf-2\.so\.4|indicator\.so\.7|notify\.so\.4)$' || true)
	[[ -z "${unexpected}" ]] || die "Unexpected files in the AppImage's usr/ tree: ${unexpected}"

	local icon size
	for icon in usr/share/icons/hicolor/*/apps/t3code.png; do
		size="${icon#usr/share/icons/hicolor/}"
		size="${size%%/*}"
		insinto "/usr/share/icons/hicolor/${size}/apps"
		newins "${icon}" t3code-nightly.png
	done

	# Upstream's own entry rather than a hand-written one: it carries the
	# t3code:// scheme handlers that make the app's deep links resolve.
	# Separate desktop and icon names allow installation alongside stable.
	# Application state and URL schemes retain upstream's shared-channel
	# behavior.
	sed -e 's|^Exec=.*|Exec=t3code-nightly %U|' -e 's|^Name=.*|Name=T3 Code (Nightly)|' \
		-e 's|^Icon=.*|Icon=t3code-nightly|' -e '/^X-AppImage-Version=/d' t3code.desktop \
		> "${T}"/t3code-nightly.desktop || die
	domenu "${T}"/t3code-nightly.desktop

	# Only the Electron tree itself: AppRun, the icon shims and the compat
	# usr/ tree are dead weight here.
	rm -rf AppRun .DirIcon usr t3code.desktop t3code.png || die
	dodir /usr/lib/t3code-nightly
	cp -a . "${ED}"/usr/lib/t3code-nightly/ || die
	chmod -R a+rX "${ED}"/usr/lib/t3code-nightly || die

	# Chromium's and Electron's own sandbox helper ships setuid, which keeps
	# the sandbox up on a kernel that denies unprivileged user namespaces --
	# linux-hardened, mainly -- instead of aborting the app.
	fperms 4755 /usr/lib/t3code-nightly/chrome-sandbox

	newbin "${FILESDIR}"/t3code-launcher.sh t3code-nightly
	# The server CLI, run through the bundled Electron as Node. Same
	# entrypoint npm's `t3` package runs, so `t3 serve`, `t3 pair`, and the
	# rest work without a separate install.
	newbin "${FILESDIR}"/t3-launcher.sh t3-nightly

	insinto /usr/share/licenses/${PN}
	doins "${FILESDIR}"/LICENSE
}

pkg_postinst() {
	elog "Nightly channel: upstream rotates a release most days and this"
	elog "package tracks it; stable is dev-util/t3code-bin."
	elog "Optional agent CLIs the app can drive: app-misc/claude-code,"
	elog "dev-util/openai-codex-bin, plus cursor-cli and github-copilot-cli"
	elog "(no Gentoo provider)."
}
