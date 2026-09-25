#!/usr/bin/env python3
"""Regenerate every brand asset in this directory.

The mark is built as shape x coloring. The shape is fixed: omarchy's bracket
ring (sources/omarchy-icon-traced.svg, traced with potrace from
omacom/omarchy@quattro icon.png) framing the official Gentoo signet g
(sources/gentoo-signet.svg), whose four path layers (back, mid, eye, front)
are the paintable regions. The coloring is a pluggable strategy -- see
COLORINGS -- selected with MARK_COLORING (default: bands4) and previewed side
by side in colorings.svg:

  bands4           the omarchy-gentoo 4-step band ladder across the g
                   (default: the frame stays omarchy green, the g climbs
                   from pale-green shine to gentoo purple)
  flat             quattro-style flat blocks: green frame, violet body,
                   deeper rim layers, pale-green eye
  oma5             omarchy's official 5-green band stack across the g
  field            one continuous band field across frame and g
  signet-official  the signet's own gradient transforms with stops re-laid
                   onto the unified palette (soft 3-D)

The wordmark is JetBrains Mono Bold, set lowercase as "omarchy on gentoo"
(display name; the repo slug stays omarchy-gentoo). Following
omacom/omarchy's own asset management, the canonical trio lives here:
logo.svg (monochrome wordmark), logo.txt (its ASCII twin) and icon.png
(300x300 raster of the mark).

Usage: MARK_COLORING=flat python3 generate.py
  needs fonttools + JetBrains Mono Nerd Font (wordmark paths),
  rsvg-convert (PNG exports) and ImageMagick (logo.txt sampling).
"""
import os
import re
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
BOLD = "/usr/share/fonts/jetbrains-mono-nerd/JetBrainsMonoNerdFont-Bold.ttf"
REG = "/usr/share/fonts/jetbrains-mono-nerd/JetBrainsMonoNerdFont-Regular.ttf"

TILE_BG = "#1a1b26"   # tokyo night background
PAGE_BG = "#16161e"   # social preview page background
GREEN = "#9ece6a"     # omarchy green (bracket frame)

from fontTools.ttLib import TTFont
from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen

_fonts = {}


def font(path):
    if path not in _fonts:
        f = TTFont(path)
        _fonts[path] = (f, f["head"].unitsPerEm, f.getBestCmap(), f.getGlyphSet(), f["hmtx"])
    return _fonts[path]


def text_runs(font_path, runs, size, x=0.0, y=0.0):
    """Lay out [(text, fill), ...] at baseline y; return (svg paths, end x)."""
    f, upm, cmap, gs, hmtx = font(font_path)
    s = size / upm
    cx = x
    out = []
    for text, fill in runs:
        parts = []
        for ch in text:
            g = cmap[ord(ch)]
            pen = SVGPathPen(gs)
            gs[g].draw(TransformPen(pen, (s, 0, 0, -s, cx, y)))
            d = pen.getCommands()
            if d:
                parts.append(d)
            cx += hmtx[g][0] * s
        out.append(f'<path fill="{fill}" d="{" ".join(parts)}"/>')
    return "".join(out), cx


def text_ink_box(font_path, text, size):
    """Ink bbox (x0, y0_from_top, w, h) of text laid out at origin baseline 0."""
    f, upm, cmap, gs, hmtx = font(font_path)
    s = size / upm
    cx = 0.0
    xmin = ymin = 1e9
    xmax = ymax = -1e9
    for ch in text:
        g = cmap[ord(ch)]
        bp = BoundsPen(gs)
        gs[g].draw(bp)
        if bp.bounds:
            gx0, gy0, gx1, gy1 = bp.bounds
            xmin, xmax = min(xmin, cx + gx0 * s), max(xmax, cx + gx1 * s)
            ymin, ymax = min(ymin, -gy1 * s), max(ymax, -gy0 * s)
        cx += hmtx[g][0] * s
    return xmin, ymin, xmax - xmin, ymax - ymin


# ---- upstream sources: the fixed shape --------------------------------------
with open(os.path.join(HERE, "sources", "gentoo-signet.svg")) as fh:
    _sig = fh.read()
with open(os.path.join(HERE, "sources", "omarchy-icon-traced.svg")) as fh:
    _traced = fh.read()

SIGNET_PATHS = {
    role: re.search(r'id="%s"[^>]*\bd="([^"]+)"' % pid, _sig).group(1)
    for role, pid in (("back", "path2973"), ("mid", "path2975"),
                      ("eye", "path4976"), ("front", "path2977"))
}
_bracket_group = re.search(r"<g transform=.*?</g>", _traced, re.S).group(0).replace(
    'fill="#000000" ', '')

# Mark geometry in the 800x800 tile space: bracket ring near full bleed,
# signet g (400-space) centered inside it.
_BRACKET_INSET = 34
_GSCALE = 1.10
_G_TX = (800 - 400 * _GSCALE) / 2
_G_TY = (800 - 400 * _GSCALE) / 2 + 6

# The g's ink extent in its own 400-space; band gradients key off this.
_SIG_Y0, _SIG_Y1 = 8, 397

# ---- pluggable colorings ----------------------------------------------------
BANDS4 = [(0.0, "#daecc6"), (0.263, "#daecc6"), (0.263, "#9ece6a"), (0.5, "#9ece6a"),
          (0.5, "#8e77c2"), (0.76, "#8e77c2"), (0.76, "#54487a"), (1.0, "#54487a")]
BANDS4_DEEP = [(0.0, "#9ece6a"), (0.263, "#8e77c2"), (0.5, "#54487a"),
               (0.76, "#3b3158"), (1.0, "#3b3158")]
OMA5 = [(0.0, "#daecc6"), (0.263, "#daecc6"), (0.263, "#bbdd97"), (0.368, "#bbdd97"),
        (0.368, "#9ece6a"), (0.579, "#9ece6a"), (0.579, "#678549"),
        (0.737, "#678549"), (0.737, "#39482e"), (1.0, "#39482e")]


def _band_grad(gid, stops, y0, y1):
    st = "".join(f'<stop offset="{o:.3f}" stop-color="{c}"/>' for o, c in stops)
    return (f'<linearGradient id="{gid}" x1="0" y1="{y0}" x2="0" y2="{y1}" '
            f'gradientUnits="userSpaceOnUse">{st}</linearGradient>')


def _official_defs():
    """The signet's own gradient transforms, stops re-laid on the palette."""
    defs = re.search(r"<defs>.*</defs>", _sig, re.S).group(0)
    stops = {
        "_Linear1": [(0.00, "#54487a"), (0.40, "#54487a"), (1.00, "#3b3158")],
        "_Linear2": [(0.00, "#8e77c2"), (0.40, "#8e77c2"), (0.70, "#54487a"), (1.00, "#3b3158")],
        "_Radial3": [(0.00, "#daecc6"), (0.45, "#daecc6"), (0.80, "#8e77c2"), (1.00, "#3b3158")],
        "_Radial4": [(0.00, "#daecc6"), (0.18, "#a795d6"), (0.45, "#8e77c2"),
                     (0.75, "#54487a"), (1.00, "#3b3158")],
    }
    for gid, sl in stops.items():
        block = re.search(
            r'<(?:linear|radial)Gradient id="%s".*?</(?:linear|radial)Gradient>' % re.escape(gid),
            defs, re.S).group(0)
        st = "".join(f'<stop offset="{o:.2f}" stop-color="{c}" stop-opacity="1"/>' for o, c in sl)
        stripped = re.sub(r"<stop .*?/>", "", block, flags=re.S)
        new = stripped.replace("</linearGradient>", st + "</linearGradient>") \
                      .replace("</radialGradient>", st + "</radialGradient>")
        defs = defs.replace(block, new)
    return defs


# Each strategy returns (svg defs fragment, fills per paintable region).
# Layer fills that differ from the front's keep the signet's layered seams
# visible; the eye is always omarchy's pale green light.
COLORINGS = {
    "flat": lambda: ("", {"front": "#8e77c2", "mid": "#54487a", "back": "#3b3158",
                          "eye": "#daecc6", "bracket": GREEN}),
    "bands4": lambda: (
        _band_grad("b4F", BANDS4, _SIG_Y0, _SIG_Y1)
        + _band_grad("b4M", BANDS4, _SIG_Y0 - 60, _SIG_Y1 - 60)
        + _band_grad("b4B", BANDS4_DEEP, _SIG_Y0 - 60, _SIG_Y1 - 60),
        {"front": "url(#b4F)", "mid": "url(#b4M)", "back": "url(#b4B)",
         "eye": "#daecc6", "bracket": GREEN}),
    "oma5": lambda: (
        _band_grad("o5F", OMA5, _SIG_Y0, _SIG_Y1)
        + _band_grad("o5M", OMA5, _SIG_Y0 - 60, _SIG_Y1 - 60),
        {"front": "url(#o5F)", "mid": "url(#o5M)", "back": "url(#o5M)",
         "eye": "#daecc6", "bracket": GREEN}),
    "field": lambda: (
        _band_grad("fdG", BANDS4, 0, 800),
        {"front": "url(#fdG)", "mid": "url(#fdG)", "back": "url(#fdG)",
         "eye": "#daecc6", "bracket": "url(#fdG)"}),
    "signet-official": lambda: (
        _official_defs(),
        {"front": "url(#_Radial4)", "mid": "url(#_Linear2)",
         "back": "url(#_Linear1)", "eye": "url(#_Radial3)", "bracket": GREEN}),
}

COLORING = os.environ.get("MARK_COLORING", "bands4")


def _mark_coloring():
    return COLORINGS[COLORING]()


# ---- mark assembly ----------------------------------------------------------
def mark_defs():
    return _mark_coloring()[0]


def mark_body(tile=True):
    fills = _mark_coloring()[1]
    bs = (800 - 2 * _BRACKET_INSET) / 300  # traced group already carries scale(0.1)
    bracket = (f'<g transform="translate({_BRACKET_INSET},{_BRACKET_INSET}) scale({bs:.5f})" '
               f'fill="{fills["bracket"]}" fill-rule="evenodd">{_bracket_group}</g>')
    g = (f'<g transform="translate({_G_TX:.1f},{_G_TY:.1f}) scale({_GSCALE})" fill-rule="evenodd">'
         f'<path d="{SIGNET_PATHS["back"]}" fill="{fills["back"]}"/>'
         f'<path d="{SIGNET_PATHS["mid"]}" fill="{fills["mid"]}"/>'
         f'<path d="{SIGNET_PATHS["eye"]}" fill="{fills["eye"]}"/>'
         f'<path d="{SIGNET_PATHS["front"]}" fill="{fills["front"]}"/></g>')
    bg = f'<rect width="800" height="800" rx="136" fill="{TILE_BG}"/>' if tile else ""
    return bg + bracket + g


def mark_tile():
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 800">'
            f'{mark_defs()}{mark_body()}</svg>')


def write(name, content):
    with open(os.path.join(HERE, name), "w") as fh:
        fh.write(content)


# ---- mark assets ------------------------------------------------------------
write("omarchy-gentoo-mark.svg", mark_tile())
write("omarchy-gentoo-glyph.svg",
      f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 800">'
      f'{mark_defs()}{mark_body(tile=False)}</svg>')

# colorings.svg: every strategy on the same shape, the mark's design space.
cells = []
for i, name in enumerate(COLORINGS):
    saved = COLORING
    globals()["COLORING"] = name
    cells.append(f'<g transform="translate({20 + i * 380},60) scale(0.45)">'
                 f'{mark_defs()}{mark_body()}</g>')
    globals()["COLORING"] = saved
    cells.append(f'<text x="{20 + i * 380 + 180}" y="{40}" font-size="26" '
                 f'text-anchor="middle" fill="#8b91a5">{name}</text>')
write("colorings.svg",
      f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {20 + len(COLORINGS) * 380} 420" '
      f'width="{20 + len(COLORINGS) * 380}" height="420">'
      f'<rect width="100%" height="100%" fill="{PAGE_BG}"/>{"".join(cells)}</svg>')

# ---- lockups ----------------------------------------------------------------
def lockup(dark=True):
    name_g = "#9ece6a" if dark else "#4d7a1a"
    name_p = "#8e77c2" if dark else "#54487a"
    name_o = "#8b91a5" if dark else "#57606a"
    tag = "#8b91a5" if dark else "#57606a"
    W, H, t = 1860, 480, 400
    word, _ = text_runs(BOLD, [("omarchy", name_g), (" on ", name_o), ("gentoo", name_p)], 128, 490, 248)
    tagline, _ = text_runs(REG, [("Omarchy packages for Gentoo Linux", tag)], 46, 494, 342)
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}">'
            f'<g transform="translate(30,30) scale({t / 800})">{mark_defs()}{mark_body()}</g>'
            f'{word}{tagline}</svg>')


write("omarchy-gentoo-lockup-dark.svg", lockup(True))
write("omarchy-gentoo-lockup-light.svg", lockup(False))

# ---- social preview 1280x640 -------------------------------------------------
W, H, t = 1280, 640, 380
txx, tyy = (W - t) / 2, 34
word, ww = text_runs(BOLD, [("omarchy", "#9ece6a"), (" on ", "#8b91a5"), ("gentoo", "#8e77c2")], 108)
tagline, tw = text_runs(REG, [("Omarchy packages for Gentoo Linux", "#8b91a5")], 42)
write("social-preview.svg",
      f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">'
      f'<rect width="{W}" height="{H}" fill="{PAGE_BG}"/>'
      f'<g transform="translate({txx},{tyy}) scale({t / 800})">{mark_defs()}{mark_body()}</g>'
      f'<g transform="translate({(W - ww) / 2:.1f},548)">{word}</g>'
      f'<g transform="translate({(W - tw) / 2:.1f},606)">{tagline}</g></svg>')

# ---- omarchy-style canonical trio -------------------------------------------
# logo.svg: monochrome wordmark, tight viewBox, fill #000 (recolor at will).
WM = "omarchy on gentoo"
wx0, wy0, ww_, wh_ = text_ink_box(BOLD, WM, 200)
pad = 8
write("logo.svg",
      f'<svg xmlns="http://www.w3.org/2000/svg" fill="none" '
      f'viewBox="{wx0 - pad:.0f} {wy0 - pad:.0f} {ww_ + 2 * pad:.0f} {wh_ + 2 * pad:.0f}" '
      f'width="{ww_ + 2 * pad:.0f}" height="{wh_ + 2 * pad:.0f}">'
      f'<g fill="#000">{text_runs(BOLD, [(WM, "#000")], 200, -wx0, 0)[0]}</g></svg>')

# icon.png: 300x300 raster of the mark, like omacom/omarchy's icon.png.
for w in (512, 128, 64, 32):
    subprocess.run(["rsvg-convert", "-w", str(w), "-h", str(w),
                    os.path.join(HERE, "omarchy-gentoo-mark.svg"),
                    "-o", os.path.join(HERE, f"omarchy-gentoo-mark-{w}.png")], check=True)
subprocess.run(["rsvg-convert", "-w", "300", "-h", "300",
                os.path.join(HERE, "omarchy-gentoo-mark.svg"),
                "-o", os.path.join(HERE, "icon.png")], check=True)
subprocess.run(["rsvg-convert", "-w", "1280", "-h", "640",
                os.path.join(HERE, "social-preview.svg"),
                "-o", os.path.join(HERE, "social-preview.png")], check=True)

# logo.txt: ASCII twin of the wordmark, two lines, half-block sampling.
COLS = 60
tmp_png = "/tmp/logo-wordmark.png"
lines = ["omarchy", "on gentoo"]
S = 200
lh = int(S * 1.45)
maxw = max(text_ink_box(BOLD, ln, S)[2] for ln in lines)
svg_lines = []
for i, ln in enumerate(lines):
    ix, iy, iw, ih = text_ink_box(BOLD, ln, S)
    svg_lines.append(text_runs(BOLD, [(ln, "#000")], S, -ix, lh * i - iy + S * 0.1)[0])
block_w, block_h = maxw + 4, lh * len(lines) + int(S * 0.1)
svg_lines_svg = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {block_w:.0f} {block_h}" '
                 f'width="{block_w:.0f}" height="{block_h:.0f}">{"".join(svg_lines)}</svg>')
with open("/tmp/logo-wordmark.svg", "w") as fh:
    fh.write(svg_lines_svg)
subprocess.run(["rsvg-convert", "-w", str(COLS * 12), "/tmp/logo-wordmark.svg",
                "-o", tmp_png], check=True)
sampling = subprocess.run(
    ["magick", tmp_png, "-alpha", "extract",
     "-resize", f"{COLS}x{int(block_h / block_w * COLS * 2)}!", "-threshold", "50%", "txt:-"],
    capture_output=True, text=True, check=True).stdout
cells = {}
for ln in sampling.splitlines()[1:]:
    m = re.match(r"(\d+),(\d+):.*?\((\d+)", ln)
    if m:
        cells[(int(m.group(2)), int(m.group(1)))] = int(m.group(3)) >= 128
rh = max(r for r, c in cells)
cw = max(c for r, c in cells)
rows = []
for r in range(0, rh, 2):
    row = []
    for c in range(cw + 1):
        top = cells.get((r, c), False)
        bot = cells.get((r + 1, c), False)
        row.append("█" if top and bot else "▀" if top else "▄" if bot else " ")
    rows.append("".join(row).rstrip())
while rows and not rows[0]:
    rows.pop(0)
while rows and not rows[-1]:
    rows.pop()
write("logo.txt", "\n".join(rows) + "\n")

print(f"brand assets regenerated in {HERE} (coloring: {COLORING})")
