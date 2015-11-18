"use strict";

/*globals */

var exec = require("cordova/exec");

/**
 * The Cordova plugin ID for this plugin.
 */
var PLUGIN_ID = "YozioPlugin";

/**
 * The plugin which will be exported and exposed in the global scope.
 */
var YozioPlugin = {};

/**
 * Used to check to see if the current running instance is a new installation of the app.
 * 
 * @param [function] successCallback - The success callback for this asynchronous function; receives a boolean flag.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
YozioPlugin.getIsNewInstall = function getIsNewInstall(successCallback, failureCallback) {
    exec(successCallback, failureCallback, PLUGIN_ID, "isNewInstall", []);
};

/**
 * Used get the installation metadata from when the application was installed as well as a
 * flag that indicates if the current running instance is a new installation of the app.
 * 
 * @param [function] successCallback - The success callback for this asynchronous function; receives an install metadata object.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
YozioPlugin.getInstallMetadata = function getInstallMetadata(successCallback, failureCallback) {
    exec(successCallback, failureCallback, PLUGIN_ID, "getInstallMetadata", []);
};

/**
 * Used to get the deep link metadata that the application was launched with.
 * 
 * @param [function] successCallback - The success callback for this asynchronous function; receives a metadata dictionary.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
YozioPlugin.getLastDeeplinkMetadata = function getLastDeeplinkMetadata(successCallback, failureCallback) {
    exec(successCallback, failureCallback, PLUGIN_ID, "getLastDeeplinkMetadata", []);
};

/**
 * Used to track a user sign up event.
 * 
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
YozioPlugin.trackSignup = function trackSignup(successCallback, failureCallback) {
    exec(successCallback, failureCallback, PLUGIN_ID, "trackSignup", []);
};

/**
 * Used to track a user payment event.
 * 
 * @param number amount - The payment amount to record.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
YozioPlugin.trackPayment = function trackPayment(amount, successCallback, failureCallback) {

    // Do validation before going over the native code bridge.
    if (typeof(amount) !== "number") {
        setTimeout(function () { failureCallback("An amount (number) is required."); }, 0);
        return;
    }

    exec(successCallback, failureCallback, PLUGIN_ID, "trackPayment", [amount]);
};

/**
 * Used to track a custom user event.
 * 
 * @param string eventName - The name of the custom event to track.
 * @param [number] value - The optional value to track with the event.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
YozioPlugin.trackEvent = function trackEvent(eventName, value, successCallback, failureCallback) {

    // Do validation before going over the native code bridge.
    if (typeof(eventName) !== "string") {
        setTimeout(function () { failureCallback("An event name (string) is required."); }, 0);
        return;
    }

    // If value wasn't provided, default it to zero.
    if (value == null) {
        value = 0;
    }

    // Do validation before going over the native code bridge.
    if (typeof(value) !== "number") {
        setTimeout(function () { failureCallback("Value must be null or a number."); }, 0);
        return;
    }

    exec(successCallback, failureCallback, PLUGIN_ID, "trackEvent", [eventName, value]);
};

module.exports = YozioPlugin;
