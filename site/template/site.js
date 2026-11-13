// Omarchy on Gentoo — theme cycling, mirroring omarchy.org's
// "pick a theme, change everything": the T key (or the ◐ button)
// walks the themes declared in site.css and remembers the pick.
(() => {
  "use strict";

  const KEY = "og-theme";
  const THEMES = ["omarchy", "gentoo", "daylight"];

  const current = () => {
    const t = document.documentElement.dataset.theme;
    return THEMES.includes(t) ? t : THEMES[0];
  };

  const apply = (t) => {
    document.documentElement.dataset.theme = t;
    try {
      localStorage.setItem(KEY, t);
    } catch {
      /* private mode: cycle without remembering */
    }
  };

  const cycle = () => apply(THEMES[(THEMES.indexOf(current()) + 1) % THEMES.length]);

  try {
    const stored = localStorage.getItem(KEY);
    if (stored && THEMES.includes(stored)) apply(stored);
  } catch {
    /* fall through to the stylesheet default */
  }

  const button = document.getElementById("theme-toggle");
  if (button) button.addEventListener("click", cycle);

  window.addEventListener("keydown", (event) => {
    if (event.key !== "t" && event.key !== "T") return;
    if (event.ctrlKey || event.metaKey || event.altKey) return;
    const el = event.target;
    if (el && (el.tagName === "INPUT" || el.tagName === "TEXTAREA" || el.isContentEditable)) return;
    cycle();
  });
})();
