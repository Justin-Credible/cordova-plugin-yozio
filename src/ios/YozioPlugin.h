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
- (void)isNewInstall:(CDVInvokedUrlCommand *)command;
- (void)getInstallMetadata:(CDVInvokedUrlCommand *)command;
- (void)getLastDeeplinkMetadata:(CDVInvokedUrlCommand *)command;
- (void)trackSignup:(CDVInvokedUrlCommand *)command;
- (void)trackPayment:(CDVInvokedUrlCommand *)command;
- (void)trackEvent:(CDVInvokedUrlCommand *)command;
@end
