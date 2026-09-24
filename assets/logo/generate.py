#!/usr/bin/env python3
"""Regenerate every brand asset in this directory.

The mark is the lowercase 'g' of JetBrains Mono Bold -- the same typeface as
the wordmark, and Omarchy's own terminal font -- filled with hard horizontal
bands: Omarchy's Tokyo Night greens flowing into Gentoo purple. The wordmark
reads "omarchy on gentoo" (display name; the repo slug stays
omarchy-gentoo). Everything is baked to SVG paths so no viewer needs the
font installed.

Usage: python3 generate.py            (needs fonttools + JetBrains Mono Nerd
                                       Font for the SVGs, rsvg-convert for PNGs)
"""
import os
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
BOLD = "/usr/share/fonts/jetbrains-mono-nerd/JetBrainsMonoNerdFont-Bold.ttf"
REG = "/usr/share/fonts/jetbrains-mono-nerd/JetBrainsMonoNerdFont-Regular.ttf"

TILE_BG = "#1a1b26"   # tokyo night background
PAGE_BG = "#16161e"   # social preview page background

# omarchy greens (top) flowing into gentoo purples (bottom), hard bands like
# the omarchy oma-logo band gradient.
BANDS = [(0.000, "#daecc6"), (0.263, "#daecc6"),
         (0.263, "#9ece6a"), (0.500, "#9ece6a"),
         (0.500, "#8e77c2"), (0.760, "#8e77c2"),
         (0.760, "#54487a"), (1.000, "#54487a")]

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


_bf = font(BOLD)
_gs = _bf[3]
_cmap = _bf[2]
_bp = BoundsPen(_gs)
_gs[_cmap[ord("g")]].draw(_bp)
_gx0, _gy0, _gx1, _gy1 = _bp.bounds


def g_path(size, tx=0.0, ty=0.0):
    """Bold 'g' outline at `size` height, bbox top-left at (tx, ty)."""
    s = size / (_gy1 - _gy0)
    pen = SVGPathPen(_gs)
    _gs[_cmap[ord("g")]].draw(TransformPen(pen, (s, 0, 0, -s, tx - _gx0 * s, ty + _gy1 * s)))
    return pen.getCommands(), (_gx1 - _gx0) * s, size


SZ, GH = 800, 500
_d, _gw, _gh = g_path(GH)
_tx, _ty = (SZ - _gw) / 2, (SZ - _gh) / 2 - 6


def grad(gid, y0, y1):
    st = "".join(f'<stop offset="{o:.3f}" stop-color="{c}"/>' for o, c in BANDS)
    return (f'<linearGradient id="{gid}" x1="0" y1="{y0}" x2="0" y2="{y1}" '
            f'gradientUnits="userSpaceOnUse">{st}</linearGradient>')


def mark_tile(rx=136):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {SZ} {SZ}">'
            f'<defs>{grad("b", _ty, _ty + _gh)}</defs>'
            f'<rect width="{SZ}" height="{SZ}" rx="{rx}" fill="{TILE_BG}"/>'
            f'<path transform="translate({_tx:.1f},{_ty:.1f})" d="{_d}" fill="url(#b)"/></svg>')


def lockup(dark=True):
    name_g = "#9ece6a" if dark else "#4d7a1a"
    name_p = "#8e77c2" if dark else "#54487a"
    name_o = "#8b91a5" if dark else "#57606a"
    tag = "#8b91a5" if dark else "#57606a"
    W, H, t = 1860, 480, 400
    ts = t / SZ
    tr = int(t * 136 / 800)
    word, _ = text_runs(BOLD, [("omarchy", name_g), (" on ", name_o), ("gentoo", name_p)], 128, 490, 248)
    tagline, _ = text_runs(REG, [("Omarchy packages for Gentoo Linux", tag)], 46, 494, 342)
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}">'
            f'<defs>{grad("b", _ty * ts + 30, (_ty + _gh) * ts + 30)}</defs>'
            f'<rect x="30" y="30" width="{t}" height="{t}" rx="{tr}" fill="{TILE_BG}"/>'
            f'<path transform="translate({_tx * ts + 30},{_ty * ts + 30}) scale({ts})" d="{_d}" fill="url(#b)"/>'
            f'{word}{tagline}</svg>')


def social():
    W, H, t = 1280, 640, 380
    ts = t / SZ
    tr = int(t * 136 / 800)
    txx, tyy = (W - t) / 2, 34
    word, ww = text_runs(BOLD, [("omarchy", "#9ece6a"), (" on ", "#8b91a5"), ("gentoo", "#8e77c2")], 108)
    tagline, tw = text_runs(REG, [("Omarchy packages for Gentoo Linux", "#8b91a5")], 42)
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}">'
            f'<defs>{grad("b", tyy + _ty * ts, tyy + (_ty + _gh) * ts)}</defs>'
            f'<rect width="{W}" height="{H}" fill="{PAGE_BG}"/>'
            f'<rect x="{txx}" y="{tyy}" width="{t}" height="{t}" rx="{tr}" fill="{TILE_BG}"/>'
            f'<path transform="translate({txx + _tx * ts},{tyy + _ty * ts}) scale({ts})" d="{_d}" fill="url(#b)"/>'
            f'<g transform="translate({(W - ww) / 2:.1f},548)">{word}</g>'
            f'<g transform="translate({(W - tw) / 2:.1f},606)">{tagline}</g></svg>')


def write(name, content):
    with open(os.path.join(HERE, name), "w") as fh:
        fh.write(content)


write("omarchy-gentoo-mark.svg", mark_tile())
write("omarchy-gentoo-glyph.svg",
      f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {_gw:.0f} {_gh:.0f}">'
      f'<defs>{grad("b", 0, _gh)}</defs>'
      f'<path transform="translate({-_tx:.1f},{-_ty:.1f})" d="{_d}" fill="url(#b)"/></svg>')
write("omarchy-gentoo-lockup-dark.svg", lockup(True))
write("omarchy-gentoo-lockup-light.svg", lockup(False))
write("social-preview.svg", social())

for w in (512, 128, 64, 32):
    subprocess.run(["rsvg-convert", "-w", str(w), "-h", str(w),
                    os.path.join(HERE, "omarchy-gentoo-mark.svg"),
                    "-o", os.path.join(HERE, f"omarchy-gentoo-mark-{w}.png")], check=True)
subprocess.run(["rsvg-convert", "-w", "1280", "-h", "640",
                os.path.join(HERE, "social-preview.svg"),
                "-o", os.path.join(HERE, "social-preview.png")], check=True)
print("brand assets regenerated in", HERE)
