/*
 * Copyright (C) 2026 YorokobiMaster
 * SPDX-License-Identifier: Apache-2.0
 */

package me.sandai.dashrefreshrate;

import android.os.IBinder;
import android.os.RemoteException;
import android.os.ServiceManager;
import android.util.Log;

import vendor.xiaomi.hardware.displayfeature_aidl.IDisplayFeature;

final class DisplayFeatureClient {
    private static final String TAG = "DashRefreshRate";
    private static final String SERVICE_NAME = IDisplayFeature.DESCRIPTOR + "/default";
    private static final int PRIMARY_DISPLAY = 0;
    private static final int FEATURE_DOZE_BRIGHTNESS = 25;
    private static final int COOKIE = 255;

    boolean setDozeBrightness(int value) {
        IBinder service = ServiceManager.checkService(SERVICE_NAME);
        if (service == null) {
            Log.w(TAG, "displayfeature service unavailable");
            return false;
        }

        try {
            IDisplayFeature.Stub.asInterface(service).setFeature(
                    PRIMARY_DISPLAY, FEATURE_DOZE_BRIGHTNESS, value, COOKIE);
            return true;
        } catch (RemoteException | RuntimeException e) {
            Log.e(TAG, "failed to set doze brightness=" + value, e);
            return false;
        }
    }
}
