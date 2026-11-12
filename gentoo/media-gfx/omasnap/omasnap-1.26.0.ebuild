# arch-pkgver: 1.26.0
# Ported from pkgbuilds/omasnap. Native Wayland screenshot and annotation
# overlay for Hyprland: Qt6 widgets over a layer-shell surface, the
# ext-image-copy-capture protocol family, a libdeflate-backed PNG fast path
# and tesseract text extraction. Omarchy 4.5.0 replaces satty/tensaku with
# it (migration 1788129995, base.packages line 107; omarchy-capture-
# screenshot execs omasnap directly).
EAPI=8

inherit cmake

DESCRIPTION="Native Wayland screenshot and annotation overlay for Hyprland"
HOMEPAGE="https://github.com/omacom/omasnap"
SRC_URI="https://github.com/omacom/omasnap/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${PV}"

LICENSE="MIT OFL-1.1 ISC"
SLOT="0"
KEYWORDS="~amd64"

# Translation of the upstream depends array: hyprland layer-shell-qt
# qt6-base tesseract tesseract-data-eng wayland wl-clipboard. LayerShellQt
# is kde-plasma/ on Gentoo and libdeflate is app-arch/. tesseract-data-eng
# has no ::gentoo package at all (the tree ships no traineddata), so the
# English OCR model is not pulled automatically; without it omasnap's text
# extraction starts with no language.
RDEPEND="
	app-arch/libdeflate
	app-text/tesseract
	>=dev-qt/qtbase-6.8:6[concurrent,gui,widgets]
	gui-apps/wl-clipboard
	gui-wm/hyprland
	kde-plasma/layer-shell-qt
"
BDEPEND="
	dev-libs/wayland
	dev-libs/wayland-protocols
	virtual/pkgconfig
"

PATCHES=(
	# Version-qualified patch names do not travel with an ebuild rename:
	# the automation renames the file, the patch stays behind, and the
	# build dies on a missing file (omasnap 1.26.0, 2026-11). Keep the
	# name unqualified; a source that outgrows the patch fails loudly at
	# prepare with a mismatch instead.
	"${FILESDIR}"/${PN}-optional-qttest.patch
)

src_configure() {
	# The smoke suite drives real surface capture against an offscreen
	# platform; it is upstream CI tooling and needs the Qt6Test module,
	# which Gentoo only builds under dev-qt/qtbase's test USE. The patch
	# makes it conditional; turn the phase off here.
	local mycmakeargs=( -DBUILD_TESTING=OFF )
	cmake_src_configure
}

src_install() {
	cmake_src_install
	einstalldocs
}
