package com.yozio;

import java.util.Map;
import java.util.HashMap;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

public final class YozioPlugin extends CordovaPlugin {

    @Override
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {

        /* TODO
        if (action == null) {
            return false;
        }

        if (action.equals("init")) {

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        YozioPlugin.this.init(args, callbackContext);
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
        */
    }

    /*
    private void init(JSONArray args, final CallbackContext callbackContext) throws JSONException {

        // Ensure we have the correct number of arguments.
        if (args.length() != 1) {
            callbackContext.error("A channel ID is required.");
            return;
        }

        // Obtain the arguments.
        String channelId = args.getString(0);

        // Validate the arguments.

        if (channelId == null || channelId.equals("")) {
            callbackContext.error("A channel ID is required.");
        }

        // Delegate to the Yozio API.
        // Yozio.init(this.cordova.getActivity().getApplicationContext(), channelId);
        // callbackContext.success();
        //TODO
    }
    */
}
