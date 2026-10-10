# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

# This feature requires Lineage's LiveDisplay AIDL and SELinux HAL attributes.
# The system_server bridge supplies Night Light requests; dash-livedisplay applies them to the HAL.
PRODUCT_PACKAGES += \
    dash-livedisplay \
    dash-eyecare \
    DashEyeCareOverlay

PRODUCT_SYSTEM_SERVER_JARS_EXTRA += system_ext:dash-eyecare
