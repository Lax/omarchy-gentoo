# arch-pkgver: 0.18.0
# Ported from pkgbuilds/gridcraft-bin.
EAPI=8

inherit xdg

# Prebuilt vendor binary: RESTRICT keeps portage from stripping the Rust
# release build or mirroring the payload. Upstream's provides/conflicts on
# "gridcraft" has no ::gentoo or overlay counterpart to conflict with.
DESCRIPTION="Clean-room spreadsheet in pure Rust that opens and saves Excel workbooks"
HOMEPAGE="https://github.com/storytold/gridcraft"
SRC_URI="
	amd64? ( https://github.com/storytold/gridcraft/releases/download/v${PV}/gridcraft-${PV}-linux-x86_64.tar.gz )
	arm64? ( https://github.com/storytold/gridcraft/releases/download/v${PV}/gridcraft-${PV}-linux-aarch64.tar.gz )
"

# Dual-licensed Rust code with bundled OFL fonts; the license files ship in
# the tarball's share/doc and land in /usr/share/doc via dodoc.
LICENSE="|| ( Apache-2.0 MIT ) OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-libs/wayland
	media-libs/vulkan-loader
	sys-apps/dbus
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	x11-themes/hicolor-icon-theme
"

RESTRICT="strip mirror"
QA_PREBUILT="usr/bin/gridcraft*"

if [[ ${ARCH} == amd64 ]]; then
	S="${WORKDIR}/gridcraft-${PV}-linux-x86_64"
else
	S="${WORKDIR}/gridcraft-${PV}-linux-aarch64"
fi

src_install() {
	dobin bin/gridcraft bin/gridcraft-cli

	# Vendor share tree: icons, desktop entry, AppStream metainfo, MIME
	# database. doc/ is Portage's turf (dodoc below).
	cp -a share "${ED}/usr/" || die
	rm -rf "${ED}/usr/share/doc" || die
	dodoc share/doc/gridcraft/*
}
