# arch-pkgver: 0.6.8
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Ported from pkgbuilds/omadesign-bin. The release tarball is a ready
# release tree - the binary, desktop entry, icon, MIME database, README,
# licences, and the /usr/share/omadesign payload (lib, licenses, docs,
# skills, plugins) - installed as shipped.
EAPI=8

inherit desktop

DESCRIPTION="Native Linux studio for design, layout, painting, photography, and motion"
HOMEPAGE="https://github.com/michaelmonetized/omadesign"
SRC_URI="
	amd64? ( https://github.com/michaelmonetized/omadesign/releases/download/v${PV}/omadesign-${PV}-x86_64-unknown-linux-gnu.tar.gz
		-> ${P}-x86_64-unknown-linux-gnu.tar.gz )
	arm64? ( https://github.com/michaelmonetized/omadesign/releases/download/v${PV}/omadesign-${PV}-aarch64-unknown-linux-gnu.tar.gz
		-> ${P}-aarch64-unknown-linux-gnu.tar.gz )
"

S="${WORKDIR}"

# Gentoo's license tree names the CDDL attribution simply CDDL (the
# upstream recipe spells it CDDL-1.0).
LICENSE="MIT CDDL"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-libs/wayland
	gui-libs/xdg-desktop-portal
	media-libs/fontconfig
	media-libs/libglvnd
	media-libs/vulkan-loader
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libxkbcommon
	x11-libs/libxkbcommon[X]
	x11-themes/hicolor-icon-theme
"

RESTRICT="strip mirror"
QA_PREBUILT="/usr/bin/omadesign /usr/share/omadesign/lib/*"

src_install() {
	local release_dir="${WORKDIR}/omadesign-${PV}-$([[ ${ARCH} == amd64 ]] && echo x86_64 || echo aarch64)-unknown-linux-gnu"

	newbin "${release_dir}"/omadesign omadesign
	domenu "${release_dir}"/omadesign.desktop
	insinto /usr/share/icons/hicolor/scalable/apps
	doins "${release_dir}"/omadesign.svg
	insinto /usr/share/mime/packages
	doins "${release_dir}"/omadesign-mime.xml
	dodoc "${release_dir}"/README.md
	insinto /usr/share/licenses/${PN}
	doins "${release_dir}"/LICENSE "${release_dir}"/LICENSE-Phosphor

	# The payload tree the app resolves next to its share directory.
	local payload
	for payload in lib licenses docs skills plugins; do
		cp -a "${release_dir}/${payload}" "${ED}/usr/share/omadesign/" || die
	done
}

pkg_postinst() {
	elog "Optional GPU rendering needs a Vulkan-capable driver."
	elog "Optional EPS/PostScript-based Illustrator import: app-text/ghostscript-gpl"
}
