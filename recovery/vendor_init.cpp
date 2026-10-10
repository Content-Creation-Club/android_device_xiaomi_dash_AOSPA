// Copyright (C) 2026 YorokobiMaster
// SPDX-License-Identifier: Apache-2.0

#include <sys/system_properties.h>

#ifdef RECOVERY
#include <android-base/logging.h>
#include <string.h>
#endif

void vendor_load_properties() {
#ifdef RECOVERY
    const prop_info* property = __system_property_find("ro.boot.verifiedbootstate");
    if (property == nullptr) {
        LOG(ERROR) << "Recovery: verifiedbootstate property is missing";
        return;
    }

    // This hook runs in init after its writable property area is initialized,
    // before recovery, adbd or fastbootd can read the fake-lock boot state.
    if (__system_property_update(const_cast<prop_info*>(property), "orange", strlen("orange")) != 0) {
        LOG(ERROR) << "Recovery: failed to override verifiedbootstate";
        return;
    }
    LOG(INFO) << "Recovery: verifiedbootstate overridden to orange";
#endif
}
