# Copyright (C) 2026 GitHub @YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

DEVICE_PATH := device/xiaomi/dash

$(call inherit-product, $(DEVICE_PATH)/health/health.mk)

$(call inherit-product, $(DEVICE_PATH)/ims/ims.mk)

$(call inherit-product, $(DEVICE_PATH)/device-services.mk)

DASH_HARDWARE_PATH ?= hardware/xiaomi/dash
$(call inherit-product, $(DASH_HARDWARE_PATH)/dash.mk)

$(call inherit-product, $(DEVICE_PATH)/fod/fod.mk)

$(call inherit-product, $(DEVICE_PATH)/display/brightness/brightness.mk)

$(call inherit-product, $(DEVICE_PATH)/power/power.mk)

# The stock device is an A/B dynamic-partition device. This stage builds the
# Lineage-owned framework partitions without packaging an OTA or super image.
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_USE_DYNAMIC_PARTITION_SIZE := true

# dash launched on Android 16 while retaining an Android 15 vendor/VNDK
# contract. These levels are intentionally separate.
PRODUCT_SHIPPING_API_LEVEL := 36
PRODUCT_TARGET_VNDK_VERSION := 35

# Retain the stock vendor-side images for this stage.
PRODUCT_BUILD_VENDOR_IMAGE := false
PRODUCT_BUILD_ODM_IMAGE := false
PRODUCT_BUILD_SYSTEM_DLKM_IMAGE := false
PRODUCT_BUILD_VENDOR_DLKM_IMAGE := true
PRODUCT_BUILD_ODM_DLKM_IMAGE := false

PRODUCT_BUILD_BOOT_IMAGE := true
PRODUCT_BUILD_VENDOR_BOOT_IMAGE := true
PRODUCT_BUILD_INIT_BOOT_IMAGE := true
PRODUCT_BUILD_DTBO_IMAGE := false
PRODUCT_BUILD_RECOVERY_IMAGE := false
PRODUCT_BUILD_DEBUG_BOOT_IMAGE := false
PRODUCT_BUILD_DEBUG_VENDOR_BOOT_IMAGE := false

DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := \
    $(DEVICE_PATH)/framework_compatibility_matrix.xml

PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH) \
    vendor/xiaomi/dash

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

# HyperOS fills ro.miui.build.region at runtime; nothing in this build did,
# so the static vendor overlay FrameworkResOverlay_dashCN (which requires
# region=cn) never activated and the GL one won by default. Its only payload
# is power_profile.xml, and GL declares battery.capacity 8500 instead of the
# CN model's 9000, which broke battery drain estimates.
PRODUCT_SYSTEM_PROPERTIES += \
    ro.miui.build.region=cn

# lineage_dash does not inherit build/make/target/product/base_system_ext.mk,
# so the ashmem allocator service is never installed even though the frozen
# device matrices require the framework to declare it (check-vintf-all).
PRODUCT_PACKAGES += \
    android.hidl.allocator@1.0-service

PRODUCT_PACKAGES += \
    DashApertureOverlay \
    DashEyeCare \
    DashFrameworkResOverlay \
    DashLineagePartsOverlay \
    DashRefreshRate \
    DashSettingsOverlay \
    DashTelecommOverlay \
    DashTelephonyOverlay \
    DashWifiOverlay \
    dash-displayfeature-compat \
    dash-livedisplay \
    dash-unavailable-features \
    init.dash-system_ext.rc \
    libhidltransport
    privapp-permissions-dash-system-ext \


DEVICE_PACKAGE_OVERLAYS += \
    $(DEVICE_PATH)/overlay \
    $(DEVICE_PATH)/overlay-lineage

# MindTheGApps/vendor_gapps, branch `baklava`, core GMS fits default partition sizes.
$(call inherit-product, $(DEVICE_PATH)/enhancements/gapps/core-arm64.mk)
