/// <reference path="cordova-plugin-yozio.d.ts" />
var installMetadata = {
    isNewInstall: true,
    timestamp: 1447869962116,
    yozio_device_id: "00000000-0000-0000-0000-000000000000"
};
var installMetadata2 = {
    isNewInstall: true,
    timestamp: 1447869962116,
    yozio_device_id: "00000000-0000-0000-0000-000000000000",
    yozio_probability: 0.5
};
YozioPlugin.getIsNewInstall();
YozioPlugin.getIsNewInstall(function (isNewInstall) { });
YozioPlugin.getIsNewInstall(function (isNewInstall) { }, function (error) { });
YozioPlugin.getInstallMetadata();
YozioPlugin.getInstallMetadata(function (installMetadata) { });
YozioPlugin.getInstallMetadata(function (installMetadata) { }, function (error) { });
YozioPlugin.getLastDeeplinkMetadata();
YozioPlugin.getLastDeeplinkMetadata(function (metadata) { });
YozioPlugin.getLastDeeplinkMetadata(function (metadata) { }, function (error) { });
YozioPlugin.trackSignup();
YozioPlugin.trackSignup(function () { });
YozioPlugin.trackSignup(function () { }, function (error) { });
YozioPlugin.trackPayment(9.99);
YozioPlugin.trackPayment(9.99, function () { });
YozioPlugin.trackPayment(9.99, function () { }, function (error) { });
YozioPlugin.trackEvent();
YozioPlugin.trackEvent("Event", 42);
YozioPlugin.trackEvent("Event", 42, function () { });
YozioPlugin.trackEvent("Event", 42, function () { }, function (error) { });
