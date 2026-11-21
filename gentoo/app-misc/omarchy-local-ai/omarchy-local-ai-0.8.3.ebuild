# arch-pkgver: 0.8.3
# Ported from pkgbuilds/omarchy-local-ai.
# Copyright 2026 Gentoo Authors
# Distributed under the terms of the MIT license

EAPI=8

DESCRIPTION="Run open models locally for Omarchy's coding agents with curated recipes"
HOMEPAGE="https://github.com/omacom/omarchy-local-ai"
SRC_URI="https://github.com/omacom/omarchy-local-ai/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# python covers the launcher script and its validate mode; systemd is what
# the script drives the model containers through.
RDEPEND="
	dev-lang/python
	sys-apps/systemd
"

# The Arch optdepends are the rootless container stack the models run in;
# they stay optional on Gentoo and the postinst names them.
pkg_postinst() {
	elog "Running the curated models needs a rootless container stack:"
	elog "  app-containers/podman - the runner Omarchy recommends"
	elog "  app-containers/crun   - the container runtime the models use"
}

src_install() {
	local target="/usr/share/${PN}"
	insinto "${target}"
	doins catalog.toml best.toml agent_local.py
	doins -r recipes runtimes reviews measurements
	exeinto "${target}"
	doexe omarchy-local-ai
	# The launcher stays beside its data and is symlinked into PATH, the
	# same layout upstream ships; -r keeps the link relative (pkgcheck
	# flags absolute symlinks as relocation hazards).
	dosym -r "/usr/share/${PN}/omarchy-local-ai" "/usr/bin/${PN}"

	newdoc docs/engine.md engine.md
	dodoc README.md
}
