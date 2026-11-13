# arch-pkgver: 26.10.3
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Ported from pkgbuilds/yaru-icon-theme. The upstream recipe builds the
# ubuntu/yaru monorepo once and splits it into nine Arch packages; this
# overlay ships the icon-theme split, which is what Omarchy themes
# reference through their icons.theme file.
#
# The icon split cannot be configured alone: icons/meson.build colorizes
# accented SVGs from gtk_yaru_colors_defs, a table only the gtk component
# builds (its SASS machinery runs at configure time), so gtk stays on
# beside icons - upstream's supported configuration builds everything and
# prunes per split; we prune harder at src_install. That machinery needs
# dev-lang/sassc, which ::gentoo carries. (An earlier revision configured
# -Dicons-only on the belief that dev-util/sassc had been dropped - the
# note named the wrong category, and the unsupported configure died in
# meson setup before the nightly rotation ever reached it.)
EAPI=8

inherit meson xdg

DESCRIPTION="Yaru default ubuntu icon theme (the icon sets Omarchy themes reference)"
HOMEPAGE="https://github.com/ubuntu/yaru"
SRC_URI="https://github.com/ubuntu/yaru/archive/${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/yaru-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	gnome-base/librsvg
	x11-themes/hicolor-icon-theme
"

BDEPEND="dev-lang/sassc"

src_configure() {
	local emesonargs=(
		-Dicons=true
		-Dgtk=true
		-Dgtksourceview=false
		-Dgnome-shell=false
		-Dmetacity=false
		-Dsounds=false
		-Dsessions=false
	)
	meson_src_configure
}

src_install() {
	meson_src_install
	# The icon-theme split: prune every other install path the monorepo
	# wrote, should a meson option ever stop covering one.
	find "${ED}/usr/share" -mindepth 1 -maxdepth 1 ! -name icons -exec rm -rf {} + || die
}
