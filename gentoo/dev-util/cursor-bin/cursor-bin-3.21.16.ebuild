# arch-pkgver: 3.21.16
# Ported from pkgbuilds/cursor-bin. Arch points Cursor at the system
# electron42 package; Gentoo has no matching electron, so this ebuild keeps
# the .deb's bundled electron and its own launcher instead of rewriting
# Arch's code.sh. The updater disable (deleting updateUrl/backupUpdateUrl
# from product.json) is ported verbatim: on Gentoo, Portage is the only
# update channel.
EAPI=8

DESCRIPTION="AI-first coding environment"
HOMEPAGE="https://www.cursor.com"
# Upstream's CDN path embeds the release directory commit.
_COMMIT=8ae78e8eee1e63479c7e0504b664bc0a80c6800f
SRC_URI="https://downloads.cursor.com/production/${_COMMIT}/linux/x64/deb/amd64/deb/cursor_${PV}_amd64.deb -> ${P}.deb"

S="${WORKDIR}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-libs/nss
	net-libs/nodejs
	x11-libs/gtk+:3
	x11-libs/libxkbfile
	x11-misc/xdg-utils
	x11-themes/hicolor-icon-theme
"
BDEPEND="app-arch/libarchive"
RESTRICT="strip mirror"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	bsdtar -xf "${DISTDIR}/${P}.deb" data.tar.xz || die
	bsdtar -xf data.tar.xz --no-same-owner || die
}

src_install() {
	local app=usr/share/cursor
	local app_res=usr/share/cursor/resources/app

	# Disable Cursor's bundled updater; Omarchy manages updates via the
	# package manager (omarchy-pkgs#238).
	sed -i '/^[[:space:]]*"\(backupUpdateUrl\|updateUrl\)":/d' \
		"${S}/${app}/product.json" || die

	# The deb ships zsh completions in the Debian vendor dir.
	if [[ -d "${S}"/usr/share/zsh/vendor-completions ]]; then
		mv "${S}"/usr/share/zsh/{vendor-completions,site-functions} || die
	fi

	cp -a "${S}"/usr "${ED}"/ || die

	# Bind the bundled runtime's helpers to system tools, like Arch does.
	dosym -r /usr/bin/node "/${app_res}/resources/helpers/node"
	dosym -r /usr/bin/xdg-open "/${app_res}/node_modules/open/xdg-open"

	# The bundled electron needs the setuid sandbox.
	if [[ -f "${ED}/${app}/chrome-sandbox" ]]; then
		fperms 4755 "/${app}/chrome-sandbox"
	else
		ewarn "chrome-sandbox not found in this release; the app may refuse"
		ewarn "to start without --no-sandbox."
	fi

	# One launcher on PATH, owned by this ebuild whether or not the deb
	# shipped its own.
	rm -f "${ED}/usr/bin/cursor" || die
	dosym -r "/${app}/cursor" /usr/bin/cursor
}
