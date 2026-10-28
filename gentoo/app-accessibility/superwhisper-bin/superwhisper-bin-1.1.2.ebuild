# arch-pkgver: 1.1.2
# Ported from pkgbuilds/superwhisper-bin. Upstream verifies the payload with
# minisign before extracting and rewrites the bundled quickshell panel's QML
# (Qt 6.12 grew a Color type that shadows Omarchy's palette singleton); both
# steps are kept here — the minisign check keeps vendor authorship bound to
# the payload alongside the Manifest digest, the rewrite ships as
# files/qualify-palette.py.
EAPI=8

inherit desktop systemd

DESCRIPTION="Local and cloud voice dictation with Superwhisper"
HOMEPAGE="https://superwhisper.com"
SRC_URI="
	https://tux.superwhisper.com/x86_64/v${PV}/superwhisper-omarchy-x86_64-${PV}.tar.zst -> ${P}.tar.zst
	https://tux.superwhisper.com/x86_64/v${PV}/superwhisper-omarchy-x86_64-${PV}.tar.zst.minisig -> ${P}.tar.zst.minisig
"

S="${WORKDIR}"
LICENSE="all-rights-reserved MIT"
SLOT="0"
KEYWORDS="~amd64"

# Mirrors the upstream Arch recipe (glibc/libgcc/libstdc++/libgomp are the
# toolchain runtime, dropped per gentoo-deps.map); foot is a hard dependency
# because the settings desktop entry runs the TUI inside it.
RDEPEND="
	app-accessibility/at-spi2-core
	dev-lang/python
	dev-python/pycairo
	dev-python/pygobject
	gnome-base/librsvg
	gui-apps/foot
	gui-apps/wl-clipboard
	gui-libs/gtk
	gui-libs/gtk4-layer-shell
	media-libs/fontconfig
	media-libs/vulkan-loader
	media-video/ffmpeg
	media-video/pipewire[pulseaudio]
	x11-libs/libnotify
	x11-misc/xdg-utils
	x11-themes/hicolor-icon-theme
"
BDEPEND="
	app-arch/zstd
	app-crypt/minisign
"

RESTRICT="strip mirror"
QA_PREBUILT="/opt/superwhisper/*"

src_unpack() {
	minisign -Vm "${DISTDIR}/${P}.tar.zst" \
		-x "${DISTDIR}/${P}.tar.zst.minisig" \
		-p "${FILESDIR}"/linux-release.pub ||
		die "minisign verification failed"
	tar --zstd -xf "${DISTDIR}/${P}.tar.zst" -C "${WORKDIR}" || die
}

src_prepare() {
	default
	local bundle="superwhisper-omarchy-x86_64-${PV}"
	[[ $(< "${bundle}"/VERSION) == "${PV}" ]] || die "payload version mismatch"
	python3 "${FILESDIR}"/qualify-palette.py \
		"${bundle}"/app/assets/omarchy-plugin/superwhisper-panel ||
		die "palette qualification failed"
}

src_install() {
	local bundle="superwhisper-omarchy-x86_64-${PV}"

	dodir /opt/superwhisper
	cp -a "${bundle}/app/." "${ED}/opt/superwhisper/" || die
	# Omarchy owns its Dictation menu; omit the portable installer's menu writer.
	rm -f "${ED}"/opt/superwhisper/scripts/omarchy-menu-rows.py || die

	dobin "${FILESDIR}"/superwhisper
	systemd_douserunit "${FILESDIR}"/superwhisper.service
	domenu "${FILESDIR}"/superwhisper.desktop "${FILESDIR}"/superwhisper-url.desktop
	exeinto /usr/share/superwhisper
	newexe "${FILESDIR}"/setup-user setup-user

	insinto /usr/share/licenses/${PN}
	doins "${bundle}"/licenses/*
	dodoc "${bundle}"/README.md
}

pkg_postinst() {
	elog "Optional runtime features:"
	elog "  app-i18n/fcitx5: insert dictation directly through the input method"
	elog "  vulkan-capable VIDEO_CARDS (intel/amdgpu): local processing"
	elog "Wire the user service and the quickshell dictation panel with:"
	elog "  /usr/share/superwhisper/setup-user"
}
