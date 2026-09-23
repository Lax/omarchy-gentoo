# arch-pkgver: 2.1.278
# Ported from pkgbuilds/claude-code. The binary is a self-contained Bun
# executable with embedded JS/resources - stripping breaks it. The wrapper
# suppresses upstream's self-update paths: on Gentoo, Portage is the only
# update channel.
EAPI=8

DESCRIPTION="An agentic coding tool that lives in your terminal"
HOMEPAGE="https://github.com/anthropics/claude-code https://code.claude.com/docs/"
SRC_URI="
	https://code.claude.com/docs/en/legal-and-compliance.md -> ${PN}-legal-${PV}.md
	amd64? ( https://downloads.claude.ai/claude-code-releases/${PV}/linux-x64/claude -> ${PN}-${PV}-amd64 )
	arm64? ( https://downloads.claude.ai/claude-code-releases/${PV}/linux-arm64/claude -> ${PN}-${PV}-arm64 )
"

S="${WORKDIR}"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="app-shells/bash"
RESTRICT="strip mirror"

src_install() {
	local distbin
	case "${ARCH}" in
		amd64) distbin=${PN}-${PV}-amd64 ;;
		arm64) distbin=${PN}-${PV}-arm64 ;;
		*) die "unsupported ARCH ${ARCH}" ;;
	esac

	exeinto /opt/${PN}/bin
	newexe "${DISTDIR}/${distbin}" claude

	local wrapper="${T}/claude"
	cat >"${wrapper}" <<'EOF' || die
#!/bin/sh
export DISABLE_UPDATES=1
export DISABLE_INSTALLATION_CHECKS=1
exec /opt/claude-code/bin/claude "$@"
EOF
	exeinto /usr/bin
	doexe "${wrapper}"

	dodoc "${DISTDIR}/${PN}-legal-${PV}.md"
}

pkg_postinst() {
	elog "Optional integrations: dev-vcs/git, github-cli (gh), glab,"
	elog "sys-apps/ripgrep, app-misc/tmux, sys-apps/bubblewrap (+net-misc/socat"
	elog "for sandboxing)."
}
