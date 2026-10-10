# Copyright (C) 2026 @YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

DEVICE_PATH := device/xiaomi/dash

# Architecture. Stock dash userspace is 64-bit only.
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := generic
TARGET_SUPPORTS_32_BIT_APPS := false
TARGET_SUPPORTS_64_BIT_APPS := true

# Platform identity established by the stock vendor properties and recovery
# configuration.
TARGET_BOARD_PLATFORM := mt6991
TARGET_BOOTLOADER_BOARD_NAME := mt6991
TARGET_NO_BOOTLOADER := true

# Kleaf builds the kernel; Android assembles the partition images.
include $(DEVICE_PATH)/kernel/BoardConfigKernel.mk

# Stock images use a 4096-byte page size.
BOARD_KERNEL_PAGESIZE := 4096
BOARD_FLASH_BLOCK_SIZE := 262144

# Downstream products select the system, product and system_ext filesystems.
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm
TARGET_COPY_OUT_ODM_DLKM := odm_dlkm

# First-stage init mounts metadata before switching to the system image root.
BOARD_USES_METADATA_PARTITION := true

TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/fstab.mt6991
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/recovery/sepolicy
$(call soong_config_set,libinit,vendor_init_lib,libinit_recovery_fake_lock)
TARGET_USERIMAGES_USE_F2FS := true

# These partitions remain stock EROFS images; the product configuration below
# explicitly disables rebuilding them.
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs

# Vendor sepolicy comes from the retained stock vendor image; nothing here
# compiles BOARD_VENDOR_SEPOLICY_DIRS. Pin the flag explicitly: the
# BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE line above would otherwise defeat the
# auto-detection in device/lineage/sepolicy/common/sepolicy.mk and silently
# drop lineage's dynamic/ policy (hal_*_service types, service_contexts).
TARGET_USES_PREBUILT_VENDOR_SEPOLICY := true

# Image bounds sized to fit the stock HyperOS LP group.
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 880340992
BOARD_PRODUCTIMAGE_PARTITION_SIZE := 1199996928
BOARD_SYSTEM_EXTIMAGE_PARTITION_SIZE := 479997952
BOARD_VENDOR_DLKMIMAGE_PARTITION_SIZE := 25477120
BOARD_VENDOR_DLKMIMAGE_EROFS_COMPRESSOR := lz4hc,level=12
BOARD_VENDOR_DLKMIMAGE_EROFS_PCLUSTER_SIZE := 16384

# Do not define BOARD_SUPER_PARTITION_SIZE or dynamic-partition group sizes
# in this stage. Per-partition sizes above come from the stock LP metadata;
# image file sizes are not a substitute for the physical super layout.

SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += \
    $(DEVICE_PATH)/sepolicy/system_ext/private

DASH_HARDWARE_PATH ?= hardware/xiaomi/dash
include $(DASH_HARDWARE_PATH)/BoardConfig.mk

include $(DEVICE_PATH)/fod/BoardConfig.mk

include $(DEVICE_PATH)/power/BoardConfig.mk

include $(DEVICE_PATH)/ims/BoardConfig.mk

include $(DEVICE_PATH)/display/livedisplay/BoardConfig.mk

ifeq ($(TARGET_PRODUCT),lineage_dash)
include $(DEVICE_PATH)/BoardConfigLineage.mk
endif
