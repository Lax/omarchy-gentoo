# arch-pkgver: 0.3.3
# Ported from pkgbuilds/ttfx.
EAPI=8

CRATES="
anstream@1.0.0
anstyle@1.0.14
anstyle-parse@1.0.0
anstyle-query@1.1.5
anstyle-wincon@3.0.11
bitflags@2.13.1
clap@4.6.6
clap_builder@4.6.6
clap_complete@4.6.9
clap_derive@4.6.4
clap_lex@1.1.0
colorchoice@1.0.5
errno@0.3.14
heck@0.5.0
is_terminal_polyfill@1.70.2
libc@0.2.189
linux-raw-sys@0.12.1
once_cell_polyfill@1.70.2
proc-macro2@1.0.107
quote@1.0.47
rustix@1.1.4
strsim@0.11.1
syn@3.0.3
terminal_size@0.4.4
unicode-ident@1.0.24
utf8parse@0.2.2
windows-link@0.2.1
windows-sys@0.61.2
"

inherit cargo

DESCRIPTION="Terminal text effects as a single static binary"
HOMEPAGE="https://github.com/omacom-io/ttfx"
SRC_URI="https://github.com/omacom-io/ttfx/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" ${CARGO_CRATE_URIS}"

S="${WORKDIR}/${P}"
LICENSE="MIT || ( Apache-2.0 MIT ) || ( Apache-2.0-with-LLVM-exception Apache-2.0 MIT ) ( || ( MIT Apache-2.0 ) ) Unicode-3.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

src_install() {
	cargo_src_install

	# Completions are rendered by the binary itself, like the Arch recipe.
	"$(cargo_target_dir)/ttfx" --print-completion bash > "${T}"/ttfx.bash || die
	"$(cargo_target_dir)/ttfx" --print-completion zsh > "${T}"/_ttfx || die
	dobashcomp "${T}"/ttfx.bash
	insinto /usr/share/zsh/site-functions
	doins "${T}"/_ttfx

	insinto /usr/share/licenses/${PN}
	doins LICENSE NOTICE

	dodoc README.md
}
