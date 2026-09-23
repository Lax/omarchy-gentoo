# arch-pkgver: 1.10.1
# Ported from pkgbuilds/omarchy-emacs.
EAPI=8

DESCRIPTION="Emacs integration for Omarchy with automatic theme and font syncing"
HOMEPAGE="https://github.com/scottjones/omarchy-emacs"
SRC_URI="https://github.com/scottjones/omarchy-emacs/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${P}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Arch splits emacs into emacs-wayland; the equivalent here is the pure-GTK
# build, selected by USE="gtk -X" (this tree's emacs has no pgtk flag).
RDEPEND="
	>=app-editors/emacs-29.4[gtk,-X]
	app-shells/bash
"

src_install() {
	insinto /usr/share/${PN}/config/themes
	doins config/init.el config/omarchy.el config/shell-bashrc
	doins config/themes/omarchy-theme.el

	insinto /usr/share/${PN}
	doins omarchy-colors.el.tpl

	exeinto /usr/share/${PN}/hooks
	doexe hooks/font-set hooks/theme-set

	dobin \
		bin/omarchy-emacs-setup \
		bin/omarchy-emacs-sync-hooks \
		bin/omarchy-restart-emacs \
		bin/omarchy-install-emacs

	dodoc LICENSE
}
