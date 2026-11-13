---
title: FAQ
desc: 简短问答——官方性、ISO、二进制包、更新、omarchy 命令行、缺失的包。
lang: zh
en-source: content/manual/06-faq.md
en-stamp: 76f8a1b2482c24db
---
**这是官方的 Omarchy 吗？**

不是——非官方社区 overlay，与上游 Omarchy 和 Gentoo 基金会均无隶属。
完整定位见[关于页](../about/)。

**有 ISO 或体验用虚拟机吗？**

没有。先装 Gentoo（[Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64)），
再加 overlay。上游的 ISO 是 Arch 专属，这里也没有预编译 binhost——
一切都从源码编译。

**主题、快捷键、插件、AI 工具的文档在哪？**

桌面使用是上游的：[官方手册](https://omarchy.org/manual/)在 Gentoo 上
同样适用。本站只记录 Gentoo 侧——
[主题](../themes/)与[插件](../plugins/)：命令是上游的，一字未改。

**为什么缺某个包？**

查[覆盖页](../../../manual/packages/)：要么已收录、要么带记录的原因被跳过、要么
还在移植队列。想移植它就提 PR——[开发页 <span class="en-tag">EN</span>](../../../manual/developing/)
说明了流程。

**更新如何工作？**

上游 Omarchy 的变更落地时（最多每三小时）CI 会重新发布 overlay 树。
你的机器上：`emaint sync -r omarchy` 加惯常的 world 升级——命令见
[安装页](../install/)。

**omarchy 命令行能用吗？**

桌面核心移植了 Omarchy CLI；它的包安装走 `omarchy-pkg-add`，在运行时
把 Arch 包名映射为 Portage atom。[差异页](../differences/)有解释。

**系统更新和内核呢？**

与任何 Gentoo 系统一样是你的事：Portage 管 @world，你管内核和引导加
载器。Arch 引导栈刻意不移植。
