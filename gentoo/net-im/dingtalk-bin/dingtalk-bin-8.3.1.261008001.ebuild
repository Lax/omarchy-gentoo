# arch-pkgver: 8.3.1.261008001
# Ported from pkgbuilds/dingtalk-bin. The vendor tree bundles a GCC-8-era
# libstdc++ plus old libm/libgbm/GL dispatch and its own libcurl linked
# against OpenLDAP 2.4 and librtmp, which no Gentoo package provides; the
# deb's copies are removed so the system libraries win (_unbundle below is
# the PKGBUILD's list, verbatim). The bundled Qt has no Wayland platform
# plugin, so the launcher pins it to XWayland.
#
# amd64 only: icotool (the .ico renderer) carries no ~arm64 keyword, and the
# icon is part of the package() contract, not an optional extra.
EAPI=8

inherit desktop

DESCRIPTION="DingTalk (钉钉), the official Linux client"
HOMEPAGE="https://www.dingtalk.com/"
_appid=com.alibabainc.dingtalk
_debbase="https://dtapp-pub.dingtalk.com/dingtalk-desktop/xc_dingtalk_update/linux_deb/Release"
SRC_URI="
	amd64? ( ${_debbase}/${_appid}_${PV}_amd64.deb -> ${P}.deb )
	arm64? ( ${_debbase}/${_appid}_${PV}_arm64.deb -> ${P}.deb )
"

S="${WORKDIR}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	media-libs/alsa-lib
	app-accessibility/at-spi2-core
	x11-libs/cairo
	net-misc/curl
	media-libs/fontconfig
	media-libs/freetype
	x11-libs/gdk-pixbuf
	dev-libs/glib
	virtual/glu
	net-libs/gnutls
	x11-libs/gtk+:3
	media-libs/harfbuzz
	x11-libs/libdrm
	media-libs/libglvnd
	x11-libs/libICE
	media-libs/libpulse
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	sys-libs/libxcrypt[compat]
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libxkbcommon[X]
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	media-libs/mesa
	dev-libs/nspr
	dev-libs/nss
	x11-libs/pango
	sys-apps/util-linux
	x11-libs/xcb-util-image
	x11-libs/xcb-util-keysyms
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
"
# icotool renders the vendor .ico into an installable PNG; patchelf clears
# the executable-stack bit glibc 2.41 refuses to dlopen.
BDEPEND="
	app-arch/libarchive
	dev-util/patchelf
	media-gfx/icoutils
"
RESTRICT="strip mirror"
QA_PREBUILT="/opt/dingtalk/*"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	bsdtar -O -xf "${DISTDIR}/${P}.deb" 'data.tar.*' |
		bsdtar --no-same-owner -xf - || die
}

src_install() {
	local files="opt/apps/${_appid}/files"
	local release="${files}/$(<"${files}/version")"
	local dest="${ED}"/opt/dingtalk

	install -d "${dest}" || die
	# The payload itself: cp before any helper creates ${ED}/opt, or cp
	# would nest opt/ inside it.
	cp -a --no-preserve=ownership "${release}" "${dest}/release" || die
	insinto /opt/dingtalk
	doins "${files}/version"

	# Bundled copies the vendor's own postinst deletes on a current glibc
	# distro: left in place they shadow the system libraries and break
	# Mesa and GTK.
	local unbundle=(
		'libstdc++.so.6*'
		'libm.so.6'
		'libm-2.31.so'
		'libgbm.so*'
		'libGLX.so*'
		'libGLdispatch.so*'
		'libharfbuzz.so*'
		'libcurl.so.4'
		'libssh2.so.1'
		'libnghttp2.so.14'
	)
	local lib
	for lib in "${unbundle[@]}"; do
		rm -f "${dest}/release/"${lib} || die
	done

	# glibc 2.41 refuses to dlopen a library that asks for an executable
	# stack.
	local file
	while IFS= read -r -d '' file; do
		if readelf -lW "${file}" 2>/dev/null | grep -q 'GNU_STACK.*RWE'; then
			patchelf --clear-execstack "${file}" || die
		fi
	done < <(find "${dest}/release" -type f -name '*.so*' -print0)

	# The vendor postinst makes chrome-sandbox setuid root, but DingTalk
	# starts its CEF processes with --no-sandbox, so the helper never runs.
	chmod 755 "${dest}/release/plugins/dtwebview/chrome-sandbox" || die

	local odd
	odd=$(find "${dest}" \( -perm /6000 -o \( ! -type l -perm /022 \) \) -printf '%M %P\n')
	[[ -z ${odd} ]] || die "Unexpected setuid, setgid or writable paths in the vendor tree: ${odd}"

	newbin "${FILESDIR}"/dingtalk.sh dingtalk
	newmenu "${FILESDIR}"/dingtalk.desktop ${_appid}.desktop

	icotool -x -w 256 -o "${T}"/dingtalk.png "${files}/logo.ico" || die
	insinto /usr/share/icons/hicolor/256x256/apps
	doins "${T}"/dingtalk.png

	insinto /usr/share/licenses/${PN}
	doins "${FILESDIR}"/LICENSE
}

pkg_postinst() {
	elog "Chinese input through the bundled fcitx5 Qt plugin needs"
	elog "app-i18n/fcitx-chinese-addons (upstream's optdepends)."
}
