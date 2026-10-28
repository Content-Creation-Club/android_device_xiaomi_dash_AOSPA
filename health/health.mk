# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

# Standard battery reporting and Lineage charging control for the stock kernel.
PRODUCT_PACKAGES += \
    android.hardware.health-service.dash \
    dash-health
DEVICE_PACKAGE_OVERLAYS += $(DEVICE_PATH)/health/overlay
