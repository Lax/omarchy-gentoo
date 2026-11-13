---
title: 主题
desc: Gentoo 上的 Omarchy 主题——与上游相同的命令、overlay 附带的全套内容，以及确切的缺口清单。
lang: zh
en-source: content/manual/08-themes.md
en-stamp: 97a9612a9161887a
---
## 命令完全一致

Gentoo 上的主题切换就是上游的机制，未经修改：选择器在 shell 里
（`Super + Ctrl + T`，或菜单里的 _Appearance > Theme_），安装第三方
主题的命令与 Arch 上相同：

```bash
omarchy theme install https://github.com/<author>/omarchy-<name>-theme
```

上游的主题流程就是 git clone 加文件操作——不碰 pacman、不需要 sudo——
所以没有任何东西需要移植。一次切换会重新生成 themed 应用模板、给整个
shell 换色，并按上游手册描述的那样运行 `theme-set` hooks。

## overlay 附带什么

- 全套内置主题，由 omarchy ebuild 安装在 `/usr/share/omarchy/themes`。
- 每个内置主题的背景 intro（omarchy-themes-intros）。
- SDDM 登录主题与解锁画面样式（omarchy-settings）。
- 主题通过 `icons.theme` 引用的图标集——
  `x11-themes/yaru-icon-theme`（ubuntu/yaru 的图标 split；Gentoo 在
  2026 年的树里移除了它，overlay 重新移植）。
- 手册点名的主题编辑器 GUI——`x11-themes/aether-bin`，取自上游的
  release 二进制构建。

## 已知缺口

少数内部助手仍在等待移植（在移植 backlog 里，P3）：`owe` 壁纸引擎、
`omarchy-hyprland-titlebars` Hyprland 插件，以及
`signed`/`gliff`/`hype`/`monologue` 应用。没有它们，颜色、终端与
shell 主题照常切换；壁纸处理在 `owe` 落地前暂时退化。

自制主题——`colors.toml` 格式、`~/.config/omarchy/themed/*.tpl` 模板、
以 `omarchy-<name>-theme` 命名分享——请直接读上游的
[指南](https://github.com/omacom/omarchy/blob/v4.5.0/manual/43-making-your-own-theme.md)，这里原样适用。社区画廊在
[omarchy.org/themes](https://omarchy.org/themes/)。
