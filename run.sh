#!/bin/bash
clear

### 清理 ###
echo "清理 ./openwrt/"
rm -rf openwrt

openwrt_version_code="v21.02.3"
# lede_tag_code="20221001"

extra_package_path="./package/extra/"

### 获取openwrt ###
git clone --depth 1 -b $openwrt_version_code https://github.com/openwrt/openwrt openwrt

#切换到openwrt目录
cd openwrt

# 配置 IRQ 并默认关闭 eth0 offloading rx/rx
sed -i '/set_interface_core 4 "eth1"/a\\tset_interface_core 1 "ff150000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/ff150000.i2c/a\\tset_interface_core 8 "ff160000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
wget -P target/linux/rockchip/armv8/base-files/etc/hotplug.d/iface/ https://github.com/QiuSimons/OpenWrt-Add/raw/master/12-disable-rk3328-eth-offloading

# 交换 LAN/WAN 口
sed -i 's,"eth1" "eth0","eth0" "eth1",g' target/linux/rockchip/armv8/base-files/etc/board.d/02_network
sed -i "s,'eth1' 'eth0','eth0' 'eth1',g" target/linux/rockchip/armv8/base-files/etc/board.d/02_network

# 更新 Feeds
./scripts/feeds update -a

# 安装Feeds
./scripts/feeds install -a

# UPX 可执行软件压缩
sed -i '/patchelf pkgconf/i\tools-y += ucl upx' ./tools/Makefile
sed -i '\/autoconf\/compile :=/i\$(curdir)/upx/compile := $(curdir)/ucl/compile' ./tools/Makefile
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/tools/upx tools/upx
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/tools/ucl tools/ucl

### 获取额外的 LuCI 应用、主题和依赖 ###

# 更换smartdns
rm -rf feeds/packages/net/smartdns
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/smartdns/ feeds/packages/net/smartdns

# 替换luci-app-smartdns
rm -rf feeds/luci/applications/luci-app-smartdns
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-smartdns/ feeds/luci/applications/luci-app-smartdns

# Argon主题
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-theme-argon/ ${extra_package_path}/luci-theme-argon
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-argon-config/ ${extra_package_path}/luci-app-argon-config

# ChinaDNS
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/chinadns-ng/ ${extra_package_path}/chinadns-ng

# OLED 驱动程序
git clone -b master --depth 1 https://github.com/NateLol/luci-app-oled.git ${extra_package_path}/luci-app-oled

# Passwall
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-passwall ${extra_package_path}/luci-app-passwall
# 修改luci-app-passwall中的Makefile以支持最新的iptables
sed -i 's,iptables-legacy,iptables-nft,g' ${extra_package_path}/luci-app-passwall/Makefile

# Passwall的依赖包
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/ipt2socks ${extra_package_path}/ipt2socks
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/microsocks ${extra_package_path}/microsocks
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/dns2socks ${extra_package_path}/dns2socks
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/dns2tcp ${extra_package_path}/dns2tcp
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/naiveproxy ${extra_package_path}/naiveproxy
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/pdnsd-alt ${extra_package_path}/pdnsd-alt
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/shadowsocks-rust ${extra_package_path}/shadowsocks-rust
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/shadowsocksr-libev ${extra_package_path}/shadowsocksr-libev
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/simple-obfs ${extra_package_path}/simple-obfs
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/tcping ${extra_package_path}/tcping
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/trojan-go ${extra_package_path}/trojan-go
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/brook ${extra_package_path}/brook
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/trojan-plus ${extra_package_path}/trojan-plus
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/ssocks ${extra_package_path}/ssocks
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/xray-core ${extra_package_path}/xray-core
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/v2ray-plugin ${extra_package_path}/v2ray-plugin
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/xray-plugin ${extra_package_path}/xray-plugin
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/hysteria ${extra_package_path}/hysteria
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/v2ray-core ${extra_package_path}/v2ray-core
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/v2ray-geodata ${extra_package_path}/v2ray-geodata

# KMS 激活助手
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-vlmcsd ${extra_package_path}/luci-app-vlmcsd
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/vlmcsd ${extra_package_path}/vlmcsd

### 后续修改 ###

# 最大连接数（来自QiuSimons/YAOF）
sed -i 's/16384/65535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf

#convert_translation（来自QiuSimons/YAOF）
po_file="$({ find | grep -E "[a-z0-9]+\.zh\-cn.+po"; } 2>"/dev/null")"
for a in ${po_file}; do
  [ -n "$(grep "Language: zh_CN" "$a")" ] && sed -i "s/Language: zh_CN/Language: zh_Hans/g" "$a"
  po_new_file="$(echo -e "$a" | sed "s/zh-cn/zh_Hans/g")"
  mv "$a" "${po_new_file}" 2>"/dev/null"
done

po_file2="$({ find | grep "/zh-cn/" | grep "\.po"; } 2>"/dev/null")"
for b in ${po_file2}; do
  [ -n "$(grep "Language: zh_CN" "$b")" ] && sed -i "s/Language: zh_CN/Language: zh_Hans/g" "$b"
  po_new_file2="$(echo -e "$b" | sed "s/zh-cn/zh_Hans/g")"
  mv "$b" "${po_new_file2}" 2>"/dev/null"
done

lmo_file="$({ find | grep -E "[a-z0-9]+\.zh_Hans.+lmo"; } 2>"/dev/null")"
for c in ${lmo_file}; do
  lmo_new_file="$(echo -e "$c" | sed "s/zh_Hans/zh-cn/g")"
  mv "$c" "${lmo_new_file}" 2>"/dev/null"
done

lmo_file2="$({ find | grep "/zh_Hans/" | grep "\.lmo"; } 2>"/dev/null")"
for d in ${lmo_file2}; do
  lmo_new_file2="$(echo -e "$d" | sed "s/zh_Hans/zh-cn/g")"
  mv "$d" "${lmo_new_file2}" 2>"/dev/null"
done

po_dir="$({ find | grep "/zh-cn" | sed "/\.po/d" | sed "/\.lmo/d"; } 2>"/dev/null")"
for e in ${po_dir}; do
  po_new_dir="$(echo -e "$e" | sed "s/zh-cn/zh_Hans/g")"
  mv "$e" "${po_new_dir}" 2>"/dev/null"
done

makefile_file="$({ find | grep Makefile | sed "/Makefile./d"; } 2>"/dev/null")"
for f in ${makefile_file}; do
  [ -n "$(grep "zh-cn" "$f")" ] && sed -i "s/zh-cn/zh_Hans/g" "$f"
  [ -n "$(grep "zh_Hans.lmo" "$f")" ] && sed -i "s/zh_Hans.lmo/zh-cn.lmo/g" "$f"
done

makefile_file="$({ find package | grep Makefile | sed "/Makefile./d"; } 2>"/dev/null")"
for g in ${makefile_file}; do
  [ -n "$(grep "golang-package.mk" "$g")" ] && sed -i "s,\../..,\$(TOPDIR)/feeds/packages,g" "$g"
  [ -n "$(grep "luci.mk" "$g")" ] && sed -i "s,\../..,\$(TOPDIR)/feeds/luci,g" "$g"
done

# Remove upx commands

makefile_file="$({ find package|grep Makefile |sed "/Makefile./d"; } 2>"/dev/null")"
for a in ${makefile_file}
do
	[ -n "$(grep "upx" "$a")" ] && sed -i "/upx/d" "$a"
done

# Script for creating ACL file for each LuCI APP
bash ../create_acl_for_luci.sh -a

cp ../r2s_config .config
make defconfig
echo "ready to make!!!"
