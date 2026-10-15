/* Copyright (C) 2026 YorokobiMaster
 * SPDX-License-Identifier: Apache-2.0
 */
package me.sandai.dashpower;

/** Manual thermal profile ids accepted by the backend. */
final class ThermalProfiles {
    static final int AUTO = -1;

    static boolean selectable(int id) {
        return id == AUTO || id == 0 || id == 1 || id == 6 || id == 7 || id == 9
                || id == 10 || id == 11 || id == 12 || id == 15 || id == 19
                || id == 20 || id == 25;
    }

    private ThermalProfiles() {}
}
