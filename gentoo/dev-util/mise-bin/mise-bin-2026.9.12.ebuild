# arch-pkgver: 2026.9.12
# Ported from pkgbuilds/mise-bin.
EAPI=8

DESCRIPTION="Dev tools, env vars, task runner"
HOMEPAGE="https://github.com/jdx/mise"
SRC_URI="
	amd64? ( https://github.com/jdx/mise/releases/download/v${PV}/mise-v${PV}-linux-x64.tar.xz -> ${P}-x64.tar.xz )
	arm64? ( https://github.com/jdx/mise/releases/download/v${PV}/mise-v${PV}-linux-arm64.tar.xz -> ${P}-arm64.tar.xz )
"

S="${WORKDIR}/mise"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="strip mirror"
QA_PREBUILT="/usr/bin/mise"

src_install() {
	dobin bin/mise
	# Managed by the package manager; keep the self-updater off like Arch does.
	keepdir /usr/lib/mise
	touch "${ED}"/usr/lib/mise/.disable-self-update || die
	doman man/man1/mise.1
	insinto /usr/share/fish/vendor_conf.d
	doins share/fish/vendor_conf.d/mise-activate.fish
	insinto /usr/share/licenses/${PF}
	doins LICENSE
	dodoc README.md
}

pkg_postinst() {
	elog "The pre-built tarball ships no bash/zsh completion; run"
	elog "  mise completion bash > ~/.bash_completion.d/mise"
	elog "or install app-shells/bash-completion and use 'mise exec' hooks."
}
