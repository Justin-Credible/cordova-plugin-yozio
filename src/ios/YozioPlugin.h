//
//  YozioPlugin.h
//
//  Copyright (c) 2015 Justin Unterreiner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import "YozioPlugin.h"

@interface YozioPlugin : CDVPlugin

+ (void)setIsNewInstall:(BOOL)isNewInstall;
+ (void)setWasOpenedViaDeepLink:(BOOL)isNewInstall;
+ (dispatch_semaphore_t)getProcessingSemaphore;
+ (void)setProcessingSemaphore:(dispatch_semaphore_t)semaphore;
+ (void)setWaitOnMetadata:(BOOL)wait;
+ (BOOL)wasOpenedViaDeepLink;

- (void)getIsNewInstall:(CDVInvokedUrlCommand *)command;
- (void)getWasOpenedViaDeepLink:(CDVInvokedUrlCommand *)command;
- (void)getInstallMetadata:(CDVInvokedUrlCommand *)command;
- (void)getLastDeeplinkMetadata:(CDVInvokedUrlCommand *)command;
- (void)trackSignup:(CDVInvokedUrlCommand *)command;
- (void)trackPayment:(CDVInvokedUrlCommand *)command;
- (void)trackEvent:(CDVInvokedUrlCommand *)command;

@end
