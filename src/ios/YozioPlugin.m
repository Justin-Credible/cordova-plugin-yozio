//
//  YozioPlugin.m
//
//  Copyright (c) 2015 Justin Unterreiner. All rights reserved.
//

#import "YozioPlugin.h"
#import <objc/runtime.h>
#import "Yozio.h"

@interface YozioPlugin()

+ (BOOL)isNewInstall;
+ (void)setIsNewInstall:(BOOL)isNewInstall;
+ (dispatch_semaphore_t)getProcessingSemaphore;
+ (void)setProcessingSemaphore:(dispatch_semaphore_t)semaphore;

+ (BOOL)wasOpenedViaDeepLink;
+ (void)setWasOpenedViaDeepLink:(BOOL)openedViaDeepLink;

@end

@implementation YozioPlugin

#pragma mark - Static Properties

static BOOL isNewInstall = NO;

+ (BOOL)isNewInstall;
{
    return isNewInstall;
}

+ (void)setIsNewInstall:(BOOL)newInstall {
    isNewInstall = newInstall;
}

static BOOL wasOpenedViaDeepLink = NO;

+ (BOOL)wasOpenedViaDeepLink;
{
    return wasOpenedViaDeepLink;
}

+ (void)setWasOpenedViaDeepLink:(BOOL)openedViaDeepLink {
    wasOpenedViaDeepLink = openedViaDeepLink;
}

static dispatch_semaphore_t processingSemaphore;

+ (dispatch_semaphore_t)getProcessingSemaphore
{
    return processingSemaphore;
}

+ (void)setProcessingSemaphore:(dispatch_semaphore_t)semaphore
{
    processingSemaphore = semaphore;
}

#pragma mark - Plugin Initialization

- (void)pluginInitialize {

    processingSemaphore = dispatch_semaphore_create(0);

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(application_enterBackground)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

#pragma mark - Notifications

- (void)application_enterBackground {

    // Once the application has been backgrounded, set the flag to false. This allows
    // us to determine if the application was launched again via a deep link on the
    // next app resume.
    wasOpenedViaDeepLink = false;
}

#pragma mark - Cordova commands

- (void)getIsNewInstall:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isNewInstall];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getWasOpenedViaDeepLink:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:wasOpenedViaDeepLink];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getInstallMetadata:(CDVInvokedUrlCommand *)command {

    // Delegate to the Yozio SDK.
    NSDictionary* metaData = [Yozio getNewInstallMetaDataAsHash];

    // Add a "isNewInstall" flag to the metadata for convenience so only one call has to
    // be made to get both the metadata and this flag.
    NSMutableDictionary *extendedMetaData = [metaData mutableCopy];
    [extendedMetaData setValue:@(isNewInstall) forKey:@"isNewInstall"];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:extendedMetaData];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getLastDeeplinkMetadata:(CDVInvokedUrlCommand *)command {

    [self.commandDelegate runInBackground:^{

        // Wait on the Yozio call 'handleDeeplinkURL' (found in AppDelegate+YozioPlugin.m)
        // to complete before continuing.
        // Calls to getLastDeeplinkMetaDataAsHash will not return data until this completes.
        // Timeout of 5 seconds to ensure we never get a deadlock.
        if (processingSemaphore != nil)
        {
            dispatch_semaphore_wait(processingSemaphore, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
        }

        NSDictionary* metaData = [Yozio getLastDeeplinkMetaDataAsHash];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:metaData];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)trackSignup:(CDVInvokedUrlCommand *)command {

    // Delegate to the Yozio SDK.
    [self.commandDelegate runInBackground:^{
        [Yozio trackSignup];
    }];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)trackPayment:(CDVInvokedUrlCommand *)command {

    // Ensure we have the correct number of arguments.
    if ([command.arguments count] != 1) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"An amount is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    // Obtain the arguments.
    NSNumber* amount = [command.arguments objectAtIndex:0];

    // Validate the arguments.
    if (!amount) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"An amount is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    // Delegate to the Yozio SDK.
    [self.commandDelegate runInBackground:^{
        [Yozio trackPayment:[amount doubleValue]];
    }];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)trackEvent:(CDVInvokedUrlCommand *)command {

    // Ensure we have the correct number of arguments.
    if ([command.arguments count] != 2) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"An event name and amount are required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    // Obtain the arguments.
    NSString* eventName = [command.arguments objectAtIndex:0];
    NSNumber* value = [command.arguments objectAtIndex:1];

    // Validate the arguments.

    if (!eventName) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"An event name is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    if (!value) {
        CDVPluginResult *res = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"A value is required."];
        [self.commandDelegate sendPluginResult:res callbackId:command.callbackId];
        return;
    }

    // Delegate to the Yozio SDK.
    [self.commandDelegate runInBackground:^{
        [Yozio trackCustomEventWithName:eventName andValue:[value doubleValue]];
    }];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
