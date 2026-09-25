# arch-pkgver: 1.0.2
# Copyright 2026, omarchy-gentoo overlay team
# Distributed under the terms of the MIT license

# Ported from pkgbuilds/omarchy-meeting-recorder-bin. Upstream publishes an
# x86_64 build only. The release tarball carries the prebuilt binary (with
# whisper.cpp and sherpa-onnx already linked in), the desktop entry, the
# shared-mime XML and the quickshell bar widget.
EAPI=8

inherit desktop xdg

DESCRIPTION="Meeting Recorder for Omarchy: two-track recording with local transcription"
HOMEPAGE="https://github.com/jankeesvw/omarchy-meeting-recorder"
SRC_URI="https://github.com/jankeesvw/omarchy-meeting-recorder/releases/download/v${PV}/omarchy-meeting-recorder-${PV}-x86_64-linux.tar.gz"

S="${WORKDIR}/omarchy-meeting-recorder-${PV}"

LICENSE="MIT"
SLOT="0"
# Upstream arch=() is x86_64 only; there is no aarch64 release to mirror.
KEYWORDS="~amd64"

RESTRICT="strip mirror"

RDEPEND="
	dev-libs/glib
	gui-libs/gtk
	>=gui-libs/libadwaita-1.6
	media-libs/graphene
	media-libs/libpulse
	media-video/ffmpeg
	x11-libs/cairo
	x11-libs/pango
"

src_install() {
	dobin omarchy-meeting-recorder

	domenu data/omarchy-meeting-recorder.desktop
	insinto /usr/share/mime/packages
	doins data/omarchy-meeting-recorder.xml

	# The quickshell bar widget, to link into ~/.config/omarchy/plugins
	# (the app offers this on first run).
	insinto /usr/share/${PN}/plugin
	doins plugin/manifest.json plugin/Widget.qml

	einstalldocs
	docinto licenses
	dodoc LICENSE
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "Meeting Recorder is installed; open it from the launcher."
	elog
	elog "The first time you open it, it offers to put its widget in the bar"
	elog "(a live waveform while you record)."
	elog
	elog "Optional, per user, a floating window in ~/.config/hypr"
	elog "(Omarchy Quattro, Lua):"
	elog '  o.window("^com\\.jankeesvw\\.OmarchyMeetingRecorder$", { float = true })'
	elog '  o.window("^com\\.jankeesvw\\.OmarchyMeetingRecorder$", { size = { 480, 700 } })'
	elog '  o.window("^com\\.jankeesvw\\.OmarchyMeetingRecorder$", { center = true })'
	elog
	elog "The speech model (about 1.6 GB) is downloaded on first use, or taken"
	elog "from voxtype when it already has it."
}
