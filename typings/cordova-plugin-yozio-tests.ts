/// <reference path="cordova-plugin-yozio.d.ts" />

var installMetadata: YozioPlugin.InstallMetadata = {
    isNewInstall: true,
    timestamp: 1447869962116,
    yozio_device_id: "00000000-0000-0000-0000-000000000000"
};

var installMetadata2: YozioPlugin.InstallMetadata = {
    isNewInstall: true,
    timestamp: 1447869962116,
    yozio_device_id: "00000000-0000-0000-0000-000000000000",
    yozio_probability: 0.5
};

YozioPlugin.getIsNewInstall();
YozioPlugin.getIsNewInstall((isNewInstall: boolean) => {});
YozioPlugin.getIsNewInstall((isNewInstall: boolean) => {}, (error: string) => {});

YozioPlugin.getInstallMetadata();
YozioPlugin.getInstallMetadata((installMetadata: YozioPlugin.InstallMetadata) => {});
YozioPlugin.getInstallMetadata((installMetadata: YozioPlugin.InstallMetadata) => {}, (error: string) => {});

YozioPlugin.getLastDeeplinkMetadata();
YozioPlugin.getLastDeeplinkMetadata((metadata: { [id: string]: string }) => {});
YozioPlugin.getLastDeeplinkMetadata((metadata: { [id: string]: string }) => {}, (error: string) => {});

YozioPlugin.trackSignup();
YozioPlugin.trackSignup(() => {});
YozioPlugin.trackSignup(() => {}, (error: string) => {});

YozioPlugin.trackPayment(9.99);
YozioPlugin.trackPayment(9.99, () => {});
YozioPlugin.trackPayment(9.99, () => {}, (error: string) => {});

YozioPlugin.trackEvent("Event");
YozioPlugin.trackEvent("Event", 42);
YozioPlugin.trackEvent("Event", 42, () => {});
YozioPlugin.trackEvent("Event", 42, () => {}, (error: string) => {});
