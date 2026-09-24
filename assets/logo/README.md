# Omarchy on Gentoo — name & brand

One name, one mark, defined once. Regenerate every asset here with
`python3 generate.py` (needs `fonttools`, JetBrains Mono Nerd Font, and
`rsvg-convert`; SVG text is baked to paths so viewers need no fonts).

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

The lowercase **g** of JetBrains Mono Bold — the same typeface as the
wordmark, and Omarchy's own terminal font — filled with four hard horizontal
bands: Omarchy's Tokyo Night greens (`#daecc6`, `#9ece6a`) flowing into
Gentoo purples (`#8e77c2`, `#54487a`). Read top to bottom: omarchy becomes
gentoo.

| Color | Hex | Role |
| --- | --- | --- |
| Tokyo Night background | `#1a1b26` | tile fill (dark), `#16161e` for the social card |
| omarchy light | `#daecc6` | band 1 |
| omarchy green | `#9ece6a` | band 2, wordmark "omarchy" on dark |
| gentoo violet | `#8e77c2` | band 3, wordmark "-gentoo" on dark |
| gentoo purple | `#54487a` | band 4 (Gentoo's brand purple) |

## Files

| File | Use |
| --- | --- |
| `omarchy-gentoo-mark.svg` | the icon: avatars, favicons, badges |
| `omarchy-gentoo-mark-{512,128,64,32}.png` | raster icon exports |
| `omarchy-gentoo-lockup-dark.svg` / `-light.svg` | horizontal logo + tagline; use per background (README `<picture>` swaps them) |
| `omarchy-gentoo-glyph.svg` | bare gradient "g", no tile |
| `social-preview.svg` / `.png` | GitHub repo social preview (1280×640; upload in repo settings → Social preview) |

Trademark note: Omarchy is a pending trademark of its respective owners;
Gentoo is a trademark of the Gentoo Foundation. This mark is original
artwork created for this overlay (glyph outlines from the SIL OFL JetBrains
Mono) and asserts no affiliation with or endorsement by either project.
