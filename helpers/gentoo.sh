# Shared helpers for the Gentoo overlay tooling (bin/scaffold-ebuild,
# bin/sync-gentoo, bin/ai-port). Source after setting BUILD_ROOT, like
# helpers/paths.sh.
#
# Keeping every Arch->Gentoo conversion rule in this one file is what lets
# the scaffolder, the sync tool and the agent tooling agree on versions,
# keywords and dependency mappings.

DEPS_MAP="${DEPS_MAP:-$BUILD_ROOT/helpers/gentoo-deps.map}"
PACKAGES_TSV="${PACKAGES_TSV:-$BUILD_ROOT/helpers/gentoo-packages.tsv}"

# Arch license string -> Gentoo LICENSE token. Anything LicenseRef-*, "custom"
# or otherwise unrecognized maps to all-rights-reserved. Tokens the Gentoo
# tree does not ship are mapped to its nearest existing token, with the
# upstream truth kept in a comment in the ebuild.
license_map() {
	local raw="$1" out=""
	local entry
	# Split on any whitespace inside the Arch array value.
	for entry in $raw; do
		entry=${entry%,} # tolerate trailing commas inside Arch arrays
		case "$entry" in
		custom:OFL | OFL | OFL-1.1 | OFL-1.1-no-RFN)
			out+="OFL-1.1 "
			;;
		custom | custom:* | EULA | LicenseRef-*)
			out+="all-rights-reserved "
			;;
		Apache)
			out+="Apache-2.0 "
			;;
		GPL3 | 'GPL' | 'GPL License Version 3.0')
			out+="GPL-3 "
			;;
		AGPL3)
			out+="AGPL-3 "
			;;
		'GPL-3.0-only' | 'GPL-3')
			out+="GPL-3 "
			;;
		'GPL-3.0-or-later' | 'GPL-3+')
			out+="GPL-3+ "
			;;
		'BSD-3-Clause' | 'BSD')
			out+="BSD "
			;;
		LicenseRef-WHENCE | LicenseRef-cirrus)
			out+="linux-firmware "
			;;
		*)
			out+="$entry "
			;;
		esac
	done
	# De-duplicate while preserving order (LICENSE="MIT MIT" is noise).
	local seen="" token deduped=""
	for token in $out; do
		[[ " $seen " == *" $token "* ]] && continue
		seen+=" $token"
		deduped+="$token "
	done
	echo "${deduped% }"
}

# Arch arch=() -> Gentoo KEYWORDS. Everything starts unstable (~) per overlay
# convention; stable keywords would be a deliberate later decision.
keywords_for_arches() {
	local arches="$1" out=""
	case " $arches " in
	*" any "*)
		echo "~amd64 ~arm64"
		return
		;;
	esac
	[[ " $arches " == *" x86_64 "* ]] && out+=" ~amd64"
	[[ " $arches " == *" aarch64 "* ]] && out+=" ~arm64"
	echo "${out# }"
}

# Map one Arch dependency atom to a Gentoo atom. Prints nothing for DROP,
# prints "MANUAL:<note>" (caller warns) when there is no mapping. Lookups use
# $NF because the map files are column-aligned with runs of tabs between the
# key and the value.
map_dep() {
	local dep="$1"
	dep=${dep%%:*} # strip Arch version operators for the lookup key first...
	local hit
	hit=$(awk -F'\t' -v key="$dep" '$1 == key { print $NF; exit }' "$DEPS_MAP")
	if [[ -n "$hit" ]]; then
		echo "$hit"
		return
	fi
	# ...then try the full entry (versioned rows like "nodejs>=22" live in the
	# map verbatim so their Gentoo-side constraint stays explicit).
	awk -F'\t' -v key="$1" '$1 == key { print $NF; exit }' "$DEPS_MAP"
}

gentoo_location() {
	local package="$1"
	awk -F'\t' -v key="$package" \
		'$1 == key { print $2 "/" $3; exit }' "$PACKAGES_TSV"
}

# Gentoo version from an Arch pkgver(+epoch): epochs are dropped (the overlay
# has no history that needs one), dot-components that start with a letter are
# folded to _<letters> (Gentoo suffix syntax) and any remaining characters
# Gentoo cannot parse become _. pkgrel never applies to ebuilds.
gentoo_version() {
	local version="$1"
	version=${version#*:} # epoch
	printf '%s' "$version" |
		sed -E 's/\.([A-Za-z][A-Za-z0-9]*)/_\1/g' |
		tr -c 'A-Za-z0-9+._\n' '_' |
		tr -d '\n'
}

gentoo_arch_keyword() {
	case "$1" in
	x86_64) echo amd64 ;;
	aarch64) echo arm64 ;;
	*) echo "$1" ;;
	esac
}
