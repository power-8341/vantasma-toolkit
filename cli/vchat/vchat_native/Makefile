# vchat_native · macOS 内存扫描工具
#
# 编译目标：find_keys_macos
# 用法（在仓库根目录）：make -C vchat_native
#                       sudo vchat_native/find_keys_macos

CC ?= clang
CFLAGS ?= -O2 -Wall -Wno-deprecated-declarations
LDFLAGS ?= -framework Foundation

.PHONY: all clean

all: find_keys_macos

find_keys_macos: find_keys_macos.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	rm -f find_keys_macos
