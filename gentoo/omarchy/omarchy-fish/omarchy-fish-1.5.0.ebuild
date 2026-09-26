# arch-pkgver: 1.5.0
# Ported from pkgbuilds/omarchy-fish. Second source is the fzf.fish plugin,
# vendored into the fish vendor directories exactly like the Arch package.
EAPI=8

inherit shell-completion

DESCRIPTION="Fish shell configuration for Omarchy (configuration layer)"
HOMEPAGE="https://github.com/omacom-io/omarchy-fish"
SRC_URI="
	https://github.com/omacom-io/omarchy-fish/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/PatrickF1/fzf.fish/archive/refs/tags/v10.3.tar.gz -> fzf.fish-10.3.tar.gz
"

S="${WORKDIR}/${P}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	app-shells/fish
	app-shells/fzf
	app-shells/starship
	app-shells/zoxide
	sys-apps/bat
	sys-apps/eza
	sys-apps/fd
"

src_install() {
	local fzf_fish="${WORKDIR}/fzf.fish-10.3"

	insinto /usr/share/fish/vendor_conf.d
	doins "${fzf_fish}"/conf.d/*.fish
	insinto /usr/share/fish/vendor_functions.d
	doins "${fzf_fish}"/functions/*.fish
	local fcomp
	for fcomp in "${fzf_fish}"/completions/*.fish; do
		newfishcomp "${fcomp}" "$(basename "${fcomp}")"
	done

	# omarchy-fish conf.d, functions and completions. shopt -s dotglob
	# equivalent: leading-dot function names like ....fish must install too.
	shopt -s dotglob
	insinto /usr/share/fish/vendor_conf.d
	doins "${S}"/conf.d/*.fish
	insinto /usr/share/fish/vendor_functions.d
	doins "${S}"/functions/*.fish
	shopt -u dotglob
	local comp
	for comp in "${S}"/completions/*.fish; do
		newfishcomp "${comp}" "$(basename "${comp}")"
	done

	insinto /usr/share/${PN}
	doins -r templates LICENSE README.md
	newins "${fzf_fish}/LICENSE.md" LICENSE.fzf.fish
	newins "${fzf_fish}/README.md" README.fzf.fish.md

	dobin "${S}/bin/omarchy-setup-fish"
}

pkg_postinst() {
	elog "omarchy-fish installed. Run 'fish' to try it, or"
	elog "'omarchy-setup-fish' to make it the default shell."
	elog "The config expects dev-util/mise (not packaged in this tree; it is"
	elog "available in the GURU overlay)."
}
