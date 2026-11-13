---
title: Omarchy on Gentoo
desc: 为 Gentoo Linux 带来 Omarchy 桌面——Hyprland、quickshell 及其周边工具，全部是源码构建的 ebuild。非官方社区 overlay。
lang: zh
en-source: content/index.md
en-stamp: 82ec5d268c3c5906
---
@@generated:status-zh@@

## 快速上手

添加 overlay、同步，然后安装桌面核心；`omarchy-base` 是上游 ISO 的完整默认应用集（[安装页](manual/install/)有完整说明）：

```bash
eselect repository add omarchy git https://github.com/Lax/omarchy-overlay.git
emaint sync -r omarchy
emerge omarchy/omarchy
```

<div class="cards">
  <a class="card" href="../manual/packages/">
    <h3>收录了什么</h3>
    <p>覆盖表：每个已移植的包、每个带原因的跳过、以及实时的移植队列——数据直接来自源码树，不靠手写。</p>
  </a>
  <a class="card" href="manual/differences/">
    <h3>有何不同</h3>
    <p>源码编译、无 ISO、无 Arch 引导栈——Gentoo 版相对上游 Omarchy 的日常差异。</p>
  </a>
  <a class="card" href="../manual/developing/">
    <h3>如何自维护</h3>
    <p>上游每三小时同步一次；门禁、每夜真实构建与自动 issue 让源码树无需人肉看管。</p>
  </a>
</div>

第一次来？Omarchy 本体是[上游的发行版](https://omarchy.org)——本 overlay
把它的包带到 Gentoo。关于*使用*桌面的问题请看[官方手册](https://omarchy.org/manual/)；
Gentoo 侧的问题从[关于页](manual/about/)开始。本页的英文原版在[这里](../)。
