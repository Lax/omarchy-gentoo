# arch-pkgver: 0.3.2.r0.g4f508be
# Ported from pkgbuilds/quickshell-git. The Arch recipe tracks quickshell's
# main branch through a git-describe snapshot; that pin becomes the codeload
# tarball of the same commit, so the content is identical and
# Manifest-verifiable. The _p suffix encodes the commit count from Arch's
# git-describe pkgver (v0.3.0-20-g28771c7). The cmake surface is taken from
# ::guru's quickshell-0.3.1 ebuild; unknown -D options are warnings to cmake,
# so it also configures this slightly older snapshot cleanly.
EAPI=8

inherit branding cmake xdg toolchain-funcs

_COMMIT=28771c7c74b42e20afca0b1b63980cb46515537c

DESCRIPTION="Toolkit for building desktop widgets using QtQuick"
HOMEPAGE="https://quickshell.org/"
SRC_URI="https://github.com/quickshell-mirror/quickshell/archive/${_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}-${_COMMIT}"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Upstream recommends leaving all build options enabled by default
IUSE="
	+jemalloc +sockets
	+wayland +layer-shell +session-lock +toplevel-management
	+hyprland +screencopy
	+X +i3
	+tray +pipewire +mpris +pam +policykit +greetd +upower +notifications
	+bluetooth +networkmanager +crash-handler
"
REQUIRED_USE="
	layer-shell?         ( wayland )
	session-lock?        ( wayland )
	toplevel-management? ( wayland )
	hyprland?            ( wayland )
	screencopy?          ( wayland )
	i3? ( X )
"

RDEPEND="
	dev-qt/qtbase:6=[dbus,vulkan,X?]
	dev-qt/qtsvg:6=
	dev-qt/qtdeclarative:6=
	x11-libs/libdrm
	jemalloc? ( dev-libs/jemalloc )
	wayland? (
		dev-libs/wayland
		dev-qt/qtwayland:6=
	)
	screencopy? ( media-libs/mesa )
	X? ( x11-libs/libxcb )
	pipewire? ( media-video/pipewire )
	pam? ( sys-libs/pam )
	policykit? (
		sys-auth/polkit
		dev-libs/glib
	)
	bluetooth? ( net-wireless/bluez )
	networkmanager? ( net-misc/networkmanager )
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	dev-cpp/cli11
	dev-util/spirv-tools
	dev-qt/qtshadertools:6
	screencopy? ( dev-util/vulkan-headers )
	wayland? (
		dev-util/wayland-scanner
		dev-libs/wayland-protocols
	)
	crash-handler? ( dev-cpp/cpptrace[unwind] )
"

DOCS=( README.md changelog/ )

PATCHES=( "${FILESDIR}/${P}-strict-aliasing.patch" )

src_configure() {
	if tc-ld-is-mold; then
		ewarn "Using mold as a linker for quickshell will cause runtime issues"
		tc-ld-force-bfd
	fi
	# hyprland controls all Hyprland sub-features as a group.
	# i3 controls I3/Sway IPC.
	# screencopy controls all screencopy backends (icc, wlr, hyprland-toplevel).
	local _hyprland=$(usex hyprland)
	local _screencopy=$(usex screencopy)
	local _i3=$(usex i3)

	local mycmakeargs=(
		-DDISTRIBUTOR="omarchy-gentoo"
		-DINSTALL_QML_PREFIX="$(get_libdir)/qt6/qml"
		-DGIT_REVISION=${_COMMIT}
		-DCRASH_HANDLER=$(usex crash-handler)
		-DUSE_JEMALLOC=$(usex jemalloc)
		-DSOCKETS=$(usex sockets)
		-DWAYLAND=$(usex wayland)
		-DWAYLAND_WLR_LAYERSHELL=$(usex layer-shell)
		-DWAYLAND_SESSION_LOCK=$(usex session-lock)
		-DWAYLAND_TOPLEVEL_MANAGEMENT=$(usex toplevel-management)
		-DHYPRLAND=${_hyprland}
		-DHYPRLAND_IPC=${_hyprland}
		-DHYPRLAND_GLOBAL_SHORTCUTS=${_hyprland}
		-DHYPRLAND_FOCUS_GRAB=${_hyprland}
		-DHYPRLAND_SURFACE_EXTENSIONS=${_hyprland}
		-DSCREENCOPY=${_screencopy}
		-DSCREENCOPY_ICC=${_screencopy}
		-DSCREENCOPY_WLR=${_screencopy}
		-DSCREENCOPY_HYPRLAND_TOPLEVEL=${_screencopy}
		-DX11=$(usex X)
		-DI3=${_i3}
		-DI3_IPC=${_i3}
		-DSERVICE_STATUS_NOTIFIER=$(usex tray)
		-DSERVICE_PIPEWIRE=$(usex pipewire)
		-DSERVICE_MPRIS=$(usex mpris)
		-DSERVICE_PAM=$(usex pam)
		-DSERVICE_POLKIT=$(usex policykit)
		-DSERVICE_GREETD=$(usex greetd)
		-DSERVICE_UPOWER=$(usex upower)
		-DSERVICE_NOTIFICATIONS=$(usex notifications)
		-DBLUETOOTH=$(usex bluetooth)
		-DNETWORK=$(usex networkmanager)
	)
	cmake_src_configure
}
