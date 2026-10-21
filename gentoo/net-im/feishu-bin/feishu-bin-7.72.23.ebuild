# arch-pkgver: 7.72.23
# Ported from pkgbuilds/feishu-bin. Feishu files each build under a
# per-architecture directory on its CDN, addressed by an opaque path hash
# (_hash_*) that has to ride every bump: like perplexity's _build pin,
# sync-gentoo cannot refresh these mechanically - update both by hand with
# the marker, and confirm the new debs answer 200 before trusting them (the
# CDN 403s superseded builds).
EAPI=8

inherit desktop
_hash_x86_64=fc38d53a
_hash_aarch64=8d668c7a

DESCRIPTION="Feishu (飞书), ByteDance messaging, meetings and docs for the China service"
HOMEPAGE="https://www.feishu.cn/"
SRC_URI="
	amd64? ( https://sf3-cn.feishucdn.com/obj/ee-appcenter/${_hash_x86_64}/Feishu-linux_x64-${PV}.deb -> ${P}.deb )
	arm64? ( https://sf3-cn.feishucdn.com/obj/ee-appcenter/${_hash_aarch64}/Feishu-linux_arm64-${PV}.deb -> ${P}.deb )
"

S="${WORKDIR}"
# Upstream ships no license text with the app; terms at
# https://www.feishu.cn/en/terms
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	media-libs/alsa-lib
	app-accessibility/at-spi2-core
	x11-libs/cairo
	sys-apps/dbus
	dev-libs/expat
	dev-libs/glib
	net-libs/gnutls
	x11-libs/gtk+:3
	net-print/cups
	x11-libs/libdrm
	dev-libs/libgcrypt
	media-libs/libglvnd
	media-libs/libpulse
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXtst
	media-libs/mesa
	dev-libs/nspr
	dev-libs/nss
	x11-libs/pango
	x11-libs/pixman
	sys-apps/systemd
	x11-misc/xdg-utils
	sys-libs/zlib
"
BDEPEND="app-arch/libarchive"
RESTRICT="strip mirror"
QA_PREBUILT="/opt/bytedance/feishu/*"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	bsdtar -O -xf "${DISTDIR}/${P}.deb" 'data.tar.*' |
		bsdtar --no-same-owner -xf - || die
}

src_install() {
	local app="${ED}"/opt/bytedance/feishu
	local expected_machine

	# The payload itself: cp before any helper creates ${ED}/opt, or cp
	# would nest opt/ inside it.
	install -d "${ED}"/opt || die
	cp -a --no-preserve=ownership opt/bytedance/feishu "${app}" || die

	case ${ARCH} in
		amd64) expected_machine='Advanced Micro Devices X86-64' ;;
		arm64) expected_machine=AArch64 ;;
	esac

	# The arm64 deb carries an x86-64 copy of this one library, which
	# nothing links and an ARM machine cannot load; drop it only while it
	# is that copy.
	local stray="${app}/libbyteview-record.so"
	if [[ ${ARCH} == arm64 && -f ${stray} ]] &&
		LC_ALL=C readelf -h "${stray}" |
			grep -q 'Machine:[[:space:]]*Advanced Micro Devices X86-64'; then
		rm "${stray}" || die
	fi
	local file machine
	while IFS= read -r -d '' file; do
		[[ $(od -An -tx1 -N4 "${file}" | tr -d ' ') == 7f454c46 ]] || continue
		machine=$(LC_ALL=C readelf -h "${file}" 2>/dev/null |
			sed -n 's/^[[:space:]]*Machine:[[:space:]]*//p')
		[[ ${machine} == "${expected_machine}" ]] ||
			die "Unexpected ${machine:-unreadable} binary: ${file#"${ED}"}"
	done < <(find "${app}" -type f -print0)

	# Updates land unattended, so a setuid or setgid file appearing in a
	# new release stops the build for review rather than shipping.
	if [[ -n $(find "${app}" -perm /6000 -print -quit) ]]; then
		die "Feishu ${PV} ships setuid/setgid files; review them."
	fi

	find "${app}" -type d -exec chmod 755 {} + || die
	chmod -R go-w "${app}" || die

	newbin "${FILESDIR}"/feishu.sh feishu

	# The vendor's maintainer scripts install icons and the desktop entry
	# at install time; ship them as package files instead, and none of
	# the scripts.
	newmenu usr/share/applications/bytedance-feishu.desktop bytedance-feishu.desktop
	sed -i -e 's|^Exec=.*|Exec=feishu %U|' \
		-e '/^#/d' -e '/^X-KDE-/d' \
		"${ED}"/usr/share/applications/bytedance-feishu.desktop || die
	local size
	for size in 16 24 32 48 64 128 256; do
		insinto /usr/share/icons/hicolor/${size}x${size}/apps
		doins "${app}"/product_logo_${size}.png
	done
	insinto /usr/share/icons/hicolor/scalable/apps
	doins "${app}"/product_logo_256.svg

	insinto /usr/share/licenses/${PN}
	doins "${FILESDIR}"/LICENSE
}
