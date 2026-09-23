# arch-pkgver: 0.4.25
# Ported from pkgbuilds/lmstudio-bin. The AppImage is installed as-is; it
# self-extracts on first run (fuse2 at runtime or --appimage-extract-and-run).
EAPI=8

inherit desktop xdg

DESCRIPTION="Desktop app for exploring and running large language models locally"
HOMEPAGE="https://lmstudio.ai"
_BUILD=1
SRC_URI="https://installers.lmstudio.ai/linux/x64/${PV}-${_BUILD}/LM-Studio-${PV}-${_BUILD}-x64.AppImage -> ${P}.AppImage"

S="${WORKDIR}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-libs/nss
	sys-fs/fuse:0
	x11-libs/gtk+:3
	x11-themes/hicolor-icon-theme
"
RESTRICT="strip mirror"

src_install() {
	exeinto /opt/lm-studio
	newexe "${DISTDIR}/${P}.AppImage" lm-studio.AppImage

	doicon "${FILESDIR}/lmstudio.png"
	domenu "${FILESDIR}/lmstudio.desktop"

	dosym -r /opt/lm-studio/lm-studio.AppImage /usr/bin/lm-studio
}
