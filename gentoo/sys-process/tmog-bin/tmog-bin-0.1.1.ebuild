# arch-pkgver: 0.1.1
# Ported from pkgbuilds/tmog-bin. The download URL carries no version — tmog.org
# serves every release from the same path; the query string is upstream's own
# cache key, and the checksum is the pin. A bump must re-verify the tarball's
# directory name really matches the new pkgver.
EAPI=8

inherit desktop

DESCRIPTION="Native system monitor and task manager"
HOMEPAGE="https://tmog.org/"
_SRCDIR="TaskManagerOG-${PV}-linux-x86_64"
SRC_URI="${HOMEPAGE}downloads/TMOG-Task-Manager-Linux-x86_64.tar.gz?v=${PV}-free -> ${P}.tar.gz"

S="${WORKDIR}/${_SRCDIR}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	sys-apps/systemd
	x11-themes/hicolor-icon-theme
	dev-qt/qtbase:6
	dev-qt/qtsvg:6
	dev-qt/qtwayland:6
"
RESTRICT="strip mirror"
QA_PREBUILT="/usr/bin/tmog-task-manager"

src_install() {
	# The Wayland platform plugin is what this actually runs on; without the
	# Qt wayland package it falls back to xcb under XWayland.
	dobin bin/tmog-task-manager
	domenu share/applications/com.tmog.taskmanager.desktop
	insinto /usr/share/metainfo
	doins share/metainfo/com.tmog.taskmanager.metainfo.xml
	insinto /usr/share/pixmaps
	newins share/pixmaps/tmog-task-manager.png tmog-task-manager.png
	local icon
	for icon in share/icons/hicolor/*/apps/tmog-task-manager.png; do
		insinto "/usr/$(dirname "${icon}")"
		doins "${icon}"
	done
	# Upstream files its licence texts under share/doc, Debian layout; they
	# belong with the package's licences here.
	local doc
	for doc in share/doc/tmog/* share/doc/taskmanagerog/copyright; do
		[[ -f ${doc} ]] || continue
		insinto /usr/share/licenses/${PF}
		doins "${doc}"
	done
}
