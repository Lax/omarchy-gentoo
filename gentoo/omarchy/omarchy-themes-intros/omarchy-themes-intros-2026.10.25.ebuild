# arch-pkgver: 2026.10.25
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Ported from pkgbuilds/omarchy-themes-intros. The Arch recipe pins a git
# commit; here that pin becomes the codeload tarball of the same commit, so
# the content is identical and Manifest-verifiable. Versioned by the date
# of the last commit that touched an intro, like upstream.
EAPI=8

DESCRIPTION="Background intro videos for the Omarchy themes"
HOMEPAGE="https://github.com/omacom/omarchy"
_COMMIT=a1ea6096d0bd88bd61ed871fc35628cd56e8bb72
SRC_URI="https://github.com/omacom/omarchy/archive/${_COMMIT}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/omarchy-${_COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

# Data-only package: the videos are consumed by the theme background
# switcher; nothing here depends on a specific viewer.

src_install() {
	local intros
	for intros in themes/*/backgrounds/intros; do
		[[ -d "${intros}" ]] || continue
		insinto "/usr/share/omarchy/${intros}"
		doins -r "${intros}"/. || die
	done
}
