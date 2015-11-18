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
 * Used to get a flag that indicates if this launch of the application is for a new install.
 * 
 * @param [function] successCallback - The success callback for this asynchronous function; receives a boolean flag.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
YozioPlugin.getIsNewInstall = function getIsNewInstall(successCallback, failureCallback) {
	exec(successCallback, failureCallback, PLUGIN_ID, "isNewInstall", []);
};

/**
 * Used to get the metadata that the application was installed with.
 * 
 * @param [function] successCallback - The success callback for this asynchronous function; receives a metadata object.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
YozioPlugin.getInstallMetadata = function getInstallMetadata(successCallback, failureCallback) {
	exec(successCallback, failureCallback, PLUGIN_ID, "getInstallMetadata", []);
};

/**
 * Used to get the deep link metadata that the application was launched with.
 * 
 * @param [function] successCallback - The success callback for this asynchronous function; receives a metadata object.
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
 * @param [number] amount - The payment amout to record.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
YozioPlugin.trackPayment = function trackPayment(amount, successCallback, failureCallback) {
	exec(successCallback, failureCallback, PLUGIN_ID, "trackPayment", [amount]);
};

/**
 * Used to track a custom user event.
 * 
 * @param [string] eventName - The name of the custom event to track.
 * @param [number] value - The value to track with the event.
 * @param [function] successCallback - The success callback for this asynchronous function.
 * @param [function] failureCallback - The failure callback for this asynchronous function; receives an error string.
 */
YozioPlugin.trackEvent = function trackEvent(eventName, value, successCallback, failureCallback) {
	exec(successCallback, failureCallback, PLUGIN_ID, "trackEvent", [eventName, value]);
};

module.exports = YozioPlugin;
