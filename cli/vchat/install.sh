#!/bin/bash
# wxchat 安装脚本
#   1. 把 wxchat 软链到 ~/.local/bin/
#   2. 提示 PATH 配置
#   3. 检测数据目录是否就绪
#   4. 提示可选依赖（whisper / silk-python，只有 voice transcribe 子命令需要）
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WXCHAT="$SCRIPT_DIR/wxchat"

if [ ! -f "$WXCHAT" ]; then
  echo "❌ wxchat 文件不存在: $WXCHAT"
  exit 1
fi

# ───────────────────────────────────────────────────────────────
# 1. 软链到 ~/.local/bin/
# ───────────────────────────────────────────────────────────────
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
ln -sf "$WXCHAT" "$BIN_DIR/wxchat"
chmod +x "$WXCHAT"
echo "✅ wxchat 已软链到 $BIN_DIR/wxchat"

# ───────────────────────────────────────────────────────────────
# 2. PATH 检查
# ───────────────────────────────────────────────────────────────
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo ""
  echo "⚠️  ~/.local/bin 不在你的 PATH 中。"
  echo "    把下面这行加到 ~/.zshrc 或 ~/.bash_profile:"
  echo ""
  echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# ───────────────────────────────────────────────────────────────
# 3. 数据目录检测
#    优先级跟 wxchat_core.get_data_dir() 一致：
#      WXCHAT_DATA_DIR > WECHAT_DECRYPT_PATH > ~/.wxchat/data > ~/Projects/wechat-decrypt
# ───────────────────────────────────────────────────────────────
DATA_DIR=""
for candidate in \
  "$WXCHAT_DATA_DIR" \
  "$WECHAT_DECRYPT_PATH" \
  "$HOME/.wxchat/data" \
  "$HOME/Projects/wechat-decrypt"; do
  if [ -n "$candidate" ] && [ -d "$candidate/decrypted" ]; then
    DATA_DIR="$candidate"
    break
  fi
done

echo ""
if [ -n "$DATA_DIR" ]; then
  DB_COUNT=$(find "$DATA_DIR/decrypted" -name "*.db" 2>/dev/null | wc -l | tr -d ' ')
  echo "✅ 检测到数据目录: $DATA_DIR ($DB_COUNT 个 db)"
else
  echo "⚠️  没找到已解密的微信数据。"
  echo ""
  echo "    wxchat 只查询，不做解密。先用任意一个开源工具解密一次："
  echo "      · PyWxDump        https://github.com/xaoyaoo/PyWxDump"
  echo "      · wechat-decrypt  https://github.com/ylytdeng/wechat-decrypt"
  echo "      · WeChatMsg       https://github.com/LC044/WeChatMsg"
  echo ""
  echo "    然后把产物（含 decrypted/ 子目录）放到下面任一位置，或显式指定："
  echo "      export WXCHAT_DATA_DIR=/path/to/your/data"
  echo ""
  echo "    期望的目录结构见 docs/DATA_LAYOUT.md。"
fi

# ───────────────────────────────────────────────────────────────
# 4. 可选依赖提示
# ───────────────────────────────────────────────────────────────
echo ""
if ! python3 -c "import zstandard" 2>/dev/null; then
  echo "ℹ️  推荐: zstandard（公众号文章 biz / 部分系统消息内容是 zstd 压缩的）"
  echo "      pip3 install zstandard"
fi
if ! python3 -c "import whisper" 2>/dev/null; then
  echo "ℹ️  可选: openai-whisper（仅 wxchat voice transcribe 需要）"
  echo "      pip3 install openai-whisper"
fi
if ! python3 -c "import pysilk" 2>/dev/null; then
  echo "ℹ️  可选: silk-python（仅 wxchat voice transcribe 需要）"
  echo "      pip3 install silk-python"
fi

# ───────────────────────────────────────────────────────────────
# 5. 验证
# ───────────────────────────────────────────────────────────────
echo ""
echo "▶ 验证安装："
"$WXCHAT" --help 2>&1 | head -5

echo ""
echo "✅ 安装完成。"
echo ""
echo "▶ 数据目录没就绪？一键解密："
echo "    sudo wxchat setup        # macOS · 自动 codesign + 解 17 个 db"
echo ""
echo "▶ 已有数据目录，试试这些："
echo "    wxchat doctor            # 检查数据完整性"
echo "    wxchat ls 20             # 最近 20 个会话"
echo "    wxchat --help            # 看全部 60+ 子命令"
echo ""
echo "▶ 装 shell completion (可选)："
echo "    bash: wxchat completion bash > ~/.local/share/bash-completion/completions/wxchat"
echo "    zsh:  wxchat completion zsh  > \"\${fpath[1]}/_wxchat\""
echo "    fish: wxchat completion fish > ~/.config/fish/completions/wxchat.fish"
