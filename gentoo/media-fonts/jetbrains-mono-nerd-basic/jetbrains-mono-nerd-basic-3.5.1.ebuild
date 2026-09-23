# arch-pkgver: 3.5.1
# Ported from pkgbuilds/ttf-jetbrains-mono-nerd-basic (Arch "basic" subset:
# only the four core faces of JetBrains Mono Nerd Font, not the full family
# upstream's zip carries).
EAPI=8

DESCRIPTION="Basic JetBrains Mono Nerd Font family (Regular/Bold/Italic/BoldItalic)"
HOMEPAGE="https://github.com/ryanoasis/nerd-fonts"
SRC_URI="https://github.com/ryanoasis/nerd-fonts/releases/download/v${PV}/JetBrainsMono.zip -> ${P}.zip"

S="${WORKDIR}"
# The zip's OFL.txt is SIL OFL 1.1; the RFN clause is simply unexercised
# upstream, so the tree's standard token is used.
LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="app-arch/unzip"

src_install() {
	local face
	for face in Regular Bold Italic BoldItalic; do
		insinto /usr/share/fonts/jetbrains-mono-nerd
		doins "JetBrainsMonoNerdFont-${face}.ttf"
	done
	dodoc OFL.txt
}
