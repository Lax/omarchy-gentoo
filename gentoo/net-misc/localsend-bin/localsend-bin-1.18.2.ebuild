# arch-pkgver: 1.18.2
# Ported from pkgbuilds/localsend-bin. The .deb is used rather than the
# tarball because it already carries the icons and the desktop entry.
EAPI=8

inherit desktop

DESCRIPTION="An open source cross-platform alternative to AirDrop"
HOMEPAGE="https://github.com/localsend/localsend"
SRC_URI="
	amd64? ( ${HOMEPAGE}/releases/download/v${PV}/LocalSend-${PV}-linux-x86-64.deb -> ${P}.deb )
	arm64? ( ${HOMEPAGE}/releases/download/v${PV}/LocalSend-${PV}-linux-arm-64.deb -> ${P}.deb )
"

S="${WORKDIR}"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-libs/libayatana-appindicator
	dev-libs/libayatana-indicator
	sys-fs/fuse:0
	x11-misc/xdg-user-dirs
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
	# Desktop entry: point at the installed binary/icon name and add the
	# StartupWMClass the Arch package adds, for taskbar pinning.
	sed -i -e 's|^Exec=localsend_app|Exec=localsend|' \
		-e 's|^Exec=/opt/localsend_app/localsend_app|Exec=localsend|' \
		-e 's|^Icon=.+|Icon=localsend|' \
		-e '/^Exec=localsend/a StartupWMClass=org.localsend.localsend_app' \
		usr/share/applications/localsend_app.desktop || die
	domenu usr/share/applications/localsend_app.desktop

	cp -a usr/share/icons "${ED}"/usr/share/ || die
	for res in 128x128 256x256; do
		mv "${ED}/usr/share/icons/hicolor/${res}/apps/localsend_app.png" \
			"${ED}/usr/share/icons/hicolor/${res}/apps/localsend.png" || die
	done
	# The release moved the Flutter app (with its bundled libs) into
	# /opt/localsend_app; keep that layout under /opt/localsend, rename the
	# binary to match the desktop entry and expose it on PATH.
	dodir /opt/localsend /usr/bin
	cp -a opt/localsend_app/. "${ED}"/opt/localsend/ || die
	mv "${ED}"/opt/localsend/localsend_app "${ED}"/opt/localsend/localsend || die
	dosym ../../opt/localsend/localsend /usr/bin/localsend

	insinto /usr/share/licenses/${PF}
	doins "${FILESDIR}"/LICENSE
}
