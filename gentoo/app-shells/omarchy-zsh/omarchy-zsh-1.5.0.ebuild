# arch-pkgver: 1.5.0
# Ported from pkgbuilds/omarchy-zsh. Second source is the omadots shared
# shell-config repo, pinned to the commit the floating Arch "master" tarball
# pointed at when this ebuild was written (Arch pins no checksum for it; a
# Gentoo Manifest must, so the pin lives here).
EAPI=8

inherit shell-completion

DESCRIPTION="Omarchy shell configuration for Zsh"
HOMEPAGE="https://github.com/omacom-io/omarchy-zsh"
SRC_URI="
	https://github.com/omacom-io/omarchy-zsh/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/omacom-io/omadots/archive/556354683664f4143776296d76df75c0fa29059a.tar.gz -> omadots-5563546.tar.gz
"

S="${WORKDIR}/${P}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	app-shells/zsh
	app-shells/zsh-syntax-highlighting
	app-shells/fzf
	app-shells/starship
	app-shells/zoxide
	sys-apps/bat
	sys-apps/eza
	sys-apps/fd
"

src_install() {
	# Shared shell config from omadots (aliases, functions, envs, inits,
	# inputrc), rewritten to source from the installed package location.
	insinto /usr/share/${PN}/shell
	doins -r "${WORKDIR}/omadots-556354683664f4143776296d76df75c0fa29059a/config/shell/."
	find "${ED}/usr/share/${PN}/shell" -type f -exec \
		sed -i \
		-e 's|"\$HOME"/\.config/shell|/usr/share/omarchy-zsh/shell|g' \
		-e 's|\$HOME/\.config/shell|/usr/share/omarchy-zsh/shell|g' \
		{} + || die

	doins "${S}/shell/zoptions"

	# Completions autoload via the default fpath; compinit is invoked from
	# zoptions.
	local comp
	for comp in "${S}"/shell/completions/*; do
		newzshcomp "${comp}" "$(basename "${comp}")"
	done

	insinto /usr/share/${PN}
	doins -r templates LICENSE README.md

	dobin "${S}/bin/omarchy-setup-zsh"
}

pkg_postinst() {
	elog "omarchy-zsh installed. Run 'zsh' to try it, or"
	elog "'omarchy-setup-zsh' to make it the default shell."
	elog "Re-run 'omarchy-setup-zsh' after upgrades for changes to take effect."
	elog "The config expects dev-util/mise (not packaged in this tree; it is"
	elog "available in the GURU overlay)."
}
