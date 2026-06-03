# ccs — Claude Code 会话仪表盘

> 一条命令,看到你**所有**项目目录下的 Claude Code 会话 —— 状态、活跃时间、
> 目录、标题 —— 并按编号直接恢复。

*中文 · [English](README.en.md)*

> ⚠️ 非官方工具,与 Anthropic 无关。它读取 Claude Code 的本地文件,
> 这些格式未公开,可能随版本变化。

---

如果你同时开着很多 Claude Code 会话(分散在不同仓库、不同 worktree),
`claude --resume` 默认只显示当前目录的会话,很容易忘了哪个在哪儿跑。
`ccs` 把**所有目录**的会话汇成一个列表,忙碌和最近活动的排在最上面,
直接输编号就能跳回去。

## 演示

```text
$ ccs
 1  🟢    2m  web-app               Fix login redirect loop
 2  🟢   11m  web-app               Add Redis rate limiter
 3  ⚪   34m  api-gateway           Investigate flaky CI test
 4  ⚪    3h  api-gateway           Refactor auth middleware
 5  ⚪    6h  mobile-app            修复支付回调超时
 6  ⚪    1d  infra                 Bump deps and run codemod
(live only — 'ccs -a' includes exited sessions)
Resume #? (enter to skip) 3
# → 自动 cd 进 api-gateway 目录,并对该会话执行 `claude --resume`
```

连进程已退出的会话也一起列出:

```text
$ ccs -a
 1  🟢    2m  web-app               Fix login redirect loop
 2  ⚪   34m  api-gateway           Investigate flaky CI test
 3  ⚫    2d  web-app               Wire up password reset email
 4  ⚫    5d  infra                 Migrate logging to OpenTelemetry
```

> 上面的标题均为虚构示例。

状态图标:🟢 忙碌 · ⚪ 活跃(空闲)· ⚫ 已退出

## 安装

需要 [`jq`](https://jqlang.github.io/jq/download/)。支持 **bash** 和 **zsh**,
**Linux** 和 **macOS**。

```bash
git clone https://github.com/nilevols/ccs.git
cd ccs
./install.sh            # 安装到 ~/.local/bin
```

或者把单个 `ccs` 脚本放到 `PATH` 上任意目录并 `chmod +x` 即可。

## 用法

| 命令                         | 作用                                              |
| :--------------------------- | :------------------------------------------------ |
| `ccs`                        | 列出活跃会话(最新在前),输编号即可恢复           |
| `ccs -a`                     | 额外列出已退出的会话(从磁盘 transcript 读取)     |
| `ccs [-a] -- <claude 参数>`  | 恢复时把这些参数透传给 `claude --resume`           |
| `ccs -h`                     | 帮助                                              |
| `ccs -V`                     | 版本                                              |

输入某行的编号即可恢复该会话(自动 `cd` 到它的目录并执行 `claude --resume`);
直接回车则不做任何操作。

`--` 之后的所有参数,会在恢复时原样透传给 `claude`:

```bash
ccs -- --dangerously-skip-permissions
ccs -a -- --model opus
```

## 原理

Claude Code 把数据都存在本地 `~/.claude`(或 `$CLAUDE_CONFIG_DIR`)下:

- **活跃会话注册表** —— `~/.claude/sessions/<pid>.json`,每个运行中的会话一份,
  记录它的目录、状态,以及**你用 `/rename` 设的名字**。`ccs` 直接读它,因为
  `claude agents --json` 的输出**抹掉了 name 字段**。
- **对话记录** —— `~/.claude/projects/<目录>/<会话ID>.jsonl`,里面有自动生成的
  `ai-title`。`ccs -a` 会扫描它来找已退出的会话。

每行标题的优先级:手动 `/rename` 的名字 → Claude 自动标题 → `(untitled)`。

`ccs` **只读** —— 只列出和恢复,绝不修改任何会话。

## 注意事项

- 依赖 Claude Code 的本地文件结构,这些是**未公开**的,可能随版本变化。
  若某次更新让 `ccs` 失效,欢迎提 issue。
- `ccs -a` 只列出最近活动的 25 个已退出会话,避免输出过长。
- 若你重定位了 Claude 配置目录,`ccs` 会遵循 `CLAUDE_CONFIG_DIR`。

## 卸载

```bash
rm "$(command -v ccs)"
```

## 许可

[MIT](LICENSE)
