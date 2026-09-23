# Overlay-local system group for the NordVPN daemon and CLI, replacing the
# Arch package's sysusers line. GID is allocated dynamically.
EAPI=8

inherit acct-group

DESCRIPTION="Group for the NordVPN daemon"
SLOT="0"
