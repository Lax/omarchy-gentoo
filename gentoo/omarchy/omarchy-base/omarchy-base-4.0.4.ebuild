# arch-pkgver: 4.0.4
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# The package set upstream's ISO installs by default: basecamp/omarchy
# v4.0.4 ships it as a plain list (install/omarchy-base.packages), not a
# package, so this meta maps it 1:1 onto ::gentoo and this overlay. Entries
# that cannot be provided are dropped, not guessed — see the omission list
# at the bottom.
#
# Non-trivial mappings (arch name -> atom):
#   bluez-utils -> net-wireless/bluez          (tools live in bluez here)
#   dotnet-runtime -> dev-dotnet/dotnet-sdk    (closest ::gentoo atom)
#   fcitx5 -> app-i18n/fcitx                   (fcitx5 renamed to fcitx)
#   fcitx5-gtk -> app-i18n/fcitx-gtk
#   fcitx5-qt -> app-i18n/fcitx-qt
#   gnome-themes-extra -> x11-themes/gnome-themes-standard
#   gvfs-mtp/nfs/smb -> gnome-base/gvfs[mtp,nfs,samba]
#   libreoffice-fresh -> app-office/libreoffice
#   lua51 -> dev-lang/lua:5.1
#   mariadb-libs -> dev-db/mariadb-connector-c
#   noto-fonts{,-cjk,-emoji} -> media-fonts/noto{,-cjk,-emoji}
#   nvim -> app-editors/neovim
#   postgresql-libs -> dev-db/postgresql
#   python-gobject -> dev-python/pygobject
#   python-poetry-core -> dev-python/poetry-core
#   qt6-imageformats -> dev-qt/qtimageformats
#   tesseract-data-eng -> app-text/tessdata_fast
#   woff2-font-awesome -> media-fonts/fontawesome
#   gum, hyprland, localsend, mise-bin, quickshell, tensaku, tobi-try,
#     ttfx, ttf-ia-writer, ttf-jetbrains-mono-nerd-basic, ufw-docker,
#     xdg-terminal-exec -> this overlay (see helpers/gentoo-packages.tsv)
EAPI=8

DESCRIPTION="The Omarchy full-install package set (meta package)"
HOMEPAGE="https://github.com/basecamp/omarchy"

LICENSE="MIT"
S="${WORKDIR}"
SLOT="0"
# The set is verified on amd64 only; several ::gentoo members are not
# keyworded for arm64 yet.
KEYWORDS="~amd64"

RDEPEND="
	omarchy/omarchy
	app-admin/system-config-printer
	app-arch/unzip
	app-containers/docker-buildx
	app-containers/docker-compose
	app-crypt/libsecret
	app-misc/ddcutil
	app-misc/fastfetch
	app-misc/tmux
	app-misc/tzupdate
	app-shells/bash-completion
	app-shells/fzf
	app-shells/starship
	app-shells/zoxide
	app-text/evince
	app-text/tesseract
	app-text/xournalpp
	dev-lang/ruby
	dev-lua/luarocks
	dev-python/nautilus-python
	dev-util/tree-sitter-cli
	gnome-base/gnome-keyring
	gnome-base/nautilus
	gnome-extra/sushi
	gui-apps/foot
	gui-apps/grim
	gui-apps/slurp
	gui-apps/uwsm
	gui-apps/wl-clipboard
	kde-apps/kdenlive
	media-gfx/imv
	media-gfx/pinta
	media-gfx/qrencode
	media-gfx/zbar
	media-libs/fontconfig
	media-sound/alsa-utils
	media-video/ffmpegthumbnailer
	media-video/mpv
	media-video/obs-studio
	media-video/wireplumber
	net-firewall/ufw
	net-misc/inetutils
	net-misc/networkmanager
	net-misc/socat
	net-misc/whois
	net-misc/yt-dlp
	net-print/cups
	net-print/cups-filters
	net-print/cups-pk-helper
	net-wireless/bluez
	net-wireless/bluez-tools
	net-wireless/wireless-regdb
	sys-apps/bat
	sys-apps/bolt
	sys-apps/eza
	sys-apps/fakeroot
	sys-apps/fd
	sys-apps/inxi
	sys-apps/less
	sys-apps/man-db
	sys-apps/plocate
	sys-apps/ripgrep
	sys-apps/xdg-desktop-portal-gtk
	sys-auth/nss-mdns
	sys-boot/plymouth
	sys-fs/dosfstools
	sys-fs/exfatprogs
	sys-fs/inotify-tools
	sys-fs/udiskie
	sys-power/power-profiles-daemon
	sys-process/btop
	www-client/chromium
	app-containers/docker
	app-editors/neovim
	app-i18n/fcitx
	app-i18n/fcitx-gtk
	app-i18n/fcitx-qt
	app-misc/jq
	app-misc/ttfx
	app-office/libreoffice
	app-shells/gum
	app-text/tessdata_fast
	dev-db/mariadb-connector-c
	dev-db/postgresql
	dev-dotnet/dotnet-sdk
	dev-lang/lua:5.1
	dev-libs/libyaml
	dev-python/poetry-core
	dev-python/pygobject
	dev-qt/qtimageformats
	dev-util/mise-bin
	dev-util/try
	dev-vcs/git
	gnome-base/gvfs[mtp]
	gnome-base/gvfs[nfs]
	gnome-base/gvfs[samba]
	gui-apps/quickshell
	gui-apps/tensaku
	gui-wm/hyprland
	llvm-core/clang
	llvm-core/llvm
	media-fonts/fontawesome
	media-fonts/ia-writer
	media-fonts/jetbrains-mono-nerd-basic
	media-fonts/noto
	media-fonts/noto-cjk
	media-fonts/noto-emoji
	media-gfx/imagemagick
	net-dns/avahi
	net-firewall/ufw-docker
	net-misc/localsend-bin
	net-wireless/bluez
	sys-apps/gnome-disk-utility
	x11-misc/sddm
	x11-misc/xdg-terminal-exec
	x11-themes/gnome-themes-standard
"

# Dropped from upstream's list, with reasons:
#   aether: Omarchy in-house tool, no ::gentoo package; port pending
#   asdcontrol: Omarchy in-house tool, no ::gentoo package; port pending
#   brightnessctl: removed from ::gentoo (2026 tree); port pending
#   cliamp: Omarchy in-house tool, no ::gentoo package; port pending
#   dua-cli: removed from ::gentoo (2026 tree); port pending
#   expac: Arch pacman helper; not applicable under portage
#   gpu-screen-recorder: removed from ::gentoo (2026 tree); port pending
#   herdr: Omarchy in-house tool, no ::gentoo package; port pending
#   hyprland-guiutils: removed from ::gentoo (2026 tree); port pending
#   hyprland-preview-share-picker: removed from ::gentoo (2026 tree); port pending
#   hyprpicker: removed from ::gentoo (2026 tree); port pending
#   hyprsunset: removed from ::gentoo (2026 tree); port pending
#   kernel-modules-hook: removed from ::gentoo (2026 tree); port pending
#   lazydocker: removed from ::gentoo (2026 tree); port pending
#   lazygit: removed from ::gentoo (2026 tree); port pending
#   libvips: removed from ::gentoo (2026 tree); port pending
#   moonlight-qt: removed from ::gentoo (2026 tree); port pending
#   mpv-mpris: removed from ::gentoo (2026 tree); port pending
#   obsidian: upstream publishes an aarch64 build only
#   omacalc: Omarchy in-house tool, no ::gentoo package; port pending
#   omacut: Omarchy in-house tool, no ::gentoo package; port pending
#   omawrite: Omarchy in-house tool, no ::gentoo package; port pending
#   omarchy-nvim: blocked, see helpers/gentoo-skip.tsv
#   pacman-contrib: Arch pacman tooling; the omarchy core ships the portage equivalents
#   pamixer: removed from ::gentoo (2026 tree); port pending
#   qemu-user-static-binfmt: upstream build is aarch64-only
#   tldr: removed from ::gentoo (2026 tree); port pending
#   usage: Omarchy in-house tool, no ::gentoo package; port pending
#   wtype: removed from ::gentoo (2026 tree); port pending
#   xdg-desktop-portal-hyprland: removed from ::gentoo (2026 tree); the omarchy core carries this dependency
#   yaru-icon-theme: removed from ::gentoo (2026 tree); port pending
#   yay: Arch AUR helper; the omarchy core ships the portage equivalents
