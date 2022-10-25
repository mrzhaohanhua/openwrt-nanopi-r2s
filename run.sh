#!/bin/bash
clear


### 清理 ###
rm -rf openwrt

### 获取openwrt ###
git clone --depth 1 -b v21.02.3 https://github.com/openwrt/openwrt openwrt

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
./scripts/feeds install -a
./scripts/feeds install -a

# UPX 可执行软件压缩
sed -i '/patchelf pkgconf/i\tools-y += ucl upx' ./tools/Makefile
sed -i '\/autoconf\/compile :=/i\$(curdir)/upx/compile := $(curdir)/ucl/compile' ./tools/Makefile
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/tools/upx tools/upx
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/tools/ucl tools/ucl

### 获取额外的 LuCI 应用、主题和依赖 ###
#替换原frp
rm -rf ./feeds/luci/applications/luci-app-frps
rm -rf ./feeds/luci/applications/luci-app-frpc
rm -rf ./feeds/packages/net/frp
rm -f ./package/feeds/packages/frp
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-frps package/extra/luci-app-frps
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-frpc package/extra/luci-app-frpc
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/frp package/extra/frp

#AliyunDrive-WebDav
svn export https://github.com/messense/aliyundrive-webdav/trunk/openwrt/aliyundrive-webdav package/extra/aliyundrive-webdav
svn export https://github.com/messense/aliyundrive-webdav/trunk/openwrt/luci-app-aliyundrive-webdav package/extra/luci-app-aliyundrive-webdav

# SmartDNS(原SmartDNS版本较低)
rm -rf ./feeds/packages/net/smartdns
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/smartdns feeds/packages/net/smartdns
rm -rf ./feeds/luci/applications/luci-app-smartdns
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-smartdns feeds/luci/applications/luci-app-smartdns

# socat
svn export https://github.com/Lienol/openwrt-package/trunk/luci-app-socat package/extra/luci-app-socat

# ChinaDNS
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/chinadns-ng/ package/extra/chinadns-ng

# OLED 驱动程序
git clone -b master --depth 1 https://github.com/NateLol/luci-app-oled.git package/extra/luci-app-oled

# Passwall
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-passwall package/extra/luci-app-passwall
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-passwall2 package/extra/luci-app-passwall2
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/ipt2socks package/extra/ipt2socks
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/microsocks package/extra/microsocks
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/dns2socks package/extra/dns2socks
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/naiveproxy package/extra/naiveproxy
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/pdnsd-alt package/extra/pdnsd-alt
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/shadowsocks-rust package/extra/shadowsocks-rust
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/shadowsocksr-libev package/extra/shadowsocksr-libev
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/simple-obfs package/extra/simple-obfs
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/tcping package/extra/tcping
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/trojan-go package/extra/trojan-go
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/brook package/extra/brook
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/trojan-plus package/extra/trojan-plus
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/ssocks package/extra/ssocks
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/xray-core package/extra/xray-core
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/v2ray-plugin package/extra/v2ray-plugin
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/xray-plugin package/extra/xray-plugin
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/hysteria package/extra/hysteria
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/v2ray-core package/extra/v2ray-core
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/v2ray-geodata package/extra/v2ray-geodata

# KMS 激活助手
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-app-vlmcsd package/extra/luci-app-vlmcsd
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/vlmcsd package/extra/vlmcsd

#Luci主题
svn export https://github.com/mrzhaohanhua/openwrt-package/trunk/luci-theme-neobird package/extra/luci-theme-neobird

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
