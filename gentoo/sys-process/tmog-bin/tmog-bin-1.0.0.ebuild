# arch-pkgver: 1.0.0
# Ported from pkgbuilds/tmog-bin. Repackages the vendor's Qt-linked tarball
# (8 MB against the system Qt) rather than the bundled-Qt AppImage.
EAPI=8

inherit desktop

DESCRIPTION="Native system monitor and task manager"
HOMEPAGE="https://tmog.org/"
SRC_URI="https://tmog.org/rtm/downloads/TaskManagerOG-${PV}-linux-x86_64.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/TaskManagerOG-${PV}-linux-x86_64"
# The vendor ships no source and files its copyright text beside the tarball;
# installed into /usr/share/licenses/${PN} below.
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64"

# Omarchy is a Wayland desktop, so the Wayland platform plugin is what this
# actually runs on; without it Qt falls back to xcb under XWayland.
RDEPEND="
	dev-qt/qtbase:6
	dev-qt/qtmultimedia
	dev-qt/qtsvg:6
	dev-qt/qtwayland:6
	sys-apps/systemd
	x11-themes/hicolor-icon-theme
"
RESTRICT="strip mirror"
QA_PREBUILT="usr/bin/tmog-task-manager"

src_install() {
	dobin bin/tmog-task-manager

	domenu share/applications/com.tmog.taskmanager.desktop
	insinto /usr/share/metainfo
	doins share/metainfo/com.tmog.taskmanager.metainfo.xml
	insinto /usr/share/pixmaps
	doins share/pixmaps/tmog-task-manager.png

	local icon
	for icon in share/icons/hicolor/*/apps/tmog-task-manager.png; do
		insinto "/usr/${icon%/*}"
		doins "${icon}"
	done

	# Upstream files its licence texts under share/doc, which is Debian's
	# layout; they belong with the package's licences here.
	insinto /usr/share/licenses/${PN}
	doins share/doc/tmog/*
	doins share/doc/taskmanagerog/copyright
}
