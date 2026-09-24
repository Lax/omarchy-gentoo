# arch-pkgver: 270.4.3312
# Ported from pkgbuilds/dropbox. Arch generates the desktop entry with
# gendesk at build time; a static entry ships in FILESDIR here. The tarball's
# GPG signature is pinned to Dropbox's automatic signing key upstream.
EAPI=8

inherit desktop systemd

DESCRIPTION="A free service that lets you bring your photos, docs, and videos anywhere and share them easily"
HOMEPAGE="https://www.dropbox.com"
SRC_URI="https://edge.dropboxstatic.com/dbx-releng/client/dropbox-lnx.x86_64-${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/dropbox-lnx.x86_64-${PV}"
# Dropbox's terms of service, shipped as terms.txt; the tree-local token
# for a terms-gated binary distribution.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-libs/libxslt
	media-libs/fontconfig
	sys-apps/dbus
	x11-libs/libSM
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXmu
	x11-libs/libXrender
	x11-libs/libXxf86vm
"
RESTRICT="strip mirror"
QA_PREBUILT="/opt/dropbox/*"

src_install() {
	dodir /opt
	cp -dr --no-preserve=ownership . "${ED}"/opt/dropbox || die
	fperms 755 /opt/dropbox/*.so
	dosym -r /opt/dropbox/dropbox /usr/bin/dropbox

	domenu "${FILESDIR}"/dropbox.desktop
	insinto /usr/share/pixmaps
	newins "${FILESDIR}"/DropboxGlyph_Blue.svg dropbox.svg
	insinto /usr/share/licenses/${PF}
	doins "${FILESDIR}"/terms.txt
	# The userspace daemon ships both flavors of unit upstream; none is
	# enabled by the package.
	systemd_dounit "${FILESDIR}"/dropbox.service
	systemd_dounit "${FILESDIR}"/dropbox@.service
}
