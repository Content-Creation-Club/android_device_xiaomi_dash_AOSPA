/* Copyright (C) 2026 YorokobiMaster
 * SPDX-License-Identifier: Apache-2.0
 */
package me.sandai.dasheyecare;

import android.app.ActivityManager;
import android.content.Context;
import android.database.ContentObserver;
import android.hardware.display.ColorDisplayManager;
import android.os.Handler;
import android.os.SystemProperties;
import android.os.UserHandle;
import android.provider.Settings;
import android.util.Log;

import com.android.internal.os.BackgroundThread;
import com.android.server.SystemService;

/** Night Light owns UI, scheduling and persistence; this service bridges to the vendor adapter. */
public final class NightLightBridge extends SystemService {
    private static final String PROPERTY = "sys.dash.livedisplay.eyecare";
    private Handler handler;
    // Accessed only on the background handler.
    private int currentUser = UserHandle.USER_SYSTEM;
    private final Runnable sync = this::syncCurrentUser;

    public NightLightBridge(Context context) {
        super(context);
    }

    @Override
    public void onStart() {
        handler = BackgroundThread.getHandler();
    }

    @Override
    public void onBootPhase(int phase) {
        if (phase == PHASE_ACTIVITY_MANAGER_READY) {
            handler.post(this::startObserving);
        }
    }

    private void startObserving() {
        currentUser = ActivityManager.getCurrentUser();
        ContentObserver observer = new ContentObserver(handler) {
            @Override
            public void onChange(boolean selfChange) { scheduleSync(); }
        };
        // Read Settings for the lifecycle's foreground user: ColorDisplayManager's
        // cached active-user state can lag a user-switch or settings notification.
        getContext().getContentResolver().registerContentObserver(
                Settings.Secure.getUriFor(Settings.Secure.NIGHT_DISPLAY_ACTIVATED),
                false, observer, UserHandle.USER_ALL);
        getContext().getContentResolver().registerContentObserver(
                Settings.Secure.getUriFor(Settings.Secure.NIGHT_DISPLAY_COLOR_TEMPERATURE),
                false, observer, UserHandle.USER_ALL);
        scheduleSync();
    }

    @Override
    public void onUserSwitching(TargetUser from, TargetUser to) {
        final int user = to.getUserIdentifier();
        handler.post(() -> {
            currentUser = user;
            scheduleSync();
        });
    }

    @Override
    public void onUserUnlocked(TargetUser user) {
        scheduleSync();
    }

    private void scheduleSync() {
        // Coalesce queued slider updates and cancel a pending failure retry.
        handler.removeCallbacks(sync);
        handler.post(sync);
    }

    private void syncCurrentUser() {
        try {
            Context context = getContext();
            boolean enabled = Settings.Secure.getIntForUser(context.getContentResolver(),
                    Settings.Secure.NIGHT_DISPLAY_ACTIVATED, 0, currentUser) != 0;
            int defaultTemperature = context.getResources().getInteger(
                    com.android.internal.R.integer.config_nightDisplayColorTemperatureDefault);
            int temperature = Settings.Secure.getIntForUser(context.getContentResolver(),
                    Settings.Secure.NIGHT_DISPLAY_COLOR_TEMPERATURE, defaultTemperature, currentUser);
            int level = NightLightLevel.fromTemperature(enabled, temperature,
                    ColorDisplayManager.getMinimumColorTemperature(context), defaultTemperature,
                    ColorDisplayManager.getMaximumColorTemperature(context));
            String requested = Integer.toString(level);
            if (!requested.equals(SystemProperties.get(PROPERTY))) {
                SystemProperties.set(PROPERTY, requested);
            }
        } catch (RuntimeException error) {
            Log.e("NightLightBridge", "Cannot synchronize Night Light", error);
            handler.removeCallbacks(sync);
            handler.postDelayed(sync, 1000);
        }
    }
}
