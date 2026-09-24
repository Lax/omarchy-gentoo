# arch-pkgver: 2.1.3
# Ported from pkgbuilds/minecraft-launcher. Upstream sets epoch=1 to outrank a
# historical 9.x version; Gentoo drops epochs, so the version is just ${PV}.
# The launcher tarball carries no version in its URL — the checksum is the pin.
EAPI=8

inherit desktop

DESCRIPTION="Official Minecraft Launcher"
HOMEPAGE="https://mojang.com/"
SRC_URI="
	https://launcher.mojang.com/download/Minecraft.tar.gz -> ${P}.tar.gz
	https://launcher.mojang.com/download/minecraft-launcher.svg -> ${PN}.svg
"

S="${WORKDIR}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-libs/libgpg-error
	sys-libs/zlib
	x11-libs/gtk+:3
"
RESTRICT="strip mirror"
QA_PREBUILT="usr/bin/minecraft-launcher usr/lib/minecraft-launcher/*"

src_install() {
	dobin "${FILESDIR}"/minecraft-launcher.sh
	dobin minecraft-launcher/minecraft-launcher
	domenu "${FILESDIR}"/minecraft-launcher.desktop
	insinto /usr/share/icons/hicolor/symbolic/apps
	newins "${DISTDIR}"/${PN}.svg minecraft-launcher.svg
}
