---
title: 排障
desc: keywords、license、USE 冲突与编译耗时——安装 Omarchy overlay 的 Gentoo 侧现实。
lang: zh
en-source: content/manual/05-troubleshooting.md
en-stamp: b2b4bfd77c0c2cfc
---
权威安装步骤在 overlay README 里，已嵌入[安装页](../install/)；本页
展开它提到的 Gentoo 侧现实。

## Portage 要求接受 keywords

overlay 里的所有包都是 `~amd64` / `~arm64` keyword——按 Portage 惯常
方式接受不稳定 keyword，例如 `/etc/portage/package.accept_keywords`：

```ini
*/*::omarchy ~amd64
```

或者沿用你已有的 package.accept_keywords 方案——overlay 在这里没有
任何特殊之处。

## Portage 要求接受 license

`-bin` 包带专有 license。按惯例接受，例如在
`/etc/portage/package.license` 里写 `*/* all-rights-reserved`。

## 安装过程中的 USE 约束冲突

按[安装节](../install/#before-you-emerge)推荐的 autounmask 参数执行
安装。当 Portage 报告 USE 约束冲突——例如 dev-qt/qtbase 需要
`libproxy` 同时要求 `network`——把隐含的 flag 一起在
`/etc/portage/package.use` 里启用后重跑。autounmask 会替你写大部分
内容；让它写之前先读一遍它的提议。

## 编译要（很长的）时间

这里没有任何二进制包。桌面核心、尤其是完整应用集要源码编译；笔记本
上整套装下来以小时计，不是分钟。两个不花钱的缓解：

- `emerge --pretend -v` 在你投入之前展示闭包。
- 每夜 smoke 构建会在问题进入发布 overlay 之前抓到它——如果某夜
 失败了，[issue 跟踪器](https://github.com/Lax/omarchy-gentoo/issues)
  里会有对应 issue。

## 去哪里报告

问题报告到
[omarchy-gentoo 的 issue 跟踪器](https://github.com/Lax/omarchy-gentoo/issues)——
不要提到发布的 overlay 仓库，它是生成的、实际上只读。附上
`emerge --info`、失败的 atom、以及你同步到的 overlay 提交（发布仓库
的 `PROVENANCE` 文件写明了它）。

关于*使用*桌面本身的问题——快捷键、AI 工具——属于上游：
[omarchy.org](https://omarchy.org)、其
[手册](https://omarchy.org/manual/)与社区频道。主题与插件的 Gentoo
侧记录在这里：[主题](../themes/)、[插件](../plugins/)。
