# arch-pkgver: 26.10.3
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Ported from pkgbuilds/yaru-icon-theme. The upstream recipe builds the
# ubuntu/yaru monorepo once and splits it into nine Arch packages; this
# overlay ships the icon-theme split, which is what Omarchy themes
# reference through their icons.theme file.
#
# The icon split is configured directly (-Dicons, everything else off)
# rather than upstream's build-everything-then-delete: the other splits'
# SASS machinery needs dev-util/sassc, which the ::gentoo 2026 tree no
# longer carries. The prune below stays as the belt to meson's braces.
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

src_configure() {
	local emesonargs=(
		-Dicons=true
		-Dgtk=false
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
