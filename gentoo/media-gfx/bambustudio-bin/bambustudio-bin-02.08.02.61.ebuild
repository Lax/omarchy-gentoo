# arch-pkgver: 02.08.02.61
# Ported from pkgbuilds/bambustudio-bin. The AppImage is unpacked with 7z
# (never executed), the same approach the Arch package takes.
EAPI=8

inherit desktop

DESCRIPTION="PC Software for BambuLab's 3D printers"
HOMEPAGE="https://github.com/bambulab/BambuStudio"
# _build is the timestamp upstream appends to the release asset.
_BUILD=20260820225108
SRC_URI="https://github.com/bambulab/BambuStudio/releases/download/v${PV}/BambuStudio_ubuntu24.04-v${PV}-${_BUILD}.AppImage -> ${P}.AppImage"

S="${WORKDIR}"
LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-libs/glib
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/pango
	media-libs/fontconfig
	media-libs/libglvnd
	media-libs/mesa
	media-libs/gstreamer
	media-libs/gst-plugins-base
	media-plugins/gst-plugins-libav
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	dev-libs/wayland
"
BDEPEND="app-arch/p7zip"
RESTRICT="strip mirror"

src_unpack() {
	mkdir -p "${S}/squashfs-root" || die
	7z x -o"${S}/squashfs-root" "${DISTDIR}/${P}.AppImage" >/dev/null || die
}

src_install() {
	local app=/opt/bambustudio-bin
	dodir "${app}"
	cp -a squashfs-root/bin squashfs-root/resources "${ED}${app}/" || die
	exeinto "${app}"
	doexe squashfs-root/AppRun
	dobin "${FILESDIR}"/bambu-studio
	domenu "${FILESDIR}"/BambuStudio.desktop
}
