# arch-pkgver: 0.96.0
# Ported from pkgbuilds/crush-bin.
EAPI=8

inherit shell-completion

DESCRIPTION="A powerful terminal-based AI assistant for developers"
HOMEPAGE="https://charm.sh/crush https://github.com/charmbracelet/crush"
SRC_URI="
	amd64? ( https://github.com/charmbracelet/crush/releases/download/v${PV}/crush_${PV}_Linux_x86_64.tar.gz -> ${P}-x86_64.tar.gz )
	arm64? ( https://github.com/charmbracelet/crush/releases/download/v${PV}/crush_${PV}_Linux_arm64.tar.gz -> ${P}-aarch64.tar.gz )
"

S="${WORKDIR}"
LICENSE="FSL-1.1-MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="strip mirror"
QA_PREBUILT="/usr/bin/crush"

src_unpack() {
	default
	# GoReleaser ships a versioned directory per arch.
	mv crush_${PV}_Linux_* "${P}" || die
}

src_install() {
	dobin "${P}"/crush
	insinto /usr/share/licenses/${PF}
	doins "${P}"/LICENSE*
	newbashcomp "${P}"/completions/crush.bash crush
	dofishcomp "${P}"/completions/crush.fish
	dozshcomp "${P}"/completions/crush.zsh
	doman "${P}"/manpages/crush.1.gz
	dodoc "${P}"/README*
}
