#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.68.1/g' package/base-files/files/bin/config_generate

echo '修改时区为东八区'
sed -i "s/'UTC'/'CST-8'\n        set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

echo '修改主机名为 JDC_Luban'
sed -i 's/OpenWrt/JDC_Luban/g' package/base-files/files/bin/config_generate

# 更换腾讯源
#sed -i 's#downloads.openwrt.org#mirrors.cloud.tencent.com/openwrt#g' /etc/opkg/distfeeds.conf

echo '载入 mt7621_jdcloud_luban.dts'
curl --retry 3 -s --globoff "https://gist.githubusercontent.com/vki888/dffcf844d8ff693d8057e2f3fde545dc/raw/15a687f05745fe1e555d4706556acc59b363c7a1/%255Bopenwrt%255Dmt7621_jdcloud_luban.dts" -o target/linux/ramips/dts/mt7621_jdcloud_luban.dts
ls -l target/linux/ramips/dts/mt7621_jdcloud_luban.dts

# fix2 + fix4.2
echo '修补 mt7621.mk'
sed -i '/Device\/adslr_g7/i\define Device\/jdcloud_luban\n  \$(Device\/dsa-migration)\n  \$(Device\/uimage-lzma-loader)\n  IMAGE_SIZE := 15808k\n  DEVICE_VENDOR := JDCloud\n  DEVICE_MODEL := luban\n  DEVICE_PACKAGES := kmod-fs-ext4 kmod-mt7915e kmod-sdhci-mt7620 kmod-usb3 uboot-envtools kmod-mmc wpad-openssl\nendef\nTARGET_DEVICES += jdcloud_luban\n\n' target/linux/ramips/image/mt7621.mk

# fix3 + fix5.2
echo '修补 02-network'
#sed -i -e '/hiwifi,hc5962|\\/i\jdcloud,luban|\\' -e '/ramips_setup_macs/,/}/{/ampedwireless,ally-00x19k/i\jdcloud,luban)\n\t\t[ "$PHYNBR" -eq 0 \] && echo $label_mac > /sys${DEVPATH}/macaddress\n\t\t\[ "$PHYNBR" -eq 1 \] && macaddr_add $label_mac 0x800000 > /sys${DEVPATH}/macaddress\n\t\t;;
#}' target/linux/ramips/mt7621/base-files/etc/board.d/02_network

sed -i '/ampedwireless,ally-00x19k|\\/i\jdcloud,luban)\n\t\tucidef_add_switch "switch0" \\ \n\t\t"0:lan" "1:lan" "2:lan" "3:lan" "4:wan" "6u@eth0" "5u@eth1"\n\t\t;;' target/linux/ramips/mt7621/base-files/etc/board.d/02_network

#sed -i -e '/hiwifi,hc5962|\\/i\jdcloud,luban|\\' -e '/ramips_setup_macs/,/}/{/ampedwireless,ally-00x19k/i\jdcloud,luban)\n\t\techo "dc:d8:7c:50:fa:ae" > /sys/devices/platform/1e100000.ethernet/net/eth0/address\n\t\techo "dc:d8:7c:50:fa:af" > /sys/devices/platform/1e100000.ethernet/net/eth1/address\n\t\t;;
#}' target/linux/ramips/mt7621/base-files/etc/board.d/02_network
cat target/linux/ramips/mt7621/base-files/etc/board.d/02_network

# fix5.1
#echo '修补 system.sh 以正常读写 MAC'
#sed -i 's#key"'\''=//p'\''#& \| head -n1#' package/base-files/files/lib/functions/system.sh

echo '定义kernel MD5，与官网一致'
echo '2974fbe1fa59be88f13eb8abeac8c10b' > ./.vermagic
cat .vermagic

sed -i 's/^\tgrep.*vermagic/\tcp -f \$(TOPDIR)\/\.vermagic \$(LINUX_DIR)\/\.vermagic/g' include/kernel-defaults.mk
cat include/kernel-defaults.mk
