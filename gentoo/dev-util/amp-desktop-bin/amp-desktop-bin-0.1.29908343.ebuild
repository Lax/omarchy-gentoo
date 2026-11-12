# arch-pkgver: 0.1.29908343
# Ported from pkgbuilds/amp-desktop-bin. Repackages the desktop app's .deb,
# which already carries the .desktop file (with the sign-in callback scheme),
# the icon set, and the apparmor profile (installed as data, like Arch does).
EAPI=8

DESCRIPTION="Amp, the frontier coding agent, as a desktop app"
HOMEPAGE="https://ampcode.com"
SRC_URI="
	amd64? ( https://static.ampcode.com/linux/0.1.29901001/amp-desktop-0.1.29901001-amd64.deb -> ${P}.deb )
	arm64? ( https://static.ampcode.com/linux/0.1.29901001/amp-desktop-0.1.29901001-arm64.deb -> ${P}.deb )
"

S="${WORKDIR}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# What the Electron binary links, libnotify for notifications, and xdg-open
# for sign-in and links.
RDEPEND="
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa
	net-print/cups
	x11-libs/gtk+:3
	x11-libs/libnotify
	x11-misc/xdg-utils
"
BDEPEND="app-arch/libarchive"
RESTRICT="strip mirror"
QA_PREBUILT="/opt/amp/*"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	bsdtar -xf "${DISTDIR}/${P}.deb" data.tar.xz || die
	bsdtar --no-same-owner -xf data.tar.xz || die
}

src_install() {
	# Debian package-policy files are not used on Gentoo.
	rm -rf usr/share/doc || die

	# The deb's install script makes this link, and pacman does not run it.
	# The menu entry Exec already points at /opt/amp directly.
	dosym /opt/amp/amp-desktop /usr/bin/amp-desktop

	# The payload itself: cp before any helper creates ${ED}/usr, or cp would
	# nest usr/ inside it. Carries the menu entry and icon set.
	cp -a opt usr "${ED}"/ || die

	# Licenses ship inside /opt/amp; expose them through the standard path.
	dodir /usr/share/licenses/${PN}
	dosym /opt/amp/LICENSE.electron.txt /usr/share/licenses/${PN}/LICENSE.electron.txt
	dosym /opt/amp/LICENSES.chromium.html /usr/share/licenses/${PN}/LICENSES.chromium.html
}
