# arch-pkgver: 0.4.1
# Ported from pkgbuilds/rawmakase-bin. The release tarball is a ready usr/
# tree: a $ORIGIN-relative launcher in /usr/bin, the binary with bundled
# LibRaw/lcms2/libjpeg/ONNX Runtime in /usr/lib/rawmakase, plus the desktop
# entry, icon and licences — installed as shipped, licence directory renamed
# to the binary package name like upstream does.
EAPI=8

DESCRIPTION="Fast, Lightroom-compatible RAW photo editor (binary release)"
HOMEPAGE="https://github.com/pch/rawmakase"
SRC_URI="https://github.com/pch/rawmakase/releases/download/v${PV}/rawmakase-${PV}-x86_64-linux.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# Windowing, input and GPU libraries are dlopen'd, while LibRaw, lcms2,
# libjpeg and ONNX Runtime come bundled under /usr/lib/rawmakase; this list
# mirrors the upstream Arch recipe rather than the ELF NEEDED entries.
RDEPEND="
	dev-libs/wayland
	media-libs/libglvnd
	media-libs/vulkan-loader
	sys-apps/dbus
	sys-libs/zlib
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libxkbcommon
	x11-libs/libxkbcommon[X]
	x11-libs/libXrandr
	x11-themes/hicolor-icon-theme
"

RESTRICT="strip mirror"
QA_PREBUILT="usr/lib/rawmakase/*"

src_install() {
	cp -a usr/. "${ED}/" || die
	# Upstream renames the vendored licence directory to the binary package
	# name; ${PF} is the portage spelling of the same idea.
	mv "${ED}/usr/share/licenses/rawmakase" "${ED}/usr/share/licenses/${PF}" || die
}
