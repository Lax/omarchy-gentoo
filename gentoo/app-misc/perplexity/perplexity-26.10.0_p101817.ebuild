# arch-pkgver: 26.10.0+build101817
# Ported from pkgbuilds/perplexity. The Arch version's "+build" does not fit a
# Gentoo version string; it maps to the _p suffix here. The pool URL needs %2B
# for '+'.
#
# The pool is rolling and 403s superseded builds, so every bump must confirm
# the new debs exist in the pool before trusting the pin (in 2026-09 the
# 26.9.4+build72244 debs vanished and the pin temporarily tracked the
# dists/stable index instead of the pkgver). Reconciled back to the upstream
# pkgver at 26.9.6+build89647.
EAPI=8

inherit desktop

DESCRIPTION="Official Perplexity desktop app"
HOMEPAGE="https://www.perplexity.ai"
_pool="https://packages.perplexity.ai/deb/pool/main/p/perplexity"
_build="26.9.6%2Bbuild89647"
SRC_URI="
	amd64? ( ${_pool}/perplexity_${_build}_amd64.deb -> ${P}.deb )
	arm64? ( ${_pool}/perplexity_${_build}_arm64.deb -> ${P}.deb )
"

S="${WORKDIR}"
# Upstream ships no license text with the app; terms at
# https://www.perplexity.ai/hub/legal/terms-of-service
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	app-accessibility/at-spi2-core
	dev-libs/expat
	dev-libs/glib
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/libdrm
	media-libs/libglvnd
	media-libs/libnotify
	media-libs/libsecret
	media-libs/mesa
	net-print/cups
	sys-apps/bubblewrap
	sys-apps/dbus
	sys-apps/systemd
	sys-apps/util-linux
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXScrnSaver
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
	x11-themes/hicolor-icon-theme
	media-libs/vulkan-loader
	app-shells/bash
"
BDEPEND="app-arch/libarchive"
RESTRICT="strip mirror"
QA_PREBUILT="/opt/Perplexity/*"

src_unpack() {
	mkdir -p "${S}" || die
	cd "${S}" || die
	bsdtar -xf "${DISTDIR}/${P}.deb" data.tar.xz || die
	bsdtar --no-same-owner -xf data.tar.xz || die
}

src_install() {
	# The deb ships a systemd unit under /lib (a symlink owned by the Gentoo
	# filesystem package). It is also a no-op off Ubuntu: its setup script
	# apt-installs Docker and the NVIDIA toolkit. Drop it and anything else
	# left outside opt/ and usr/.
	rm -f lib/systemd/system/perplexity-local-runtime-setup.service || die
	rm -rf lib || die
	local unexpected
	unexpected=$(find . -mindepth 1 -path ./opt -prune -o -path ./usr -prune -o -print)
	[[ -z "${unexpected}" ]] || die "Unexpected entries outside opt/ and usr/ in the upstream deb: ${unexpected}"

	# pacman never runs the deb's postinst, so the /usr/bin entry is our
	# launcher; the menu entry goes through it so a flags file applies too.
	rm -f usr/bin/perplexity || die
	sed -i 's|^Exec=.*|Exec=perplexity %U|' \
		usr/share/applications/perplexity.desktop || die
	# Debian package-policy files are not used on Gentoo.
	rm -rf usr/share/doc || die

	# The payload itself: cp before any helper creates ${ED}/usr, or cp would
	# nest usr/ inside it.
	cp -a opt usr "${ED}"/ || die
	newbin "${FILESDIR}"/perplexity-launcher.sh perplexity

	# Chromium's sandbox helper ships setuid on Arch (postinst does it for the
	# deb); keep the sandbox up on kernels that deny unprivileged namespaces.
	fperms 4755 opt/Perplexity/chrome-sandbox
	# The profile the deb's postinst would install; it names /opt/Perplexity.
	insinto /etc/apparmor.d
	doins opt/Perplexity/resources/apparmor-profile
}

pkg_postinst() {
	elog "A local GPU runtime for on-device models needs app-containers/docker"
	elog "and app-containers/nvidia-container-toolkit (where available)."
}
