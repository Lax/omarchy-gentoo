# arch-pkgver: 0.2.0
# Ported from pkgbuilds/omarchy-billboard-generator. The release archive
# carries a package-lock but no vendored node_modules, so the build runs the
# same locked 'npm ci --omit=dev --ignore-scripts' install as upstream's
# installer; that needs the network, hence network-sandbox is lifted for this
# package only.
EAPI=8

inherit desktop

DESCRIPTION="Animated Omarchy domain videos, desktop app and CLI (Omarchy application)"
HOMEPAGE="https://github.com/llstrk/omarchy-billboard-generator"
SRC_URI="https://github.com/llstrk/omarchy-billboard-generator/releases/download/v${PV}/${PN}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}"
# MIT covers the project's own code; Apache-2.0 and 0BSD the vendored npm
# dependencies; OFL-1.1 the bundled fonts; all-rights-reserved the Omarchy
# wordmark/palette assets carried over from omarchy-site (see PROVENANCE.md).
LICENSE="MIT Apache-2.0 0BSD OFL-1.1 all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# src_compile runs 'npm ci', which needs the network; the nightly smoke job
# emerges with FEATURES=-network-sandbox for this package's sake.

# Rendering drives a Chromium-family browser; ::gentoo's chromium is
# package.masked (removal 2026-10-24), so any of these satisfies it.
RDEPEND="
	>=net-libs/nodejs-22
	media-video/ffmpeg
	|| (
		omarchy/omarchy-chromium-bin
		www-client/google-chrome
		www-client/google-chrome-beta
		www-client/chromium
	)
	x11-misc/xdg-utils
"
BDEPEND="net-libs/nodejs"

src_compile() {
	export npm_config_cache="${T}/npm-cache"
	npm ci --omit=dev --ignore-scripts || die
}

src_install() {
	local appdir=/usr/lib/${PN}
	insinto "${appdir}"
	# Only what runs: no tests, release scripts, CI, or the curl|bash installer.
	doins -r bin src app web assets data examples node_modules package.json
	fperms 0755 "${appdir}/bin/omarchy-billboard" "${appdir}/bin/omarchy-billboard-app"

	dosym -r "${appdir}/bin/omarchy-billboard" /usr/bin/omarchy-billboard
	dosym -r "${appdir}/bin/omarchy-billboard-app" /usr/bin/omarchy-billboard-app

	local desktop="${T}/${PN}.desktop"
	cat >"${desktop}" <<-EOF || die
	[Desktop Entry]
	Version=1.0
	Type=Application
	Name=Omarchy Billboard Generator
	Comment=Create animated Omarchy domain videos locally
	Exec=omarchy-billboard-app
	Icon=${PN}
	Terminal=false
	Categories=AudioVideo;Video;
	StartupWMClass=chrome-127.0.0.1__omarchy-billboard-Default
	EOF
	domenu "${desktop}"

	insinto /usr/share/icons/hicolor/scalable/apps
	newins app/icon.svg "${PN}.svg"

	einstalldocs
	docinto licenses
	dodoc LICENSE PROVENANCE.md
	docinto licenses
	dodoc assets/fonts/*-OFL.txt
}
