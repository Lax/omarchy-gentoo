# arch-pkgver: 2026.09.28
# Ported from pkgbuilds/dropbox-cli. The CLI is generated at build time
# from nautilus-dropbox's dropbox.in template by upstream's
# build_dropbox.py - no network, pure stdlib python - and lands as a
# single script whose runtime dependencies are the ported client
# (net-misc/dropbox) and pygobject.
EAPI=8

DESCRIPTION="Command line interface for Dropbox"
HOMEPAGE="https://www.dropbox.com"
# The dropboxd-fallback.patch ships in the PKGBUILD source array; vendored
# under files/ like every other aux file.
SRC_URI="https://linux.dropbox.com/packages/nautilus-dropbox-${PV}.tar.bz2
	-> ${P}.tar.bz2"

S="${WORKDIR}/nautilus-dropbox-${PV}"
LICENSE="GPL-3.0-or-later"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	dev-python/pygobject
	net-misc/dropbox
"
BDEPEND="
	x11-libs/gdk-pixbuf
"

src_prepare() {
	default
	# Point the CLI at /opt/dropbox/dropboxd when the default
	# ~/.dropbox-dist path does not exist - our client installs to /opt.
	eapply "${FILESDIR}"/dropboxd-fallback.patch
}

src_compile() {
	python3 build_dropbox.py "${PV}" "/usr/share/applications" \
		< dropbox.in > dropbox-cli || die "generating dropbox-cli failed"
}

src_install() {
	dobin dropbox-cli
}

pkg_postinst() {
	elog "Optional runtime features:"
	elog "  x11-libs/gtk+:3 for the Dropbox update GUI"
	elog "  app-crypt/gpgme[python] to verify the client binary signature"
}
