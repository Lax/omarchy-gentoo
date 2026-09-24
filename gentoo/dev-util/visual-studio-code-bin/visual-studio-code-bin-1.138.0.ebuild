# arch-pkgver: 1.138.0
# Ported from pkgbuilds/visual-studio-code-bin. The launcher is the upstream
# visual-studio-code-bin.sh; flags go in ~/.config/code-flags.conf.
EAPI=8

inherit desktop

DESCRIPTION="Visual Studio Code (vscode): Editor for building and debugging modern web and cloud applications (official binary version)"
HOMEPAGE="https://code.visualstudio.com/"
SRC_URI="
	amd64? ( https://update.code.visualstudio.com/${PV}/linux-deb-x64/stable -> ${P}-amd64.deb )
	arm64? ( https://update.code.visualstudio.com/${PV}/linux-deb-arm64/stable -> ${P}-arm64.deb )
"

S="${WORKDIR}"
# Commercial, free-of-charge redistributable binary.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	app-crypt/gnupg
	dev-libs/libsecret
	dev-libs/nss
	media-libs/alsa-lib
	sys-process/lsof
	x11-libs/gtk+:3
	x11-libs/libXScrnSaver
	x11-libs/libxkbfile
	x11-misc/shared-mime-info
	x11-misc/xdg-utils
	x11-libs/libnotify
"
BDEPEND="app-arch/libarchive"
RESTRICT="strip mirror"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	bsdtar -xf "${DISTDIR}/${P}.deb" data.tar.xz || die
	bsdtar --no-same-owner -xf data.tar.xz || die
}

src_install() {
	# One launcher on PATH owned by this ebuild; the deb's /usr/bin/code
	# symlink is replaced by the flags-aware script.
	rm -f usr/bin/code || die
	newbin "${FILESDIR}"/visual-studio-code.sh code
	sed -i -e 's/^\(Exec=\)[^ ]*/\1code/g' usr/share/applications/*.desktop || die
	domenu usr/share/applications/*.desktop
	cp -a usr/share/code "${ED}"/usr/share/ || die
	# Upstream's extension signature check breaks if the tree is stripped
	# (RESTRICT=strip above) and ships setuid on the sandbox helper, kept as
	# the deb leaves it.
	fperms 4755 usr/share/code/chrome-sandbox
	dosym -r /usr/share/code/resources/app/LICENSE.rtf \
		/usr/share/licenses/${PF}/LICENSE.rtf
}

pkg_postinst() {
	elog "Custom flags go in ~/.config/code-flags.conf, one per line."
}
