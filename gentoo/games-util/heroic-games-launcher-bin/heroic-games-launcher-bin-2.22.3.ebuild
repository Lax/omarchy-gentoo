# arch-pkgver: 2.22.3
# Ported from pkgbuilds/heroic-games-launcher-bin. The release asset is a
# pacman-format payload carrying usr/ and opt/Heroic.
EAPI=8

DESCRIPTION="An Open source Launcher for Epic, Amazon and GOG Games"
HOMEPAGE="https://heroicgameslauncher.com/"
SRC_URI="https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/download/v${PV}/Heroic-${PV}-linux-x64.pacman -> ${P}.pacman"

S="${WORKDIR}"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	app-shells/which
	x11-libs/gtk+:3
"
BDEPEND="app-arch/libarchive"
RESTRICT="strip mirror"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	bsdtar -xf "${DISTDIR}/${P}.pacman" usr opt || die
}

src_install() {
	cp -a "${S}"/usr "${S}"/opt "${ED}"/ || die
	dosym -r /opt/Heroic/heroic /usr/bin/heroic
}
