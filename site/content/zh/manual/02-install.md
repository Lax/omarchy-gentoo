---
title: 安装
desc: 在 Gentoo 上把 omarchy overlay 加入 Portage 并安装 Omarchy 桌面。
lang: zh
en-source: content/manual/02-install.md
en-stamp: 564c685bfd233a2d
---
下面第一节的全部内容逐字来自发布的 overlay README（构建时嵌入）——如果
它与本页其他文字有任何出入，以它为准。其后的各节是本站补充。

@@include gentoo/README.md@@

## 保持 overlay 最新

发布的树随上游移动：上游 Omarchy 的变更落地时 CI 会重新发布，最多每
三小时一次。按惯常方式同步并升级：

```bash
emaint sync -r omarchy
emerge --ask --deep --update --newuse @world
```

移植过来的 Omarchy 命令行能处理的它会处理；在 Gentoo 上，系统升级
仍然是 Portage 的职责。

## 卸载

```bash
emerge --ask --depclean omarchy/omarchy omarchy/omarchy-base
eselect repository remove omarchy
```

伴生 overlay（guru、hyproverlay）是普通 overlay——如果机器上没有其他
东西用到它们，用同样的方式移除即可。

## 日常使用

- 在动手编译前先看会拉进什么：`emerge --pretend -v omarchy/omarchy`。
- overlay 里的所有包都带有 `omarchy::` 仓库标签，与 ::gentoo 和伴生
  overlay 一眼可分。
- Omarchy 的脚本与文档按 Arch 包名安装软件；移植过来的
  `omarchy-pkg-add` 会在运行时把它们解析为正确的 Portage atom。
  见[差异页](../differences/)。
