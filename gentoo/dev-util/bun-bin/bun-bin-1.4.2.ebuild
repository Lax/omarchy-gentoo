# arch-pkgver: 1.4.2
# Ported from pkgbuilds/bun-bin. On amd64 both upstream variants (AVX2 and
# baseline) are installed-able; the build machine's CPU picks which one
# becomes bun, exactly like the Arch recipe (emerge on the target machine,
# which is the default source-based flow on Gentoo).
EAPI=8

inherit shell-completion

DESCRIPTION="All-in-one JavaScript runtime with bundler, transpiler and package manager"
HOMEPAGE="https://github.com/oven-sh/bun"
SRC_URI="
	amd64? (
		https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-x64.zip -> ${PN}-x64-${PV}.zip
		https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-x64-baseline.zip -> ${PN}-x64-baseline-${PV}.zip
	)
	arm64? ( https://github.com/oven-sh/bun/releases/download/bun-v${PV}/bun-linux-aarch64.zip -> ${PN}-aarch64-${PV}.zip )
"

S="${WORKDIR}"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="app-arch/unzip"
RESTRICT="strip mirror"

src_compile() {
	local variant
	if [[ ${ARCH} == amd64 ]]; then
		if grep -q avx2 /proc/cpuinfo; then
			variant=bun-linux-x64
		else
			variant=bun-linux-x64-baseline
		fi
	else
		variant=bun-linux-aarch64
	fi

	mkdir -p "${T}/completions" || die
	SHELL=zsh "./${variant}/bun" completions >"${T}/completions/bun.zsh" || die
	SHELL=bash "./${variant}/bun" completions >"${T}/completions/bun.bash" || die
	SHELL=fish "./${variant}/bun" completions >"${T}/completions/bun.fish" || die
}

src_install() {
	local variant
	if [[ ${ARCH} == amd64 ]]; then
		if grep -q avx2 /proc/cpuinfo; then
			variant=bun-linux-x64
		else
			variant=bun-linux-x64-baseline
		fi
	else
		variant=bun-linux-aarch64
	fi

	dobin "${variant}/bun"
	dosym -r /usr/bin/bun /usr/bin/bunx

	newzshcomp "${T}/completions/bun.zsh" _bun
	newbashcomp "${T}/completions/bun.bash" bun
	newfishcomp "${T}/completions/bun.fish" bun.fish
}
