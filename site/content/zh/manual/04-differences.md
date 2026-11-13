---
title: 与 Arch Omarchy 的差异
desc: Gentoo 版相对上游 Omarchy 改变了什么——源码编译、无 ISO、无引导栈、运行时包名映射。
lang: zh
en-source: content/manual/04-differences.md
en-stamp: 19e70837eeacd3d7
---
## 一切都在你的机器上编译

这是源码 overlay——没有 binhost。桌面核心、尤其是完整应用集要从源码
构建，浏览器也不例外。桌面规模的依赖闭包需要时间；这是源码系 Gentoo
的代价，不是移植的缺陷。动手前用 `emerge --pretend -v` 看看闭包。

## 没有 ISO，没有安装器

先装 Gentoo（[Gentoo 手册](https://wiki.gentoo.org/wiki/Handbook:AMD64)），
再加 overlay——命令见[安装页](../install/)。上游的 ISO 及其引导栈
（Limine 等）是 Arch 的载荷，刻意不移植；内核与引导加载器仍然是你的，
与任何 Gentoo 系统一样。

## omarchy-pkg-add 会说两种名字

Omarchy 的脚本和文档按 Arch 包名安装软件。移植过来的
`omarchy-pkg-add` 内置运行时 Arch→Gentoo 重命名表，这些调用会解析成
正确的 Portage atom——包括 Gentoo 惯例不同之处的改名（去掉 `-git`
后缀、去掉 `ttf-` 前缀、合并包族等）。

## 旧地址暂时继续可用

随着移植成熟，品牌包归入 `omarchy/` 与 `omarchy-extra/` 分类。旧分类
位置以空的迁移 shim 形式保留，早期安装依然可解析；待用户迁移完成后
删除。

## 缺口

部分上游包这里尚不存在，或带有记录在案的原因被跳过——没有 Gentoo
提供者的专有载荷、Arch 专属机制、后续移植批次。
[覆盖页](../../../manual/packages/#skipped)是权威清单；本页刻意不复述。

主题与插件有自己的页面，因为它们的故事基本是"完全一致"：
[主题](../themes/)与[插件](../plugins/)覆盖命令（上游原样）、overlay
围绕它们提供的东西，以及少数仍在等待的助手。

两个 Gentoo 侧的现实：所有包都是 `~arch` keyword，`-bin` 包带专有
license——都按 Portage 惯常方式接受（[排障页](../troubleshooting/)）。
