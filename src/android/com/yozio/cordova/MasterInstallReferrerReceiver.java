package com.yozio.cordova;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.yozio.android.YozioReferrerReceiver;

/**
 * This is the sample code with the best practice for registering multiple
 * receivers for Google Play's Referrer String via broadcast.
 */
public class MasterInstallReferrerReceiver extends BroadcastReceiver{

    @Override
    public void onReceive(Context context, Intent intent) {

        YozioReferrerReceiver yozioReferrerReceiver = new YozioReferrerReceiver();
        yozioReferrerReceiver.onReceive(context, intent);
    }
}
