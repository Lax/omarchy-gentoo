# arch-pkgver: 1.0.0
# Ported from pkgbuilds/elsewhen.
EAPI=8

DESCRIPTION="World clock plugin for the Omarchy shell"
HOMEPAGE="https://github.com/omacom/elsewhen"
SRC_URI="https://github.com/omacom/elsewhen/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	app-misc/omarchy
	dev-lang/python
	gui-apps/quickshell
"

src_configure() { :; }
src_compile() { :; }

src_install() {
	local plugin=/usr/share/omarchy/shell/plugins/omacom.elsewhen

	# Upstream fails the pacman build when the release tree is incomplete;
	# keep the same guarantees, since a tree that installs cleanly but never
	# loads is the failure mode the checks exist for.
	[[ -f manifest.json ]] || die "release tree is missing manifest.json"
	grep -Eq '"id"[[:space:]]*:[[:space:]]*"omacom\.elsewhen"' manifest.json ||
		die "manifest.json does not declare the plugin id omacom.elsewhen"
	grep -Eq '"barWidget"[[:space:]]*:[[:space:]]*"Panel\.qml"' manifest.json ||
		die "manifest.json does not name Panel.qml as the bar widget entry point"
	[[ -f Panel.qml ]] || die "release tree is missing the entry point Panel.qml"

	# Explicit allow-list of runtime files, so tests/, .github/ and the rest
	# of the repository never reach the package. An unmatched glob stays
	# literal, fails the -f test, and dies — the release tree is incomplete.
	insinto "${plugin}"
	local file
	for file in manifest.json cities.json world.json worldclock-data.py *.qml *.js; do
		[[ -f ${file} ]] || die "release tree is missing ${file}"
		doins "${file}"
	done

	insinto /usr/share/licenses/${PF}
	doins LICENSE
	einstalldocs
}
