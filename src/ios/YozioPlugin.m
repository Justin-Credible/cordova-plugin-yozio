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

#pragma mark - Cordova commands

- (void)getIsNewInstall:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isNewInstall];
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

    NSDictionary* metaData = [Yozio getLastDeeplinkMetaDataAsHash];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:metaData];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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
