# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

# Lineage configuration for the shared wake and LED implementations.
$(call inherit-product, $(DASH_HARDWARE_PATH)/lineage.mk)

# Charging control implements Lineage's health interface.
$(call inherit-product, $(DEVICE_PATH)/health/health.mk)

# These overlays reference LineageParts and Lineage platform resources.
PRODUCT_PACKAGES += \
    DashLineagePartsOverlay \
    DashSettingsOverlay

# LiveDisplay/Night Light remains one device feature. Its implementation
# requires Lineage's LiveDisplay interface; see display/livedisplay/livedisplay.mk.
