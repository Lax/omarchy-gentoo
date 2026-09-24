# arch-pkgver: 1.14.9
# Ported from pkgbuilds/typora.
EAPI=8

inherit desktop

DESCRIPTION="A minimal markdown editor and reader"
HOMEPAGE="https://typora.io/"
SRC_URI="
	amd64? ( https://download.typora.io/linux/typora_${PV}_amd64.deb -> ${P}.deb )
	arm64? ( https://download.typora.io/linux/typora_${PV}_arm64.deb -> ${P}.deb )
"

S="${WORKDIR}"
# Copyright (c) 2015 Abner Lee All Rights Reserved.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	media-libs/alsa-lib
	dev-libs/nss
	x11-libs/gtk+:3
"
BDEPEND="app-arch/libarchive"
RESTRICT="strip mirror"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	bsdtar -xf "${DISTDIR}/${P}.deb" data.tar.zst || die
	bsdtar --no-same-owner -xf data.tar.zst || die
}

src_install() {
	rm -rf usr/share/lintian || die
	# Replace the deb's bin link with the launcher script, which sets the
	# runtime dir relative to the script like Arch's does.
	rm -f usr/bin/typora || die
	newbin "${FILESDIR}"/typora.sh typora

	# Debian doc layout is not used on Gentoo; the copyright moves to the
	# licenses directory.
	mv usr/share/doc/typora/copyright usr/share/licenses_typora_copyright || die
	rm -rf usr/share/doc || die
	insinto /usr/share/licenses/${PF}
	newins "${S}"/usr/share/licenses_typora_copyright LICENSE
	sed -i '/Change Log/d' usr/share/applications/typora.desktop || die
	domenu usr/share/applications/typora.desktop
	cp -a usr/share/typora "${ED}"/usr/share/ || die
}
