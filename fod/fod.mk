# Copyright (C) 2026 GitHub @YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

PRODUCT_PACKAGES += DashFod DashPinLowOverlay dash-fod
PRODUCT_SYSTEM_SERVER_JARS_EXTRA += system_ext:dash-fod

DEVICE_PACKAGE_OVERLAYS += $(DEVICE_PATH)/fod/overlay
