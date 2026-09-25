# Omarchy on Gentoo — name & brand

One name, one mark, defined once. Regenerate every asset here with
`python3 generate.py` (needs `fonttools`, JetBrains Mono Nerd Font,
`rsvg-convert`, and ImageMagick; SVG text is baked to paths so viewers need
no fonts).

## The name

The display name is **Omarchy on Gentoo** — an intentional echo of Ruby on
Rails, whose author DHH also started Omarchy. The repository slug stays
`omarchy-gentoo` (lowercase, hyphenated); slug and display name are two
layers of one brand, the way `rails/rails` is for Ruby on Rails.

| Context | Canonical form |
| --- | --- |
| Display name / wordmark | **Omarchy on Gentoo** (the wordmark sets it lowercase in mono, "on" in the neutral gray) |
| GitHub repository (slug) | `omarchy-gentoo` — stable; URLs, CI, and user configs depend on it |
| One-line description | **Omarchy packages for Gentoo Linux** |
| Portage repository on user machines | `omarchy` (so `emerge ::omarchy`, `emaint sync -r omarchy`) |
| Overlay branch (what Portage syncs) | `overlay` |
| CI bot identity | `omarchy-gentoo-ci` |

Rules:

- The name uses **on**, and never in reverse: "Gentoo on Omarchy" inverts
  the stack (Gentoo is the host). "For" belongs to the tagline's
  descriptive register; "on" belongs to the name.
- The slug is always lowercase and hyphenated: `omarchy-gentoo`. Never
  `OmarchyGentoo`, `omarchy_gentoo`, or `Omarchy-Gentoo`.
- "Omarchy" and "Gentoo" are capitalized when they stand alone as proper
  nouns in prose ("Omarchy packages for Gentoo Linux"); the wordmark and
  the slug stay lowercase.
- The Portage repository name is `omarchy` — short, because users type it
  (`emerge ::omarchy`). The `repo-name` in `gentoo/metadata/layout.conf`
  declares this; keep the two in sync.
- This is a community overlay: describe it as "an unofficial community
  overlay", never as official Omarchy or Gentoo tooling.

## The mark

Shape and coloring are deconstructed and recombined. The shape is fixed:
omarchy's interlocking bracket ring (traced from omacom/omarchy's `icon.png`,
quattro branch, via potrace — `sources/omarchy-icon-traced.svg`) framing the
official Gentoo signet **g** (gentoo.org artwork,
`sources/gentoo-signet.svg`, paths untouched), whose four path layers —
back, mid, eye, front — are the paintable regions. The coloring is a
pluggable strategy (`generate.py` → `COLORINGS`, switch with
`MARK_COLORING=<name> python3 generate.py`); all of them are previewed side
by side in `colorings.svg`:

| Strategy | Look |
| --- | --- |
| `bands4` *(default)* | the omarchy→gentoo 4-step band ladder (`#daecc6`/`#9ece6a`/`#8e77c2`/`#54487a`) stepped across the g — omarchy green frame, the g climbing from pale-green shine into gentoo purple |
| `flat` | quattro-style flat blocks — green frame, violet `#8e77c2` body, `#54487a` rim, `#3b3158` shadow, pale-green eye |
| `oma5` | omarchy's official 5-green band stack (`#daecc6`→`#39482e`) across the g |
| `field` | one continuous band field running through frame and g together |
| `signet-official` | the signet's own gradient transforms, stops re-laid on the palette (soft 3-D) |

Layer fills that differ from the front's keep the signet's layered seams
visible; the eye is always omarchy's pale green light on the g. The default
`bands4` reads as: **the omarchy green frame hands the g over to gentoo
purple, one hard step at a time.**

## Asset management

The canonical trio follows omacom/omarchy's own convention — one plainly
named file per medium, kept side by side:

| File | Use |
| --- | --- |
| `logo.svg` | the wordmark in the icon's brackets — `[ omarchy on gentoo ]`, monochrome `fill="#000"`, recolor at will |
| `logo.txt` | block-art `omarchy` (hand-set 4-row font) + plain-text `[ omarchy on gentoo ]` — 35 cols, TTY-safe `▄█▀` only |
| `icon.png` | 300×300 raster of the mark, drop-in anywhere omarchy's `icon.png` would go |

The full kit around them:

| File | Use |
| --- | --- |
| `omarchy-gentoo-mark.svg` | the icon: avatars, favicons, badges |
| `colorings.svg` | every coloring strategy on the same shape — the mark's design space |
| `omarchy-gentoo-mark-{512,128,64,32}.png` | raster icon exports |
| `omarchy-gentoo-lockup-dark.svg` / `-light.svg` | horizontal logo + tagline; use per background (README `<picture>` swaps them) |
| `omarchy-gentoo-glyph.svg` | bracket + g without the tile, transparent background |
| `social-preview.svg` / `.png` | GitHub repo social preview (1280×640; upload in repo settings → Social preview) |
| `sources/` | the upstream vectors the mark is built from; do not hand-edit |
| `generate.py` | regenerates everything above |

Trademark note: the Gentoo logo artwork and name are trademarks of the
Gentoo Foundation, used here per the Gentoo artwork guidelines to identify
an unofficial community overlay — this project is not official Gentoo or
Omarchy tooling. Omarchy is a pending trademark of its respective owners.
The mark is original composition for this overlay.
