# arch-pkgver: 0.0.3
# Ported from pkgbuilds/omawake-bin. Arch ships an ALPM PreTransaction hook
# that stops and removes the app's user services across every user before
# removal; on Gentoo the same shipped helper runs from pkg_prerm instead.
EAPI=8

inherit systemd

DESCRIPTION="Configurable local wake-word daemon (pre-built binary)"
HOMEPAGE="https://github.com/jacob-vincent-mink/omawake"
SRC_URI="
	amd64? ( https://github.com/jacob-vincent-mink/omawake/releases/download/v${PV}/omawake-${PV}-linux-x86_64.tar.xz )
	arm64? ( https://github.com/jacob-vincent-mink/omawake/releases/download/v${PV}/omawake-${PV}-linux-aarch64.tar.xz )
"

LICENSE="MIT Apache-2.0 BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="media-libs/alsa-lib"
RESTRICT="strip mirror"

if [[ ${ARCH} == amd64 ]]; then
	S="${WORKDIR}/omawake-${PV}-linux-x86_64"
else
	S="${WORKDIR}/omawake-${PV}-linux-aarch64"
fi

src_install() {
	dobin omawake

	exeinto /usr/libexec/omawake
	doexe "${FILESDIR}/package-remove"

	exeinto /usr/lib/omawake
	doexe lib/libaudiocpp.so.0.1.0
	dosym libaudiocpp.so.0.1.0 /usr/lib/omawake/libaudiocpp.so.0
	dosym libaudiocpp.so.0 /usr/lib/omawake/libaudiocpp.so

	systemd_douserunit packaging/systemd/omawake.service

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
	"${EROOT}/usr/libexec/omawake/package-remove" omawake ||
		die "could not clean up omawake user services; stop/remove them and retry"
}

pkg_postinst() {
	elog "Run 'omawake setup' to configure a model and runtime; see the"
	elog "ACCELERATOR_SETUP.md document shipped with this package for"
	elog "accelerator runtimes."
}
