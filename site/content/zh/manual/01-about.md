---
title: 关于
desc: omarchy-gentoo 是什么——把 Omarchy 的 Arch 包移植到 Gentoo 的非官方社区 overlay；以及它不是什么。
lang: zh
en-source: content/manual/01-about.md
en-stamp: 6abe68ed33ddd652
---
## 这是什么

Omarchy on Gentoo 是 [Omarchy](https://omarchy.org)（DHH 的 Arch 系
Hyprland 桌面）向 **Gentoo Linux** 的社区移植：同一套桌面（Hyprland、
quickshell shell、SDDM、PipeWire、Omarchy 命令行、主题与默认配置）以
源码构建 ebuild 的形式放进一个 Portage overlay。没有预编译包、没有
ISO：一切都由 Portage 在你的机器上编译。

它是**非官方社区 overlay**——与上游 Omarchy 无隶属关系，也不是 Gentoo
官方工具。品牌规范（名称、标志、配色）在仓库的
[assets/logo/README.md](https://github.com/Lax/omarchy-gentoo/blob/master/assets/logo/README.md)
中一次性定义。

## 这不是什么

- **不是 Omarchy 的 fork。** 上游的 Arch 配方驱动一切：CI 从钉住的
  `omacom/omarchy-pkgs` 子模块读取它们，昼夜不停地与本树对账。
- **不是 Omarchy 使用指南。** 快捷键、AI 工具是上游的故事——
  [官方手册](https://omarchy.org/manual/)在任何发行版上都适用。主题与
  插件的 Gentoo 侧是例外：它们的命令在这里原样可用，
  [主题](../themes/)与[插件](../plugins/)记录了 overlay 附带什么。
- **不是 Gentoo 教程。** 如果 Portage 概念是新的，先读
  [Gentoo 手册](https://wiki.gentoo.org/wiki/Handbook:AMD64)（英文），
  再回到[安装页](../install/)。

## 两棵树，一个 overlay

你加进 Portage 的是发布的 overlay
[Lax/omarchy-overlay](https://github.com/Lax/omarchy-overlay)——一棵
生成的树，每次变更由 CI 整体替换。它的 `PROVENANCE` 文件写明生成它的
确切提交：本仓库的 master 与钉住的上游配方提交。所有开发、issue 与
文档都发生在
[Lax/omarchy-gentoo](https://github.com/Lax/omarchy-gentoo)；不要直接
编辑或向发布树提 PR。

## 范围

移植瞄准上游包配方覆盖的内容——桌面、配套工具、上游 ISO 的默认应用
集——以及它们在 Portage 下运行所需的补丁与脚本。内核、引导加载器和
Arch 引导栈刻意不移植；在 Gentoo 上那些是你自己的事。见
[差异页](../differences/)。
