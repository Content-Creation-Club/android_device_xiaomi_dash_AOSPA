# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

# Bluetooth profiles exposed by the stock phone product.
PRODUCT_PRODUCT_PROPERTIES += \
    persist.bluetooth.a2dp_offload.coex_buf_count=5 \
    bluetooth.profile.a2dp.source.enabled=true \
    bluetooth.profile.asha.central.enabled=true \
    bluetooth.profile.avrcp.target.enabled=true \
    bluetooth.profile.bas.client.enabled=true \
    bluetooth.profile.gatt.enabled=true \
    bluetooth.profile.hfp.ag.enabled=true \
    bluetooth.profile.hid.device.enabled=true \
    bluetooth.profile.hid.host.enabled=true \
    bluetooth.profile.map.server.enabled=true \
    bluetooth.profile.opp.enabled=true \
    bluetooth.profile.pan.nap.enabled=true \
    bluetooth.profile.pan.panu.enabled=true \
    bluetooth.profile.pbap.server.enabled=true \
    bluetooth.profile.sap.server.enabled=true

# Select the retained CN power profile for the 9000 mAh battery.
PRODUCT_SYSTEM_PROPERTIES += \
    ro.miui.build.region=cn \
    ro.sf.lcd_density=480
