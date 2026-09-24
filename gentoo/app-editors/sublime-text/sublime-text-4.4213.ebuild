# arch-pkgver: 4.4213
# Ported from pkgbuilds/sublime-text-4. The Arch name's trailing "-4" is a
# version, not part of a legal Gentoo package name (PMS forbids a name ending
# in -<digits>); the Gentoo package is app-editors/sublime-text and the tsv
# row maps sublime-text-4 -> sublime-text.
EAPI=8

inherit desktop

DESCRIPTION="Sophisticated text editor for code, html and prose - stable build"
HOMEPAGE="https://www.sublimetext.com/download"
SRC_URI="
	amd64? ( https://download.sublimetext.com/sublime_text_build_4213_x64.tar.xz -> ${P}-x64.tar.xz )
	arm64? ( https://download.sublimetext.com/sublime_text_build_4213_arm64.tar.xz -> ${P}-arm64.tar.xz )
"

S="${WORKDIR}/sublime_text"
# Proprietary, unpriced license distributed with the binary.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	media-libs/libpng
	x11-libs/gtk+:3
"
RESTRICT="strip mirror"

src_prepare() {
	default
	# Point the desktop entry at the launcher on PATH and register the
	# window class, the same edits the Arch package makes.
	sed -i -e 's#/opt/sublime_text/sublime_text#/usr/bin/subl#g' \
		-e '\#^StartupNotify=#a StartupWMClass=subl' \
		sublime_text.desktop || die
}

src_install() {
	dodir /opt
	cp --preserve=mode -r . "${ED}"/opt/sublime_text || die
	rm -f "${ED}"/opt/sublime_text/sublime_text.desktop || die
	local res
	for res in 128x128 16x16 256x256 32x32 48x48; do
		dosym -r /opt/sublime_text/Icon/${res}/sublime-text.png \
			/usr/share/icons/hicolor/${res}/apps/sublime-text.png
	done
	domenu sublime_text.desktop
	newbin "${FILESDIR}"/sublime-text-4.sh subl
}
