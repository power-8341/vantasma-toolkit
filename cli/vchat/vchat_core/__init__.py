"""vchat_core · 已解密微信 db 的查询库

零外部依赖（仅 Python stdlib），独立实现 vchat CLI 所有数据访问能力。
"""

import os
from pathlib import Path


__version__ = "2.0.0"
__version_info__ = (2, 0, 0)


def get_data_dir() -> Path:
    """解析数据根目录（含 `decrypted/` 子目录的那一层）。

    优先级：
        1. `VCHAT_DATA_DIR` 环境变量
        2. `WECHAT_DECRYPT_PATH` 环境变量（旧名，兼容祥瑞历史脚本与 group-daily skill）
        3. `~/.vchat/data`
        4. `~/Projects/wechat-decrypt`（旧默认值，兼容祥瑞本机）
    """
    for env in ("VCHAT_DATA_DIR", "WECHAT_DECRYPT_PATH"):
        v = os.environ.get(env)
        if v:
            return Path(os.path.expanduser(v))

    for default in (Path.home() / ".vchat/data",
                    Path.home() / "Projects/wechat-decrypt"):
        if (default / "decrypted").exists():
            return default

    # 都不存在，返回新默认值（让上层报"目录不存在"）
    return Path.home() / ".vchat/data"


def get_decrypted_dir() -> Path:
    """`<data_dir>/decrypted/` ——所有 sqlite db 实际存放路径。"""
    return get_data_dir() / "decrypted"


__all__ = ["get_data_dir", "get_decrypted_dir"]
