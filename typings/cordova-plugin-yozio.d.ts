// Type definitions for cordova-plugin-yozio 1.0.3
// Project: https://github.com/Justin-Credible/cordova-plugin-yozio
// Definitions by: Justin Unterreiner <https://github.com/Justin-Credible>
// Definitions: https://github.com/borisyankov/DefinitelyTyped

declare module YozioPlugin {

    interface YozioStatic {

        /**
         * Used to check to see if the current running instance is a new installation of the app.
         * 
         * @param successCallback The success callback for this asynchronous function; receives a boolean flag.
         * @param failureCallback The failure callback for this asynchronous function; receives an error string.
         */
        getIsNewInstall(successCallback?: (isNewInstall: boolean) => void, failureCallback?: (error: string) => void): void;

        /**
         * Used to check to see if the current running instance was launched via a deep link.
         * 
         * @param successCallback The success callback for this asynchronous function; receives a boolean flag.
         * @param failureCallback The failure callback for this asynchronous function; receives an error string.
         */
        getWasOpenedViaDeepLink(successCallback?: (wasOpenedViaDeepLink: boolean) => void, failureCallback?: (error: string) => void): void;

        /**
         * Used get the installation metadata from when the application was installed as well as a
         * flag that indicates if the current running instance is a new installation of the app.
         * 
         * @param successCallback The success callback for this asynchronous function; receives an install metadata object.
         * @param failureCallback The failure callback for this asynchronous function; receives an error string.
         */
        getInstallMetadata(successCallback?: (installMetadata: InstallMetadata) => void, failureCallback?: (error: string) => void): void;

        /**
         * Used get the metadata from when the application was launch with a deep link.
         * 
         * @param successCallback The success callback for this asynchronous function; receives a metadata dictionary.
         * @param failureCallback The failure callback for this asynchronous function; receives an error string.
         */
        getLastDeeplinkMetadata(successCallback?: (metadata: { [id: string]: string }) => void, failureCallback?: (error: string) => void): void;

        /**
         * Used to track a user sign up event.
         * 
         * @param successCallback The success callback for this asynchronous function.
         * @param failureCallback The failure callback for this asynchronous function; receives an error string.
         */
        trackSignup(successCallback?: () => void, failureCallback?: (error: string) => void): void;

        /**
         * Used to track a user payment event.
         * 
         * @param amount The payment amount to record.
         * @param successCallback The success callback for this asynchronous function.
         * @param failureCallback The failure callback for this asynchronous function; receives an error string.
         */
        trackPayment(amount: number, successCallback?: () => void, failureCallback?: (error: string) => void): void;

        /**
         * Used to track a custom user event.
         * 
         * @param eventName The name of the custom event to track.
         * @param value The optional value to track with the event.
         * @param successCallback The success callback for this asynchronous function.
         * @param failureCallback The failure callback for this asynchronous function; receives an error string.
         */
        trackEvent(eventName: string, value?: number, successCallback?: () => void, failureCallback?: (error: string) => void): void;
    }

    interface InstallMetadata {

        /**
         * Indicates if the current running instance is a new installation of the app.
         */
        isNewInstall: boolean;

        /**
         * The time at which the application was installed.
         * 
         * Integer value representing the number of milliseconds since 1 January 1970 00:00:00 UTC (Unix Epoch).
         */
        timestamp: number;

        /**
         * Yozio's unique identifier for this device.
         */
        yozio_device_id: string;

        /**
         * This value represents the probability that the new install comes from a click event.
         * 
         * If the value of this parameter is negative, or not there, a new install match was not
         * found, and there is likely something wrong with the integration.
         * 
         * If you are using iOS 100% matching using SafariViewController, this parameter will
         * not be present.
         */
        yozio_probability?: number;
    }
}

declare var YozioPlugin: YozioPlugin.YozioStatic;
