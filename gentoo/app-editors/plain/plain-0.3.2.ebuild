# arch-pkgver: 0.3.2
# Ported from pkgbuilds/plain.
EAPI=8

inherit desktop xdg

DESCRIPTION="Omarchy's text editor for config files"
HOMEPAGE="https://github.com/omacom/plain"
SRC_URI="https://github.com/omacom/plain/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${P}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
	dev-qt/qtwayland:6
	sys-apps/xdg-desktop-portal
	x11-themes/hicolor-icon-theme
"
DEPEND="${RDEPEND}"
BDEPEND="dev-build/cmake"

src_compile() {
	# Upstream's bin/build, minus the tests: the CMakeLists enables
	# enable_testing() unconditionally and the plain target is all the
	# package installs, so building just that target avoids dragging in
	# Qt6Test. The CMakeLists ships no install rules; the PKGBUILD installs
	# by hand and so does src_install.
	local build_dir="${S}/build"
	cmake -S "${S}" -B "${build_dir}" -DCMAKE_BUILD_TYPE=Release >/dev/null \
		|| die "cmake configure failed"
	cmake --build "${build_dir}" --target plain -j"$(makeopts_jobs)" \
		|| die "build failed"
}

src_install() {
	dobin build/plain
	insinto /usr/share/icons/hicolor/scalable/apps
	doins pkgbuild/plain.svg
	domenu pkgbuild/plain.desktop
	dodoc README.md
	insinto /usr/share/licenses/${PN}
	doins LICENSE
}

pkg_postinst() {
	xdg_pkg_postinst
}
