# arch-pkgver: 3.0.0
# Ported from pkgbuilds/hex-bin. The Hex voice dictation app by Anomaly,
# not a prebuilt of extra/hex (the hex dump tool installs /usr/bin/hx), so
# no provider or blocker relationship exists with it.
EAPI=8

inherit desktop systemd xdg

DESCRIPTION="Hex voice dictation app by Anomaly: hold a key, speak, and it types"
HOMEPAGE="https://github.com/anomalyco/hex"
# The release service names its files by payload digest, not by version;
# the -> renames keep DISTDIR and the manifest keyed to the version.
_x64=5541eb3fdf971813ce72a9ada04f43ea09ebb90f9545fabca648adc9b4e3349c
_arm64=f43a7a3b4c6d432599f830aceaaae957b13b57bc60b6a6655a4d88ddd6a66d4a
SRC_URI="
	amd64? ( https://anoma.ly/release/hex/files/${_x64}/hex -> hex-${PV}-linux-x64 )
	arm64? ( https://anoma.ly/release/hex/files/${_arm64}/hex -> hex-${PV}-linux-arm64 )
"

if [[ ${ARCH} == amd64 ]]; then
	_HEX_BIN="${DISTDIR}/hex-${PV}-linux-x64"
else
	_HEX_BIN="${DISTDIR}/hex-${PV}-linux-arm64"
fi

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Linked: glibc and gcc-libs (dropped), alsa, the vulkan loader; the
# X11/Wayland/xkbcommon client libraries and OpenBLAS load at runtime.
# Upstream's wtype optdepend is gone from the ::gentoo 2026 tree; wl-clipboard
# stays the paste path.
RDEPEND="
	dev-libs/wayland
	media-libs/alsa-lib
	media-libs/vulkan-loader
	net-misc/curl
	sci-libs/openblas
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
"

RESTRICT="strip mirror"
QA_PREBUILT="usr/bin/hex"

src_install() {
	newbin "${_HEX_BIN}" hex
	domenu "${FILESDIR}/hex.desktop"
	systemd_douserunit "${FILESDIR}/hex.service"
	insinto /usr/share/licenses/${PN}
	doins "${FILESDIR}/LICENSE"
}

pkg_postinst() {
	elog "Open Hex from your launcher or run 'hex'; the first run downloads a"
	elog "speech model."
	elog "Start Hex at login: systemctl --user enable hex.service"
	elog
	elog "Optional extras:"
	elog "  gui-apps/wl-clipboard   paste on Wayland"
	elog "  media-video/wireplumber mute output while dictating"
	elog "  x11-misc/xdg-utils      open links from voice commands"
	elog "A Vulkan driver (media-libs/mesa or the vendor driver) enables GPU"
	elog "transcription."
}
