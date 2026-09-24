# arch-pkgver: 8.12.38_25.BETA
# Ported from pkgbuilds/1password-beta; twin of app-admin/1password on the
# beta channel. Arch's pkgver "8.12.38_25.BETA" is not a PMS version string;
# the ebuild filename uses 8.12.38.25_beta while the marker keeps upstream's
# exact version for the drift checker.
EAPI=8

inherit desktop

DESCRIPTION="Password manager and secure wallet"
HOMEPAGE="https://1password.com"
_tarver="8.12.38-25.BETA"
SRC_URI="
	amd64? ( https://downloads.1password.com/linux/tar/beta/x86_64/1password-${_tarver}.x64.tar.gz -> ${P}-x64.tar.gz )
	arm64? ( https://downloads.1password.com/linux/tar/beta/aarch64/1password-${_tarver}.arm64.tar.gz -> ${P}-arm64.tar.gz )
"

S="${WORKDIR}/1password-${_tarver}.x64"
LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

RDEPEND="
	acct-group/onepassword
	dev-libs/nss
	x11-libs/gtk+:3
	x11-misc/xdg-utils
	x11-themes/hicolor-icon-theme
"
RESTRICT="strip mirror"

if [[ ${ARCH} == arm64 ]]; then
	S="${WORKDIR}/1password-${_tarver}.arm64"
fi

render_polkit_policy() {
	sed "s|\${POLICY_OWNERS}|${POLICY_OWNERS}|g" \
		com.1password.1Password.policy.tpl >com.1password.1Password.policy ||
		die "could not render polkit policy"
	grep -q '${' com.1password.1Password.policy &&
		die "unsubstituted variable left in polkit policy"
	return 0
}

src_install() {
	local resolution
	for resolution in 32x32 64x64 256x256 512x512; do
		insinto "/usr/share/icons/hicolor/${resolution}/apps"
		doins "resources/icons/hicolor/${resolution}/apps/1password.png"
	done

	sed -i 's|^Exec=.*|Exec=/opt/1Password/1password --force-device-scale-factor=1 %U|' \
		resources/com.onepassword.OnePassword.desktop || die
	newmenu resources/com.onepassword.OnePassword.desktop 1password-beta.desktop

	local policy_owners
	policy_owners="$(
		cut -d: -f1,3 /etc/passwd | grep -E ':[0-9]{4}$' | cut -d: -f1 |
			head -n 10 | sed 's/^/unix-user:/' | tr '\n' ' '
	)" || die
	POLICY_OWNERS="${policy_owners}" render_polkit_policy
	insinto /usr/share/polkit-1/actions
	doins com.1password.1Password.policy

	docinto examples
	dodoc resources/custom_allowed_browsers

	dodir /opt/1Password
	cp -a . "${ED}/opt/1Password/" || die

	rm -f "${ED}/opt/1Password/com.1password.1Password.policy" \
		"${ED}/opt/1Password/com.1password.1Password.policy.tpl" \
		"${ED}/opt/1Password/install_biometrics_policy.sh" || die
	rm -r "${ED}/opt/1Password/resources/icons" || die
	rm -f "${ED}/opt/1Password/resources/com.onepassword.OnePassword.desktop" \
		"${ED}/opt/1Password/resources/custom_allowed_browsers" || die

	fperms 4755 /opt/1Password/chrome-sandbox

	dosym -r /opt/1Password/1password /usr/bin/1password
}

pkg_postinst() {
	local helper="${EROOT}/opt/1Password/1Password-BrowserSupport"
	if [[ -e "${helper}" ]]; then
		chgrp onepassword "${helper}" ||
			ewarn "could not chgrp ${helper}"
		chmod g+s "${helper}" ||
			ewarn "could not setgid ${helper}"
	fi

	elog "1Password beta ${_tarver} installs alongside nothing: like upstream it"
	elog "conflicts with stable 1password, so the two cannot be co-installed."
	elog "Browser integration: add your user to the onepassword group"
	elog "(gpasswd -a <user> onepassword) ONLY if you understand the security"
	elog "implications - it grants the browser helper access to the app."
}
