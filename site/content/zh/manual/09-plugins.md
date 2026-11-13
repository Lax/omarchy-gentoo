---
title: 插件
desc: Gentoo 上的 Omarchy shell 插件——上游的命令原样可用：add、enable、list、update、remove。
lang: zh
en-source: content/manual/09-plugins.md
en-stamp: ab0437f6403e5d59
---
## 命令完全一致

Shell 插件是上游的机制，在 Gentoo 上未经修改。插件是一个带
`manifest.json` 和 QML 入口的 git 仓库，克隆进
`~/.config/omarchy/plugins/`，由 Omarchy shell 加载：

```bash
omarchy plugin list                                    # 已装 + 内置
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable
omarchy plugin enable omarchy.tailscale
omarchy plugin update acme.weather                     # 全部更新：omarchy plugin update
omarchy plugin remove acme.weather
omarchy plugin validate ./my-plugin                    # 安装前校验
```

目录站是 [plugins.omarchy.org](https://plugins.omarchy.org)。整个流程
不涉及任何包管理器——安装插件不碰 Portage，也不需要 sudo。

## 安全

上游的警告在这里逐字适用：插件以任意、未沙箱的代码运行在常驻 shell
进程里，拥有你用户的全部权限。启用前先读插件代码（或者信任它的作
者）。

## 注意这个词：elephant provider

启动器栈里也有"plugins"——elephant 搜索守护进程的 provider
（calculator、clipboard、files、unicode 等）。那些是普通的 Portage
包：一个合并的 ebuild 同时提供守护进程和全部 provider，随 overlay 其
余部分一起安装更新（[覆盖页](../../../manual/packages/)有清单）。Shell
插件才是本页说的这种 git 安装、带 manifest 的东西；两者只是共用了一
个词。

编写插件——manifest schema、kinds、entry points——请读上游的
[插件指南](https://github.com/omacom/omarchy/blob/v4.5.0/manual/32-shell-plugins.md)，这里原样适用。
