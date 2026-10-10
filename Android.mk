# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

LOCAL_PATH := $(call my-dir)
ifeq ($(TARGET_DEVICE),dash)


# Install the retained platform contents using Android's file-copy rules.
# Modules and modules.load are installed separately by the core depmod rules.
dash_platform_root := $(DASH_KERNEL_INPUTS)/platform
dash_platform_excluded_files := \
    init.recovery.hardware.rc \
    lib/modules/modules.load \
    miui.factoryreset.fstab \
    miui.factoryreset.rc \
    system/bin/adjust_cpu_governor.sh \
    system/bin/fastbootd \
    system/bin/hw/android.hardware.health-service.example_recovery \
    system/bin/logd \
    system/etc/init/android.hardware.boot-service.mtk_recovery.rc \
    system/etc/init/android.hardware.health-service.example_recovery.rc \
    system/etc/init/hw/init.rc \
    system/etc/init/logd.rc \
    system/etc/init/mtk-plpath-utils.rc \
    system/etc/init/recovery-persist.rc \
    system/etc/init/recovery-refresh.rc \
    system/etc/vintf/manifest/android.hardware.health-service.example.xml \
    system/lib64/android.hardware.health-V3-ndk.so \
    system/lib64/hw/android.hardware.fastboot@1.0-impl-mtk.so \
    system/lib64/libcap.so \
    system/lib64/libsysutils.so \
    system/lib64/twrp/%
dash_platform_files := $(filter-out $(addprefix $(dash_platform_root)/,$(dash_platform_excluded_files)),$(shell find $(dash_platform_root) -type f))
dash_platform_outputs := $(patsubst $(dash_platform_root)/%,$(TARGET_VENDOR_RAMDISK_OUT)/%,$(dash_platform_files))
$(foreach src,$(dash_platform_files),$(eval $(call copy-one-file,$(src),$(patsubst $(dash_platform_root)/%,$(TARGET_VENDOR_RAMDISK_OUT)/%,$(src)))))

define dash-platform-symlink
$(TARGET_VENDOR_RAMDISK_OUT)/$(1):
	@mkdir -p $$(dir $$@)
	ln -sfn '$(2)' '$$@'
endef
dash_platform_links := $(filter-out $(addprefix $(dash_platform_root)/,$(dash_platform_excluded_files)),$(shell find $(dash_platform_root) -type l))
$(foreach src,$(dash_platform_links),$(eval $(call dash-platform-symlink,$(patsubst $(dash_platform_root)/%,%,$(src)),$(shell readlink '$(src)'))))
dash_platform_outputs += $(patsubst $(dash_platform_root)/%,$(TARGET_VENDOR_RAMDISK_OUT)/%,$(dash_platform_links))

# Preserve empty mount-point directories as well as files and symlinks.
dash_platform_dirs := $(patsubst $(dash_platform_root)%,$(TARGET_VENDOR_RAMDISK_OUT)%,$(filter-out $(dash_platform_root)/system/lib64/twrp $(dash_platform_root)/system/lib64/twrp/%,$(shell find $(dash_platform_root) -type d)))
dash_platform_dirs_stamp := $(call intermediates-dir-for,PACKAGING,dash_platform)/dirs.stamp
$(dash_platform_dirs_stamp): PRIVATE_DIRS := $(dash_platform_dirs)
$(dash_platform_dirs_stamp): PRIVATE_EXCLUDED_FILES := $(addprefix $(TARGET_VENDOR_RAMDISK_OUT)/,$(filter-out lib/modules/modules.load system/lib64/twrp/%,$(dash_platform_excluded_files)))
$(dash_platform_dirs_stamp): PRIVATE_EXCLUDED_DIR := $(TARGET_VENDOR_RAMDISK_OUT)/system/lib64/twrp
$(dash_platform_dirs_stamp): PRIVATE_RECOVERY_RETIRED_FILE := $(TARGET_RECOVERY_ROOT_OUT)/vendor/etc/ueventd.rc
$(dash_platform_dirs_stamp): $(LOCAL_PATH)/Android.mk
	@mkdir -p $(PRIVATE_DIRS) $(dir $@)
	# Drop retired files from reused staging.
	rm -f $(PRIVATE_EXCLUDED_FILES) $(PRIVATE_RECOVERY_RETIRED_FILE)
	rm -rf $(PRIVATE_EXCLUDED_DIR)
	touch $@
$(dash_platform_outputs): | $(dash_platform_dirs_stamp)
ALL_DEFAULT_INSTALLED_MODULES += $(dash_platform_outputs)
$(call intermediates-dir-for,PACKAGING,vendor_boot)/vendor_ramdisk.cpio.lz4: $(dash_platform_dirs_stamp)
$(call intermediates-dir-for,PACKAGING,recovery)/ramdisk_files-timestamp: $(dash_platform_dirs_stamp)

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
