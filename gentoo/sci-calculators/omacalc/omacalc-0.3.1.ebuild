# arch-pkgver: 0.3.1
# Ported from pkgbuilds/omacalc.
EAPI=8

inherit desktop xdg

DESCRIPTION="Dead-simple calculator built with Qt Quick"
HOMEPAGE="https://github.com/omacom-io/omacalc"
SRC_URI="https://github.com/omacom-io/omacalc/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${P}"
LICENSE="MIT OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
	sys-apps/xdg-desktop-portal
	x11-themes/hicolor-icon-theme
"
DEPEND="${RDEPEND}"
BDEPEND="dev-qt/qtbase:6"

src_compile() {
	local build_dir="${S}/build"
	mkdir -p "${build_dir}" || die
	pushd "${build_dir}" >/dev/null || die
	qmake6 "${S}/omacalc.pro" || die "qmake6 failed"
	emake
	popd >/dev/null || die
}

src_install() {
	dobin build/omacalc
	insinto /usr/share/icons/hicolor/scalable/apps
	doins pkgbuild/omacalc.svg
	domenu pkgbuild/omacalc.desktop
	insinto /usr/share/licenses/${PN}
	doins LICENSE fonts/OFL.txt
}

pkg_postinst() {
	xdg_pkg_postinst
}
