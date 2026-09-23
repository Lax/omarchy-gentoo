# arch-pkgver: 0.0.3
# Ported from pkgbuilds/omaspeak-bin. Arch ships an ALPM PreTransaction hook
# that stops and removes the app's user services across every user before
# removal; on Gentoo the same shipped helper runs from pkg_prerm instead.
EAPI=8

inherit systemd

DESCRIPTION="Local-first text-to-speech application and daemon (pre-built binary)"
HOMEPAGE="https://github.com/jacob-vincent-mink/omaspeak"
SRC_URI="
	amd64? ( https://github.com/jacob-vincent-mink/omaspeak/releases/download/v${PV}/omaspeak-${PV}-linux-x86_64.tar.xz )
	arm64? ( https://github.com/jacob-vincent-mink/omaspeak/releases/download/v${PV}/omaspeak-${PV}-linux-aarch64.tar.xz )
"

LICENSE="MIT Apache-2.0 BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="media-sound/alsa-utils"
RESTRICT="strip mirror"

if [[ ${ARCH} == amd64 ]]; then
	S="${WORKDIR}/omaspeak-${PV}-linux-x86_64"
else
	S="${WORKDIR}/omaspeak-${PV}-linux-aarch64"
fi

src_install() {
	dobin omaspeak

	exeinto /usr/libexec/omaspeak
	doexe "${FILESDIR}/package-remove"

	exeinto /usr/lib/omaspeak
	doexe lib/libaudiocpp.so.0.1.0
	dosym libaudiocpp.so.0.1.0 /usr/lib/omaspeak/libaudiocpp.so.0
	dosym libaudiocpp.so.0 /usr/lib/omaspeak/libaudiocpp.so

	systemd_douserunit packaging/systemd/omaspeak.service

	local document
	for document in README.md INSTALL.md ACCELERATOR_SETUP.md CHANGELOG.md \
		RELEASE_NOTES.md DEMO.md RUNTIME.md config.example.toml; do
		[[ -f "${document}" ]] && dodoc "${document}"
	done
	docinto assets
	dodoc -r assets
	docinto benchmarks
	dodoc -r benchmarks
	if [[ -d licenses ]]; then
		docinto licenses
		dodoc -r licenses/.
	fi
}

pkg_prerm() {
	# Mirror of the Arch PreTransaction hook (AbortOnFail): stop and remove
	# the user services this app generated before the files go away.
	"${EROOT}/usr/libexec/omaspeak/package-remove" omaspeak ||
		die "could not clean up omaspeak user services; stop/remove them and retry"
}

pkg_postinst() {
	elog "Run 'omaspeak setup' to configure a model and runtime."
	elog "The optional user service stays disabled; on-demand speech works"
	elog "without it. Accelerator instructions: see the ACCELERATOR_SETUP.md"
	elog "document shipped with this package."
}
