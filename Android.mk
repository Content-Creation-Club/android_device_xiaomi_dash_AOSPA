# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

LOCAL_PATH := $(call my-dir)
ifeq ($(TARGET_DEVICE),dash)

# Platform contains only first-stage inputs; Soong installs kernel modules.
dash_platform_root := $(DASH_KERNEL_INPUTS)/platform
dash_platform_files := first_stage_ramdisk/fstab.mt6991
dash_platform_outputs := $(addprefix $(TARGET_VENDOR_RAMDISK_OUT)/,$(dash_platform_files))
$(foreach file,$(dash_platform_files),$(eval $(call copy-one-file,$(dash_platform_root)/$(file),$(TARGET_VENDOR_RAMDISK_OUT)/$(file))))
ALL_DEFAULT_INSTALLED_MODULES += $(dash_platform_outputs)

# Retain stock recovery load order for modules installed in the vendor ramdisk.
dash_recovery_modules_load := $(TARGET_VENDOR_RAMDISK_OUT)/lib/modules/modules.load.recovery
$(dash_recovery_modules_load): $(dash_platform_root)/lib/modules/modules.load.recovery $(LOCAL_PATH)/kernel/modules.mk
	@mkdir -p $(dir $@)
	$(hide) awk 'BEGIN { n=split("$(notdir $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES))", modules); for (i=1; i<=n; i++) included[modules[i]]=1 } $$0 in included' $< > $@
ALL_DEFAULT_INSTALLED_MODULES += $(dash_recovery_modules_load)

# Retain the MTK UFS boot-control implementation as recovery inputs.
dash_recovery_mtk_root := $(DASH_KERNEL_INPUTS)/recovery-mtk
dash_recovery_mtk_files := \
    system/bin/hw/android.hardware.boot-service.mtk_recovery \
    system/bin/mtk_plpath_utils \
    system/lib64/libmtk_bsg.so \
    system/etc/vintf/manifest/android.hardware.boot-service.mtk.xml
dash_recovery_mtk_outputs := $(addprefix $(TARGET_RECOVERY_ROOT_OUT)/,$(dash_recovery_mtk_files))
$(foreach file,$(dash_recovery_mtk_files),$(eval $(call copy-one-file,$(dash_recovery_mtk_root)/$(file),$(TARGET_RECOVERY_ROOT_OUT)/$(file))))
ALL_DEFAULT_INSTALLED_MODULES += $(dash_recovery_mtk_outputs)

$(TARGET_RECOVERY_ROOT_OUT)/system/etc/mke2fs.conf: $(TARGET_RECOVERY_ROOT_OUT)/system/etc/mke2fs.conf.recovery
	ln -sfn mke2fs.conf.recovery $@
ALL_DEFAULT_INSTALLED_MODULES += $(TARGET_RECOVERY_ROOT_OUT)/system/etc/mke2fs.conf

# /ram/lib64 aliases /system/lib64 for the blobs' dlopen paths.
dash_recovery_touch_root := vendor/xiaomi/dash/recovery-touch
dash_recovery_touch_files := \
    system/bin/touch_report_debug \
    ram/lib64/libtensorflowlite_touch_c.so \
    ram/lib64/libtouchreport.so \
    ram/lib64/libtouchreport_alg.so \
    ram/lib64/libtouchreport_hal.so \
    ram/lib64/libtouchreport_sensor.so \
    ram/firmware/film_model.tflite \
    ram/firmware/novatek_nt38771_p10u_fw_csot.bin \
    ram/firmware/novatek_nt38771_p10u_fw_tm.bin \
    ram/firmware/p10u_nova_csot_thp_config.ini \
    ram/firmware/p10u_nova_tm_thp_config.ini \
    ram/firmware/smooth.tflite \
    ram/firmware/water_check.tflite
dash_recovery_touch_outputs := $(addprefix $(TARGET_RECOVERY_ROOT_OUT)/,$(patsubst ram/lib64/%,system/lib64/%,$(dash_recovery_touch_files)))
$(foreach file,$(dash_recovery_touch_files),$(eval $(call copy-one-file,$(dash_recovery_touch_root)/$(file),$(TARGET_RECOVERY_ROOT_OUT)/$(patsubst ram/lib64/%,system/lib64/%,$(file)))))
$(TARGET_RECOVERY_ROOT_OUT)/ram/lib64:
	@mkdir -p $(dir $@)
	ln -sfn /system/lib64 $@
ALL_DEFAULT_INSTALLED_MODULES += $(dash_recovery_touch_outputs) $(TARGET_RECOVERY_ROOT_OUT)/ram/lib64

ifdef BUILDING_VBMETA_IMAGE
$(PRODUCT_OUT)/vbmeta.img: $(DASH_STOCK_INPUTS)/vbmeta_vendor.img
endif
endif
