# Overlay-local system group for the 1Password browser helper (setgid),
# replacing Arch's .install groupadd. GID is allocated dynamically.
EAPI=8

inherit acct-group

DESCRIPTION="Group for the 1Password browser integration helper"
SLOT="0"
