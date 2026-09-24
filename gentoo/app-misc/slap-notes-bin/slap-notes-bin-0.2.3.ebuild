# arch-pkgver: 0.2.3
# Ported from pkgbuilds/slap-notes-bin. Slap Notes publishes a plain Electron
# tree rather than an AppImage, so this repackages the vendor tarball as-is.
EAPI=8

inherit desktop

DESCRIPTION="Local-first block notes with a wiki-link graph and a built-in AI research agent"
HOMEPAGE="https://slapnotes.com"
SRC_URI="https://github.com/Onefailatatime/slap-notes/releases/download/${PV}/slap-notes-${PV}-linux-x64.tar.zst -> ${P}.tar.zst"

S="${WORKDIR}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-accessibility/at-spi2-core
	dev-libs/expat
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/libdrm
	media-libs/libnotify
	media-libs/libsecret
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-apps/systemd
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/pango
	x11-misc/xdg-utils
	x11-themes/hicolor-icon-theme
"
RESTRICT="strip mirror"
QA_PREBUILT="/opt/slap-notes/*"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	bsdtar --no-same-owner -xf "${DISTDIR}/${P}.tar.zst" || die
}

src_install() {
	dodir /opt/slap-notes
	cp -a slap-notes-${PV}/app/. "${ED}"/opt/slap-notes/ || die
	fperms -R a+rX /opt/slap-notes
	dobin "${FILESDIR}"/slap-notes-launcher.sh
	sed -e 's|^Exec=.*|Exec=slap-notes %U|' \
		slap-notes-${PV}/slap-notes.desktop > "${T}"/slap-notes.desktop || die
	domenu "${T}"/slap-notes.desktop
	local size
	for size in 16 32 48 64 128 256 512 1024; do
		insinto /usr/share/icons/hicolor/${size}x${size}/apps
		doins slap-notes-${PV}/icons/${size}.png
	done
}

pkg_postinst() {
	elog "Extra Chromium flags go in ~/.config/slap-notes-flags.conf, one per line."
}
