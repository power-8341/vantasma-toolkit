# wxchat

> 微信本地聊天记录的查询/导出/分析 CLI。一行命令拉聊天、找联系人、列语音、转录、导出朋友圈、看统计。**零运行依赖**（纯 Python stdlib + 可选 whisper），自带查询库 `wxchat_core/`。

> ## ⚠️ 免责声明 · Personal Learning Only
>
> **本项目仅用于个人学习与研究目的。**
>
> 1. 本工具只在用户**本机**上操作自己已登录的微信账号的本地数据库。所有处理在本地完成，**不上传任何数据到任何服务器**。
> 2. 用户**只能用本工具处理自己拥有合法访问权的数据**。严禁用于：
>    - 未经他人同意访问、解析他人微信账号或聊天记录
>    - 任何商业目的的批量数据采集、出售、转发
>    - 任何形式的监控、跟踪他人
>    - 违反《中华人民共和国网络安全法》《个人信息保护法》《数据安全法》以及微信《软件许可及服务协议》《用户协议》的行为
> 3. 本工具不提供任何形式的明示或暗示担保。**使用者自行承担一切后果与法律责任**。作者及贡献者不对任何使用造成的直接或间接损失负责。
> 4. 微信、WeChat、SQLCipher、WCDB 是其各自持有人的注册商标。本项目与腾讯公司、Zetetic 等无任何关联，亦未获其授权。
> 5. 一旦下载或使用本工具，即视为你已阅读、理解并接受上述声明。若不接受任何一条，请立即停止使用并删除本项目。
>
> **学习目的**：了解 SQLCipher / WCDB 加密原理、Python 系统编程、跨平台进程内存读取、CLI 工程化实践。


```
$ wxchat ls 5
最近 5 个会话：
  [2026-05-12 00:59] 灯下白听友1群           📬1
  [2026-05-12 00:56] 祥瑞和Ta的社区朋友们
  [2026-05-12 00:56] ComfyUI官方群1          📬551
  [2026-05-12 00:52] AI媒体创造营
  [2026-05-12 00:48] 一群朋友
```

## 这是什么

wxchat 是一个**只做查询、不做解密**的 CLI 工具。你需要先用任意一个开源工具把微信本地 SQLCipher 数据库解密成普通 sqlite，把产物放到 wxchat 能找到的位置（默认 `~/.wxchat/data/decrypted/`），然后所有子命令都能跑了。

跟其他「微信工具集成包」的区别：

- **轻**：1300 行主 CLI + 1500 行查询库，纯 Python stdlib
- **解耦**：解密由你选，wxchat 不绑死任何一个解密工具
- **跨平台**：理论上 macOS/Linux/Windows 都能跑（解密产物结构对就行）
- **可嵌入**：`from wxchat_core import ...` 直接当库用，给 LLM Agent / 脚本使

## 60+ 子命令（v2.0 全部 kebab-case 风格）

```bash
# 数据健康
wxchat doctor                                   # 数据目录健康检查
wxchat info                                     # 数据新鲜度概览
sudo wxchat setup                               # 一键解密（含 codesign / 编译 / 扫内存 / 解所有 db）
sudo wxchat decrypt                             # 仅解密（不重做 setup）

# 查询
wxchat ls 20                                    # 最近 20 个会话
wxchat history "祥瑞和Ta的社区朋友们" -n 5000     # 拉一个群 5000 条历史
wxchat search "OPC" --fast                      # FTS 全库快速搜（10× 提速）
wxchat export "某某" -o ~/Desktop/x.json        # 导出全部历史 JSON
wxchat contacts "陈天泽"                         # 找单人 wxid
wxchat history-history -n 30                    # 你的微信内搜索历史

# 语音
wxchat voice-ls "群名"                          # 列语音 local_id
wxchat voice-transcribe "群名" --local-id 11239 # 转录单条语音
wxchat voice-stats                              # 全局语音密度排行

# 群 & 头像
wxchat group-info "群名"                        # 群主 + 公告 + 成员数
wxchat group-members "群名" --avatars -o dir/   # 列成员 + 批量导出真实头像
wxchat avatar "李祥瑞" -o ~/Downloads

# 数据洞察
wxchat stats-overview                           # 消息总数 / 联系人数 / 时间跨度
wxchat stats-top-groups -n 10
wxchat stats-monthly
wxchat stats-hourly

# 朋友圈
wxchat sns-ls / sns-search "关键词" / sns-user "李祥瑞" / sns-export "李祥瑞"

# 公众号 / 企微 / 视频号
wxchat biz-ls / biz-accounts / biz-info / biz-articles
wxchat bizchat-contacts / bizchat-groups        # 企业微信
wxchat finder / finder-lives                    # 视频号

# 其他
wxchat files / fav-ls / fav-search / fav-tags
wxchat money / friends / emoji-packages / miniprogram
wxchat revoked / unread / tags-ls / deleted-sessions
wxchat watch --chat "群名"                       # 实时监听新消息（tail -f 风格）
```

完整列表（共 60+）：`wxchat --help`

### 全局 flag

```bash
wxchat --version                # 输出版本号
wxchat --json <subcommand>      # 所有子命令输出 JSON（适合 AI Agent / 管道）
wxchat --no-color <...>         # 禁用颜色（也尊重 NO_COLOR=1 环境变量）
wxchat -q <...>                 # 静默模式
wxchat -v <...>                 # 调试模式
```

### Shell completion

```bash
# bash
wxchat completion bash > ~/.local/share/bash-completion/completions/wxchat
# zsh
wxchat completion zsh > "${fpath[1]}/_wxchat"
# fish
wxchat completion fish > ~/.config/fish/completions/wxchat.fish
```

## 安装

### 1. 先解密一次（任选其一）

wxchat 不重复造解密的轮子。挑一个上游工具把微信 db 解密成 sqlite：

| 工具 | 平台 | 微信版本 |
|---|---|---|
| [PyWxDump](https://github.com/xaoyaoo/PyWxDump) | Windows + macOS | 3.x / 4.x |
| [wechat-decrypt](https://github.com/ylytdeng/wechat-decrypt) | macOS | 4.x |
| [WeChatMsg](https://github.com/LC044/WeChatMsg) | Windows | 3.x |

按它们的 README 操作一次，拿到一个目录，里面有 `contact.db` / `message_*.db` 等。

### 2. 把产物摆成 wxchat 期望的样子

```
~/.wxchat/data/decrypted/
├── contact/contact.db
├── session/session.db
├── message/message_0.db
├── message/media_0.db
├── head_image/head_image.db
└── sns/sns.db
```

详细布局 + 各工具迁移示例：[`docs/DATA_LAYOUT.md`](docs/DATA_LAYOUT.md)

### 3. 装 wxchat

```bash
git clone https://github.com/Larkin0302/wxchat.git ~/Projects/wxchat
cd ~/Projects/wxchat
bash install.sh
```

`install.sh` 把 `wxchat` 软链到 `~/.local/bin/`，并检测数据目录是否就绪。

### 4. 配置（可选）

```bash
# 默认数据目录是 ~/.wxchat/data，如果你的解密产物在别处：
export WXCHAT_DATA_DIR=/your/path/containing/decrypted

# 写到 ~/.zshrc 或 ~/.bash_profile 持久化
```

### 5. 验证

```bash
wxchat doctor      # 检查必需 db 是否齐全
wxchat info        # 看数据新鲜度
wxchat ls 5        # 试拉 5 条最近会话
```

## 工作原理

```
微信本地 db（SQLCipher 加密）
    ↓ 任意开源解密工具（PyWxDump / WeChatMsg / wechat-decrypt / ...）
解密产物 ($WXCHAT_DATA_DIR/decrypted/)
    ↓
wxchat_core/ 查询库（纯 Python stdlib）
    ↓
wxchat CLI · 17 个子命令
    ↓
你的终端 / LLM Agent / Skill
```

## 高频用法

### 拉一个群的全部历史（适合喂给 AI）

```bash
wxchat history "祥瑞和Ta的社区朋友们" -n 10000 --asc > /tmp/log.txt
# 让 Claude / Cursor 用 Read 工具分块读这个 txt
```

历史直接落盘到文件，比通过 MCP 一爆几百 KB JSON 友好太多。

### 给某个人导出全部聊天

```bash
wxchat export "某某" -o ~/Desktop/someone.json
wxchat export "某某" --md   # 顺带生成 markdown
```

### 转录一段语音

```bash
wxchat voice ls "群名" -n 100                  # 看 local_id
wxchat voice transcribe "群名" --local-id 11239 # 出文字
```

走本地 `openai-whisper` + `silk-python`，转写结果落 `voice_transcriptions.json` 自带缓存。

### 数据洞察

```bash
wxchat stats overview         # 消息总数 / 聊天对象数 / 时间跨度
wxchat stats top-groups -n 20 # 最活跃的群
wxchat stats hourly           # 看自己一天哪个小时最活跃
wxchat voice stats            # 各群语音密度排行
```

## 适合谁用

- 想把群聊一天的历史喂给 AI 做日报/周报
- 想找半年前某次对话的关键词，但微信内置搜索不给力
- 想统计自己一年发了多少条消息、跟谁聊得最多
- 想批量导出朋友圈做存档
- 想给 LLM Agent 一个「看微信」的能力（CLI 比 MCP 轻量）

## 当库用

`wxchat_core/` 是独立 Python 包，可以单独 import：

```python
from wxchat_core import get_decrypted_dir
from wxchat_core.contacts import resolve_chat_context, get_chatroom_members
from wxchat_core.messages import get_chat_history, search_messages
from wxchat_core.voice import transcribe_voice

print(get_chat_history("某某群", limit=100, oldest_first=True))
```

模块：
- `wxchat_core.cache` · sqlite 连接缓存（mtime + per-key lock + 只读 URI）
- `wxchat_core.contacts` · 联系人/群/上下文解析
- `wxchat_core.messages` · 历史/搜索/会话列表
- `wxchat_core.voice` · SILK 解码 + Whisper 转写 + 缓存
- `wxchat_core.content` · 消息内容解码（转账/红包/链接卡）

## 依赖

- macOS / Linux / Windows（解密工具需自行配套；CLI 跨平台）
- Python 3.9+（仅 stdlib）
- 数据目录里有合规结构的已解密 sqlite（见 `docs/DATA_LAYOUT.md`）
- 推荐 `zstandard`（公众号文章 / 部分系统消息内容是 zstd 压缩的）
- 可选 `openai-whisper` + `silk-python`（仅 `wxchat voice transcribe` 需要）

## 数据隐私

- wxchat 只读本机已解密的 sqlite，**不上传任何数据**
- 所有处理在本地完成
- 转录用的也是本地 whisper 模型
- `.gitignore` 已忽略 `*.db` / `decrypted/` / 转写缓存，防误推

## License

MIT。见 `LICENSE`。

## 路线图

见 [`ROADMAP.md`](ROADMAP.md)。短期：单测、`--json` 全子命令输出、`wxchat watch` 实时监听、Windows/Linux 完整验证。

## 鸣谢

wxchat 是查询层；解密层站在以下开源项目的肩膀上，平等鸣谢：

- [PyWxDump](https://github.com/xaoyaoo/PyWxDump)
- [wechat-decrypt](https://github.com/ylytdeng/wechat-decrypt)
- [WeChatMsg](https://github.com/LC044/WeChatMsg)
