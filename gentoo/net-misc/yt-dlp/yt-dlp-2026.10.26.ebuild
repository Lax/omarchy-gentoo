# arch-pkgver: 2026.10.26
# Ported from pkgbuilds/yt-dlp. The official zipapp, run by the system
# python: it bundles yt-dlp-ejs (the YouTube challenge solver) and installs
# no Python modules, so it can follow upstream on the fast ring.
# ::gentoo carries net-misc/yt-dlp as well; at an equal version this
# overlay ebuild wins (the variant that knows about node), and a newer
# ::gentoo bump shadows this one until the next sync - the visible
# difference is only the ejs bundling and /etc/yt-dlp.conf.
EAPI=8

DESCRIPTION="A youtube-dl fork with additional features and fixes"
HOMEPAGE="https://github.com/yt-dlp/yt-dlp"
SRC_URI="https://github.com/yt-dlp/yt-dlp/releases/download/${PV}/yt-dlp -> ${P}"

S="${WORKDIR}"
LICENSE="Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	dev-lang/python
	net-libs/nodejs
"
RESTRICT="strip mirror"

src_install() {
	newbin "${DISTDIR}/${P}" yt-dlp
	# --js-runtimes node: yt-dlp only looks for deno unless told otherwise,
	# and the overlay's runtime is node.
	insinto /etc
	newins "${FILESDIR}"/yt-dlp.conf yt-dlp.conf
}

pkg_postinst() {
	elog "Optional helpers not pulled in: media-video/ffmpeg (video"
	elog "post-processing and format merging), net-misc/aria2 (external"
	elog "downloader), media-video/rtmpdump (rtmp streams),"
	elog "AtomicParsley (m4a thumbnail embedding)."
}
