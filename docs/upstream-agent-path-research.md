# 上游贡献调研：agent 启动的 PATH 解析问题（omarchy 上游）

状态：**调研完成，结论为不向上游提报**。本文档保留完整证据链与重评条件，
供未来复查。日期：2026-10-14。关联 issue：#30（本 overlay）。

## 0. 任务与结论

任务：评估是否值得向 basecamp/omarchy（Arch 上游）贡献「让 agent 启动不依赖
PATH 顺序」的修复（#30 讨论中的方案 E）。

**结论：不提。** 调研确认上游通过 uwsm 环境种子已经把 mise shims 前置，
Arch 桌面对裸名的解析是确定性的、优先命中 mise——上游不具备我们遇到的
故障形态，PR 的前提不成立。Gentoo 事故是本机环境分层叠加的结果，且
overlay 已忠实复刻上游机制（含 env.d 这一层，见 §2.5 的勘误）。

## 1. 事故回顾（为什么曾考虑上游贡献）

#30 的故障需要三层叠加：

1. guru 的 `dev-util/opencode-bin-2.0.24` 占住 `/usr/bin/opencode`；
2. 桌面会话某条启动链的 PATH 里 shims 排在 `/usr/bin` 之后（issue 记录的
   "compositor scope" 快照）；
3. opencode v2.0.24 自身 `service.ensure` 不复用已登记服务（sst/opencode
   的 bug，与 omarchy 无关）。

当时设想的上游修复（方案 E）：`omarchy-agent` 启动前把 agent 解析为绝对
路径（优先 mise shim），或允许 `defaults/agent` 携带路径覆盖。

## 2. 调研证据

### 2.1 上游的 PATH 种子设计（源码，master 9f49906）

`default/uwsm/env.d/10-omarchy`（uwsm 组装会话环境时执行）：

```sh
[ -r /usr/share/omarchy/default/bash/env-bootstrap ] && . /usr/share/omarchy/default/bash/env-bootstrap
...
omarchy-cmd-present mise && eval "$(mise activate bash --shims)"
```

`default/bash/env-bootstrap` 会把 shims **追加到末尾**（注释明言 "appended
so system binaries keep precedence"，服务 SSH/无 rc 场景），随后 env.d 里
的 `mise activate --shims` 再做前置。该文件在我们 pin（v4.0.4/c668141）、
上游 master、本机已装副本三处逐字节一致。

### 2.2 关键实验：activate 是否无条件前置（本机 mise 2026.10.7）

```console
$ env -i HOME=$HOME PATH=/usr/bin:/bin bash -c 'eval "$(mise activate bash --shims)"; echo $PATH'
/home/lax/.local/share/mise/shims:/usr/bin:/bin
$ env -i HOME=$HOME PATH=/usr/bin:/bin:$HOME/.local/share/mise/shims bash -c 'eval "$(mise activate bash --shims)"; echo $PATH'
/home/lax/.local/share/mise/shims:/usr/bin:/bin:/home/lax/.local/share/mise/shims
```

shims 已在 PATH 里时 activate **依旧前置**一份——不会被 env-bootstrap 的
追加"安抚"掉。即上游设计下桌面的裸名解析永远先命中 shim。

### 2.3 本机实测：桌面环境今天就是这个顺序

```
$ systemctl --user show-environment | grep ^PATH
PATH=/usr/share/omarchy/bin:/home/lax/.local/share/mise/shims:/home/lax/.cargo/bin:/usr/bin:...
$ tr '\0' '\n' < /proc/<foot pid>/environ | grep ^PATH
PATH=/usr/share/omarchy/bin:/home/lax/.local/share/mise/shims:/home/lax/.cargo/bin:/usr/local/bin:/usr/bin:...
```

运行中的 foot 进程与 systemd 用户环境一致：**shims 第 2 位**。今天桌面
裸名 `opencode` 命中的就是 mise 的 1.19.0（guru 包已卸，见 §4）。

### 2.4 issue 里那条异常 PATH 的来源：未完全定位，但已不具现值

#30 记录的快照（`cargo:/usr/local/sbin:/usr/local/bin:/usr/bin:…:shims:.local/bin`）
与今日实测不符：它缺少前置副本，却保留 env-bootstrap 的追加指纹——更像
另一条启动链（未经 uwsm env.d 处理的 app 作用域）或旧会话状态的产物。
无法从现场复现（会话已多次重启）。重要推论：**这条异常不是上游设计
造成的，也无法靠改上游胶水来兜住**——上游的防线在 env.d，会话环境健康
时它必然生效。

### 2.5 对我们此前审计的勘误

早前 #30 的忠实性审计覆盖了 bin/ 脚本与 skill，未覆盖 uwsm env.d 这层。
本次补齐：`default/uwsm/env.d/10-omarchy` 与 `default/bash/env-bootstrap`
在 pin、master、本机三方一致（master 新增的 command-wrappers 块晚于
v4.0.4，属正常版本差）。**overlay 在这一层同样忠实，无需修复。**

### 2.6 上游 issue 先例：无

在 basecamp/omarchy 的 issue 里搜索 "opencode PATH" / "opencode
version" / "agent mise" 均无结果——没有既有讨论，也没有上游认为这是
问题的迹象。

## 3. 结论与建议

**不向 basecamp/omarchy 提 PATH 解析的 PR。** 理由：

1. 上游已有确定性机制（env.d → activate 前置 shims），我们提的"修复"
   在 Arch 上修的是一个不存在的故障；
2. 防御性加固（启动时优先 shim）没有上游可复现的失败样例，PR 大概率
   被以 "works as designed" 拒绝，还消耗上游维护者信任；
3. 我们事故的真正根因分层里，属于 Gentoo 侧的（异常启动链环境 + 用户
   安装的系统包）都已在 overlay/本机层处置完毕（#30 更正评论）。

### 3.1 重评触发条件（满足任一再考虑上游跟进）

- 在 **stock Arch** 上复现：桌面启动的 agent 与 `mise where <agent>` 不
  同版本（即 env.d 前置在某条真实启动链上失效）；
- 上游 issue 区出现同类报告，社区/维护者认可这是问题；
- 上游改动 env.d/activate 的调用方式，破坏了前置保证。

### 3.2 备用草案（仅在触发条件满足时使用，勿主动提交）

最小防御性改动（`bin/omarchy-agent`，在 case 分派前）：

```bash
# Prefer the copy this install manages (mise) over whatever a system
# package may have dropped on the session PATH (basecamp/omarchy#<n>).
shim=$HOME/.local/share/mise/shims/$agent
[[ -x $shim ]] && agent_bin=$shim || agent_bin=$agent
command=("$agent_bin" --auto)   # 各 case 中的裸名相应替换
```

附带影响面说明：需同步改 omarchy-cmd-present/missing 的语义（或仅在
launch 处使用 shim）、test/shell.d 的 agent 启动测试、以及 opencode 之外
十余个 agent 的 case 分支——工作量不小，收益在 Arch 上为零，这正是当前
不建议提报的量化理由。

### 3.3 另一条真实的上游线索（不属于 omarchy）

opencode 2.0.24 的 `service.ensure` 不复用 `~/.local/state/opencode/
service.json` 里活着的服务，硬起第二个 server 撞自己的端口——这是
sst/opencode 的 bug，若要报告应提到 sst/opencode（先核对新版本是否
已修）。与 omarchy 上游无关，未在本次范围内展开。

## 4. Gentoo 侧现状（闭环记录）

- 本机：孤儿服务已清、guru 包已卸、mise 1.19.0 经 shim 正常应答；
- overlay：omarchy 包 `pkg_postinst` 增加 `/usr/bin/opencode` 运行时
  检测告警（1eeaffc）；mask 路线经实证不可行已撤销（Portage 的
  package.mask 按 repo 作用域求值，见 #30 更正评论）；
- 残余风险：若那条异常启动链再次出现（桌面某 app 的 PATH 缺前置
  shims），排查入口是 `/proc/<pid>/environ` 对比 systemd 用户环境。
