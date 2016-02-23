# Cordova plugin for Yozio

This is a [Cordova](http://cordova.apache.org/) plugin for the Yozio mobile app tracking platform.

You can find out more about Yozio here: [https://www.yozio.com](https://www.yozio.com).

This version of the plugin uses versions `2.1.0` (iOS) and `1.1.13` (Android) of the Yozio SDK. Documentation for Yozio SDKs can be found [here for iOS](https://docs.yozio.com/documents/base-sdk-setup--2) and [here for Android](https://docs.yozio.com/documents/base-sdk-setup).

**This version of the plugin should be considered beta and has not yet been tested in all scenarios.**

# Install

To add the plugin to your Cordova project, simply add the plugin from the npm registry. You'll need to specify your app and secret keys via the variables flags. You can obtain your keys from the Yozio console's SDK page. You'll also need to specify the URL scheme used for deep linking to your app.

    cordova plugin add cordova-plugin-yozio --variable YOZIO_APP_KEY=app_key_here --variable YOZIO_APP_SECRET=secret_key_here --variable URL_SCHEME=your_scheme

For an app with all zeros as the keys and a URL deep link scheme of `yourapp://...` the command would look like this:

    cordova plugin add cordova-plugin-yozio --variable YOZIO_APP_KEY=00000000-0000-0000-0000-000000000000 --variable YOZIO_APP_SECRET=00000000-0000-0000-0000-000000000000 --variable URL_SCHEME=yourapp

Alternatively, you can install the latest version of the plugin directly from git:

    cordova plugin add https://github.com/Justin-Credible/cordova-plugin-yozio --variable YOZIO_APP_KEY=app_key_here --variable YOZIO_APP_SECRET=secret_key_here --variable URL_SCHEME=your_scheme

# Usage

The plugin handles hooking the various application events needed to initialize with Yozio as well as capture installation and deep link metadata.

The plugin is available via a global variable named `YozioPlugin`. It exposes the following properties and functions.

All functions accept optional success and failure callbacks as their final two arguments, where the failure callback will receive an error string as an argument unless otherwise noted.

A TypeScript definition file for the JavaScript interface is available in the `typings` directory as well as on [DefinitelyTyped](https://github.com/borisyankov/DefinitelyTyped) via the `tsd` tool.

## Check If New Install

Used to check to see if the current running instance is a new installation of the app.

Method Signature:

`getIsNewInstall(successCallback, failureCallback)`

Example Usage:

    YozioPlugin.getIsNewInstall(function(isNewInstall) {
        console.log("IsNewInstall: " + isNewInstall);
    }

## Get Installation Metadata

Used get the installation metadata from when the application was installed as well as a flag that indicates if the current running instance is a new installation of the app.

Method Signature:

`getInstallMetadata(successCallback, failureCallback)`

Example Usage:

    YozioPlugin.getInstallMetadata(function(installMetadata) {
        console.log("Install Metadata: " + installMetadata);
    }

## Get Deep Link Metadata

Used get the metadata from when the application was launch with a deep link.

Method Signature:

`getLastDeeplinkMetadata(successCallback, failureCallback)`

Example Usage:

    YozioPlugin.getLastDeeplinkMetadata(function(metadata) {
        console.log("Deep Link Metadata: " + metadata);
    }

## User Sign Up Tracking

Used to track a user sign up event.

Method Signature:

`trackSignup(successCallback, failureCallback)`

Example Usage:

    YozioPlugin.trackSignup();

## User Payment Tracking

Used to track a user payment event.

Method Signature:

`trackPayment(amount, successCallback, failureCallback)`

Parameters:

* amount (number): The payment amount to record.

Example Usage:

    YozioPlugin.trackPayment(9.99);

## Custom Event Tracking

Used to track a custom user event.

Method Signature:

`trackEvent(eventName, value, successCallback, failureCallback)`

Parameters:

* eventName (string): The name of the custom event to track.
* value (number): The optional value to track with the event.

Example Usage:

    YozioPlugin.trackEvent("Coupon Code", 10);
    
    YozioPlugin.trackEvent("Account Linked");
