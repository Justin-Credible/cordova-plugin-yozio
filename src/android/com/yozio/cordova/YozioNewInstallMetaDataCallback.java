package com.yozio.cordova;

import java.util.HashMap;

import android.content.Context;
import android.util.Log;

import com.yozio.android.Yozio;
import com.yozio.android.interfaces.YozioMetaDataCallbackable;

public class YozioNewInstallMetaDataCallback implements YozioMetaDataCallbackable {

    public YozioNewInstallMetaDataCallback() {}

    public void onCallback(Context context, String targetActivityClassName, HashMap<String, Object> metaData) {

        Log.i("YozioPlugin", "Obtained metadata from a new application install: " + metaData.toString());

        YozioPlugin.setIsNewInstall(true);

        if (targetActivityClassName != null) {
            Yozio.startActivityWithMetaData(context, targetActivityClassName, metaData);
        }
    }
}
