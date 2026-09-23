# arch-pkgver: 0.155.1
# Ported from pkgbuilds/openai-codex-bin. Static musl binaries; the CLI
# generates its own shell completions at build time.
EAPI=8

inherit shell-completion

DESCRIPTION="OpenAI Codex CLI"
HOMEPAGE="https://github.com/openai/codex"
SRC_URI="
	amd64? (
		https://github.com/openai/codex/releases/download/rust-v${PV}/codex-x86_64-unknown-linux-musl.tar.gz
		https://github.com/openai/codex/releases/download/rust-v${PV}/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz
	)
	arm64? (
		https://github.com/openai/codex/releases/download/rust-v${PV}/codex-aarch64-unknown-linux-musl.tar.gz
		https://github.com/openai/codex/releases/download/rust-v${PV}/codex-code-mode-host-aarch64-unknown-linux-musl.tar.gz
	)
"

S="${WORKDIR}"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RESTRICT="strip mirror"

src_install() {
	local dist
	case "${ARCH}" in
		amd64) dist=x86_64 ;;
		arm64) dist=aarch64 ;;
		*) die "unsupported ARCH ${ARCH}" ;;
	esac

	newbin "codex-${dist}-unknown-linux-musl" codex
	newbin "codex-code-mode-host-${dist}-unknown-linux-musl" codex-code-mode-host

	# Completion generation needs the installed binary name to match.
	local completions="${T}/completions"
	mkdir -p "${completions}" || die
	local shell
	for shell in bash zsh fish; do
		"${ED}/usr/bin/codex" completion "${shell}" \
			>"${completions}/codex.${shell}" || die
	done
	"${ED}/usr/bin/codex" completion elvish >"${completions}/codex.elvish" || die
	"${ED}/usr/bin/codex" completion powershell >"${completions}/codex.ps1" || die

	newbashcomp "${completions}/codex.bash" codex
	newzshcomp "${completions}/codex.zsh" _codex
	newfishcomp "${completions}/codex.fish" codex.fish
	insinto /usr/share/elvish/lib
	newins "${completions}/codex.elvish" codex.elv
	insinto /usr/share/powershell/Completions
	newins "${completions}/codex.ps1" codex.ps1
}
