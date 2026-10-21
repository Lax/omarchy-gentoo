# arch-pkgver: 4.1.13.26
# Ported from pkgbuilds/wechat-bin. Tencent publishes only the newest build,
# at a URL that never names a version, so the Manifest digest is the pin:
# once Tencent moves, an old PV stops fetching - which is the point.
EAPI=8

inherit desktop

DESCRIPTION="WeChat (微信) for Linux, the official client from Tencent"
HOMEPAGE="https://linux.weixin.qq.com/"
# Both architectures rename to the same DISTDIR name; only the enabled one
# is ever fetched, so they cannot collide.
SRC_URI="
	amd64? ( https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.deb -> ${P}.deb )
	arm64? ( https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_arm64.deb -> ${P}.deb )
"

S="${WORKDIR}"
# Upstream ships no license text beyond the bundled one; terms at
# https://weixin.qq.com/
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	media-libs/alsa-lib
	app-accessibility/at-spi2-core
	x11-libs/cairo
	sys-apps/dbus
	dev-libs/expat
	media-libs/fontconfig
	dev-libs/glib
	x11-themes/hicolor-icon-theme
	net-print/cups
	media-libs/libglvnd
	x11-libs/libICE
	media-libs/libpulse
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	media-libs/mesa
	media-fonts/noto-cjk
	dev-libs/nspr
	dev-libs/nss
	x11-libs/pango
	sys-apps/systemd
	x11-libs/xcb-util-keysyms
	sys-libs/zlib
"
BDEPEND="app-arch/libarchive"
RESTRICT="strip mirror"
QA_PREBUILT="/opt/wechat/*"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	# The deb's data member is not always the same compression; take it
	# through the wildcard the way the PKGBUILD does.
	bsdtar -O -xf "${DISTDIR}/${P}.deb" 'data.tar.*' |
		bsdtar --no-same-owner -xf - || die
}

src_install() {
	# The payload itself: cp before any helper creates ${ED}/opt, or cp
	# would nest opt/ inside it.
	install -d "${ED}"/opt || die
	cp -a --no-preserve=ownership opt/wechat "${ED}"/opt/ || die
	# Nothing in WeChat needs privilege; a future build that asks for it
	# gets none.
	chmod -R go-w,ug-s "${ED}"/opt/wechat || die

	dosym -r /opt/wechat/wechat /usr/bin/wechat

	insinto /usr/share/applications
	domenu "${FILESDIR}"/wechat.desktop
	# The vendor's hidden entry names the mini-program runtime's window; keep it.
	domenu usr/share/applications/com.tencent.wechatappex.desktop
	# insinto above created /usr/share; the icon tree rides next to it.
	cp -a --no-preserve=ownership usr/share/icons "${ED}"/usr/share/ || die

	insinto /usr/share/licenses/${PN}
	doins "${FILESDIR}"/LICENSE
}

pkg_postinst() {
	elog "Optional runtime bits upstream suggests:"
	elog "  virtual/jack - JACK audio output for voice and video"
	elog "  an xdg-desktop-portal backend (e.g."
	elog "  sys-apps/xdg-desktop-portal-gtk) - file chooser and screen sharing"
}
