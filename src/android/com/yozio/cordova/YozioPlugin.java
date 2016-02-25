package com.yozio.cordova;

import android.content.Intent;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.yozio.android.Yozio;

import java.util.HashMap;

public final class YozioPlugin extends CordovaPlugin {

    private static boolean isNewInstall = false;

    public static void setIsNewInstall(boolean value) {
        isNewInstall = value;
    }

    private static boolean wasOpenedViaDeepLink = false;

    @Override
    protected void pluginInitialize() {
        Yozio.YOZIO_ENABLE_LOGGING = true;
        Yozio.YOZIO_READ_TIMEOUT = 7000;
        Yozio.initialize(cordova.getActivity());
    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        HashMap<String, Object> deepLinkMetadata = Yozio.getMetaData(intent);
        
        wasOpenedViaDeepLink = deepLinkMetadata != null && deepLinkMetadata.size() > 0;
    }

    @Override
    public void onPause(boolean multitasking) {
        wasOpenedViaDeepLink = false;
    }

    @Override
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {

        if (action == null) {
            return false;
        }

        if (action.equals("getIsNewInstall")) {

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        YozioPlugin.this.getIsNewInstall(callbackContext);
                    }
                    catch (Exception exception) {
                        callbackContext.error("YozioPlugin uncaught exception: " + exception.getMessage());
                    }
                }
            });

            return true;
        }
        else if (action.equals("getWasOpenedViaDeepLink")) {

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        YozioPlugin.this.getWasOpenedViaDeepLink(callbackContext);
                    }
                    catch (Exception exception) {
                        callbackContext.error("YozioPlugin uncaught exception: " + exception.getMessage());
                    }
                }
            });

            return true;
        }
        else if (action.equals("getInstallMetadata")) {

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        YozioPlugin.this.getInstallMetadata(callbackContext);
                    }
                    catch (Exception exception) {
                        callbackContext.error("YozioPlugin uncaught exception: " + exception.getMessage());
                    }
                }
            });

            return true;
        }
        else if (action.equals("getLastDeeplinkMetadata")) {

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        YozioPlugin.this.getLastDeeplinkMetadata(callbackContext);
                    }
                    catch (Exception exception) {
                        callbackContext.error("YozioPlugin uncaught exception: " + exception.getMessage());
                    }
                }
            });

            return true;
        }
        else if (action.equals("trackSignup")) {

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        YozioPlugin.this.trackSignup(callbackContext);
                    }
                    catch (Exception exception) {
                        callbackContext.error("YozioPlugin uncaught exception: " + exception.getMessage());
                    }
                }
            });

            return true;
        }
        else if (action.equals("trackPayment")) {

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        YozioPlugin.this.trackPayment(args, callbackContext);
                    }
                    catch (Exception exception) {
                        callbackContext.error("YozioPlugin uncaught exception: " + exception.getMessage());
                    }
                }
            });

            return true;
        }
        else if (action.equals("trackEvent")) {

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        YozioPlugin.this.trackEvent(args, callbackContext);
                    }
                    catch (Exception exception) {
                        callbackContext.error("YozioPlugin uncaught exception: " + exception.getMessage());
                    }
                }
            });

            return true;
        }
        else {
            // The given action was not handled above.
            return false;
        }
    }

    private void getIsNewInstall(final CallbackContext callbackContext) throws JSONException {
        callbackContext.success(Boolean.toString(isNewInstall));
    }

    private void getWasOpenedViaDeepLink(final CallbackContext callbackContext) throws JSONException {
        callbackContext.success(Boolean.toString(wasOpenedViaDeepLink));
    }

    private void getInstallMetadata(final CallbackContext callbackContext) throws JSONException {

        // Delegate to the Yozio SDK.
        HashMap<String, Object> metadata = Yozio.getInstallMetaDataAsHash(cordova.getActivity().getApplicationContext());

        // Add a "isNewInstall" flag to the metadata for convenience so only one call has to
        // be made to get both the metadata and this flag.
        metadata.put("isNewInstall", isNewInstall);

        callbackContext.success(new JSONObject(metadata));
    }

    private void getLastDeeplinkMetadata(final CallbackContext callbackContext) throws JSONException {

        // Delegate to the Yozio SDK.
        HashMap<String, Object> metadata = Yozio.getLastDeeplinkMetaDataAsHash(cordova.getActivity().getApplicationContext());

        callbackContext.success(new JSONObject(metadata));
    }

    private void trackSignup(final CallbackContext callbackContext) throws JSONException {

        // Delegate to the Yozio API.
        Yozio.trackSignUp(cordova.getActivity().getApplicationContext());

        callbackContext.success();
    }

    private void trackPayment(JSONArray args, final CallbackContext callbackContext) throws JSONException {

        // Ensure we have the correct number of arguments.
        if (args.length() != 1) {
            callbackContext.error("An amount is required.");
            return;
        }

        // Obtain the arguments.
        double amount = args.getDouble(0);

        // Delegate to the Yozio API.
        Yozio.trackPayment(cordova.getActivity().getApplicationContext(), amount);

        callbackContext.success();
    }

    private void trackEvent(JSONArray args, final CallbackContext callbackContext) throws JSONException {

        // Ensure we have the correct number of arguments.
        if (args.length() != 2) {
            callbackContext.error("An event name and amount are required.");
            return;
        }

        // Obtain the arguments.
        String eventName = args.getString(0);
        double value = args.getDouble(1);

        // Validate the arguments.

        if (eventName == null || eventName.equals("")) {
            callbackContext.error("An event name is required.");
        }

        // Delegate to the Yozio API.
        Yozio.trackCustomEvent(cordova.getActivity().getApplicationContext(), eventName, value);

        callbackContext.success();
    }
}
