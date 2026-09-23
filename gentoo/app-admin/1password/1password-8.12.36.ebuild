# arch-pkgver: 8.12.36
# Ported from pkgbuilds/1password. Two deliberate Gentoo differences:
# - the onepassword group is an acct-group package (Arch: .install groupadd);
#   the setgid browser helper is handled in pkg_postinst;
# - the polkit policy is generated at build time from this machine's
#   /etc/passwd like the Arch recipe does, which is correct here precisely
#   because source-based installs run on the target machine.
EAPI=8

inherit desktop

DESCRIPTION="Password manager and secure wallet"
HOMEPAGE="https://1password.com"
SRC_URI="
	amd64? ( https://downloads.1password.com/linux/tar/stable/x86_64/1password-${PV}.x64.tar.gz )
	arm64? ( https://downloads.1password.com/linux/tar/stable/aarch64/1password-${PV}.arm64.tar.gz )
"

S="${WORKDIR}/1password-${PV}.x64"
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
	S="${WORKDIR}/1password-${PV}.arm64"
fi

# Render the policy template with POLICY_OWNERS substituted (the Arch recipe
# evals a heredoc; this is the same expansion without eval).
render_polkit_policy() {
	sed "s|\${POLICY_OWNERS}|${POLICY_OWNERS}|g" \
		com.1password.1Password.policy.tpl >com.1password.1Password.policy ||
		die "could not render polkit policy"
	# Fail loudly when the template uses a variable this function ignores.
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

	# 1Password reads the display scale itself, the way Electron apps do, and
	# comes up oversized next to every other window on a scaled monitor. Pin
	# it and let the compositor do the scaling.
	sed -i 's|^Exec=.*|Exec=/opt/1Password/1password --force-device-scale-factor=1 %U|' \
		resources/com.onepassword.OnePassword.desktop || die
	newmenu resources/com.onepassword.OnePassword.desktop 1password.desktop

	# System-unlock polkit policy, filled in with the first ten human users.
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

	# The whole tree into /opt with the tarball's own modes intact
	# (cp -a preserves the vendor's exec and setuid bits).
	dodir /opt/1Password
	cp -a . "${ED}/opt/1Password/" || die

	# Not installed by this package.
	rm -f "${ED}/opt/1Password/com.1password.1Password.policy" \
		"${ED}/opt/1Password/com.1password.1Password.policy.tpl" \
		"${ED}/opt/1Password/install_biometrics_policy.sh" || die
	rm -r "${ED}/opt/1Password/resources/icons" || die
	rm -f "${ED}/opt/1Password/resources/com.onepassword.OnePassword.desktop" \
		"${ED}/opt/1Password/resources/custom_allowed_browsers" || die

	# chrome-sandbox requires the setuid bit to be specifically set.
	fperms 4755 /opt/1Password/chrome-sandbox

	dosym -r /opt/1Password/1password /usr/bin/1password
}

pkg_postinst() {
	# Arch's .install sets the setgid bit on the browser helper for the
	# onepassword group; mirror that here, after the group exists.
	local helper="${EROOT}/opt/1Password/1Password-BrowserSupport"
	if [[ -e "${helper}" ]]; then
		chgrp onepassword "${helper}" ||
			ewarn "could not chgrp ${helper}"
		chmod g+s "${helper}" ||
			ewarn "could not setgid ${helper}"
	fi

	elog "Browser integration: add your user to the onepassword group"
	elog "(gpasswd -a <user> onepassword) ONLY if you understand the security"
	elog "implications - it grants the browser helper access to the app."
}
