# Copyright (C) 2026 YorokobiMaster
# SPDX-License-Identifier: Apache-2.0

# Resource arrays replace rather than merge; keep the complete startup list here.
DEVICE_PACKAGE_OVERLAYS := $(DEVICE_PATH)/configs/device-services/overlay $(DEVICE_PACKAGE_OVERLAYS)
