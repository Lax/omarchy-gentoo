# arch-pkgver: 0.33.4
# Ported from pkgbuilds/cua-driver-bin. Earlier 0.28.3..0.32.x releases
# were held upstream for a screenshot regression; the hold lifted before
# 0.33 once upstream fixed the screenshot path.
EAPI=8

DESCRIPTION="Computer-use driver for native GUI apps: accessibility-tree snapshots and input injection"
HOMEPAGE="https://github.com/trycua/cua"
SRC_URI="
	amd64? ( https://github.com/trycua/cua/releases/download/cua-driver-rs-v${PV}/cua-driver-rs-${PV}-linux-x86_64.tar.gz )
	arm64? ( https://github.com/trycua/cua/releases/download/cua-driver-rs-v${PV}/cua-driver-rs-${PV}-linux-arm64.tar.gz )
"

# The vendor tarball directory names the arch the way upstream packs it;
# global-scope usex is not available when portage generates metadata.
if [[ ${ARCH} == amd64 ]]; then
	S="${WORKDIR}/cua-driver-rs-${PV}-linux-x86_64"
else
	S="${WORKDIR}/cua-driver-rs-${PV}-linux-arm64"
fi
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# at-spi2-core carries the AT-SPI accessibility bus the driver reads GUI
# trees through; the X libraries are linked, not dlopen'd.
RDEPEND="
	app-accessibility/at-spi2-core
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libxkbcommon
"
# Prebuilt Rust binaries ship byte-exact apart from the installer rewrite in
# src_prepare; their build ids are what upstream symbolication matches.
RESTRICT="strip mirror"
QA_PREBUILT="usr/lib/cua-driver/.*"

# Rust strings carry their length out of band, so the replacement has to be
# exactly as long as the original, which is what fixes the stand-in's short
# name and location.
_vendor_installer='https://cua.ai/driver/install.sh'
_pm_installer='file:///usr/lib/cua-driver/pm.sh'

src_prepare() {
	default

	if [[ ${#_vendor_installer} -ne ${#_pm_installer} ]]; then
		die "installer URLs must be the same length to rewrite in place"
	fi

	# In 0.28.1 the URL appears in the updater, the printed reinstall command,
	# and two embedded copies of Skills/cua-driver/README.md. Rewrite all four
	# so the embedded instructions also defer to the package manager. Any
	# other count means the release layout changed and needs review before
	# packaging.
	local expected=4 found
	found=$(grep -obUaF "${_vendor_installer}" cua-driver | wc -l)
	[[ ${found} -eq ${expected} ]] ||
		die "expected the vendor installer URL ${expected} times in cua-driver, found ${found}"

	local size_before size_after
	size_before=$(stat -c %s cua-driver)
	sed -i "s|${_vendor_installer//./\\.}|${_pm_installer}|g" cua-driver || die
	size_after=$(stat -c %s cua-driver)

	if [[ ${size_before} -ne ${size_after} ]] \
		|| grep -qUaF "${_vendor_installer}" cua-driver \
		|| [[ $(grep -obUaF "${_pm_installer}" cua-driver | wc -l) -ne ${expected} ]]; then
		die "installer URL rewrite did not land cleanly in cua-driver"
	fi
}

src_install() {
	# The vendor tree stays together: cua-driver execs cua-cursor-theme as a
	# sibling of the resolved binary, and the SDK library, node runtime, ABI
	# header, and the GNOME wayland-helper extension are versioned with it.
	dodir /usr/lib/cua-driver
	cp -a . "${ED}"/usr/lib/cua-driver/ || die
	chmod -R a+rX "${ED}"/usr/lib/cua-driver || die

	# The path src_prepare wrote into the binary. Stands in for the vendor
	# installer so `cua-driver update --apply` cannot step around Portage and
	# this repository's release gate.
	exeinto /usr/lib/cua-driver
	newexe "${FILESDIR}"/pm.sh pm.sh

	dosym ../lib/cua-driver/cua-driver /usr/bin/cua-driver

	insinto /usr/share/licenses/${PN}
	doins "${FILESDIR}"/LICENSE
}
