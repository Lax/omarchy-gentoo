# arch-pkgver: 1.22.5
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Ported from pkgbuilds/collie-bin. The release tarball is a compiled Bun
# single-file executable plus the tree it serves at run time (web/dist,
# herdr-plugin.toml, package.json, .env.example, scripts/) - nothing is
# built here and stripping breaks the binary.
#
# /usr/bin/collie MUST stay a symlink into /opt/collie: the binary resolves
# its root as dirname(dirname(realpath(argv0))) and accepts that root only
# if herdr-plugin.toml sits in it, so a real file at /usr/bin would make
# the root /usr and the bridge would find neither web/dist nor the
# manifest.
EAPI=8

DESCRIPTION="Phone web UI for the AI agents running in your terminal, served over Tailscale"
HOMEPAGE="https://github.com/AltanS/collie"
SRC_URI="
	amd64? ( https://github.com/AltanS/collie/releases/download/v${PV}/collie-${PV}-linux-x64.tar.gz
		-> ${P}-linux-x64.tar.gz )
	arm64? ( https://github.com/AltanS/collie/releases/download/v${PV}/collie-${PV}-linux-arm64.tar.gz
		-> ${P}-linux-arm64.tar.gz )
"

S="${WORKDIR}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# glibc is the only shared-library set the executable links (Bun statically
# links the rest); every action in the shipped herdr-plugin.toml runs bash.
RDEPEND="app-shells/bash"

RESTRICT="strip mirror"
QA_PREBUILT="/opt/collie/bin/collie /opt/collie/scripts/*"

src_install() {
	local distdir="${WORKDIR}/collie-${PV}-$([[ ${ARCH} == amd64 ]] && echo x64 || echo arm64)"

	# Everything the run time reads keeps its path relative to /opt/collie.
	while IFS= read -r -d '' f; do
		case "${f}" in
			bin/*|LICENSE|README.md|CHANGELOG.md|docs/*) continue ;;
			scripts/*) install -Dm755 "${distdir}/${f}" "${ED}/opt/collie/${f}" ;;
			*)         install -Dm644 "${distdir}/${f}" "${ED}/opt/collie/${f}" ;;
		esac
	done < <(find "${distdir}" -type f -printf '%P\0')
	install -Dm755 "${distdir}/bin/collie" "${ED}/opt/collie/bin/collie" || die
	dosym ../../opt/collie/bin/collie /usr/bin/collie

	dodoc "${distdir}"/README.md "${distdir}"/CHANGELOG.md
	dodoc -r "${distdir}"/docs
	insinto /usr/share/licenses/${PN}
	doins "${distdir}"/LICENSE
}

pkg_postinst() {
	elog "Start Collie with: collie start"
	elog "Collie drives one multiplexer and will not guess when it sees two,"
	elog "for example tmux and Herdr. Name one: COLLIE_MUX=herdr collie start"
	elog "Optional: herdr plugin link /opt/collie adds Collie to the Herdr plugin menu."
	elog "Herdr does not scan /opt, so it never finds the package on its own."
}

pkg_prerm() {
	elog "The systemd --user unit and the tailscale serve mapping Collie"
	elog "published stay unless you ran collie uninstall first."
}

pkg_postrm() {
	elog "Left behind, delete by hand when you want them gone:"
	elog "  ~/.local/state/collie/"
	elog "  ~/.config/herdr/plugins/config/herdr.collie/"
}
