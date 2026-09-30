# arch-pkgver: 0.10.1
# Ported from pkgbuilds/disktree-bin.
EAPI=8

inherit desktop

DESCRIPTION="Disk space treemap for Omarchy: see what fills a disk by kind, mark what should go, and remove it"
HOMEPAGE="https://github.com/tobi/disktree"
SRC_URI="
	amd64? ( https://github.com/tobi/disktree/releases/download/v${PV}/disktree-${PV}-x86_64-linux.tar.gz )
	arm64? ( https://github.com/tobi/disktree/releases/download/v${PV}/disktree-${PV}-aarch64-linux.tar.gz )
"

# The tarball's top-level directory names the arch the way upstream packs it;
# global-scope usex is not available when portage generates metadata.
if [[ ${ARCH} == amd64 ]]; then
	S="${WORKDIR}/disktree-${PV}-x86_64-linux"
else
	S="${WORKDIR}/disktree-${PV}-aarch64-linux"
fi
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	x11-libs/libxcb
	x11-libs/libxkbcommon[X]
	dev-libs/wayland
	media-libs/libglvnd
	media-libs/vulkan-loader
"
RESTRICT="strip mirror"
QA_PREBUILT="usr/bin/disktree"

src_install() {
	dobin disktree

	sed -e 's|@BINDIR@/||' -e "s|@VERSION@|${PV}|" \
		disktree.desktop.in > "${T}"/disktree.desktop || die
	domenu "${T}"/disktree.desktop
	newicon disktree.svg disktree.svg

	insinto /usr/share/licenses/${PN}
	doins LICENSE
	dodoc README.md
}

pkg_postinst() {
	elog "Optional: app-misc/trash-cli moves deletions to the trash with"
	elog "trash-put (a built-in XDG trash or gio is used otherwise);"
	elog "dev-vcs/git annotates checkouts with changes, stashes and"
	elog "unpushed commits."
}
