# arch-pkgver: 1.8.1
# Ported from pkgbuilds/tobi-try. Three scripts pinned to one upstream
# commit; the entry script's shebang is rewritten to the system ruby so a
# user's mise-managed ruby cannot shadow it.
EAPI=8

DESCRIPTION="Fresh directories for every vibe"
HOMEPAGE="https://github.com/tobi/try"
_COMMIT=d1bc484cc31a34db3d287550f4800e9a6e56bacd
SRC_URI="
	https://raw.githubusercontent.com/tobi/try/${_COMMIT}/try.rb -> try-${PV}.rb
	https://raw.githubusercontent.com/tobi/try/${_COMMIT}/lib/fuzzy.rb -> try-fuzzy-${PV}.rb
	https://raw.githubusercontent.com/tobi/try/${_COMMIT}/lib/tui.rb -> try-tui-${PV}.rb
"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="dev-lang/ruby"

src_prepare() {
	default
	# DISTDIR is read-only; the shebang rewrite happens on a copy.
	cp "${DISTDIR}/try-${PV}.rb" "${T}/" || die
	sed -i '1c#!/usr/bin/ruby' "${T}/try-${PV}.rb" || die
}

src_install() {
	exeinto /usr/libexec/try
	newexe "${T}/try-${PV}.rb" try.rb
	insinto /usr/libexec/try/lib
	newins "${DISTDIR}/try-fuzzy-${PV}.rb" fuzzy.rb
	newins "${DISTDIR}/try-tui-${PV}.rb" tui.rb
	dosym -r /usr/libexec/try/try.rb /usr/bin/try
}
