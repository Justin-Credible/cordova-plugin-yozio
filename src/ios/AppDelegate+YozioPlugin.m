//
//  AppDelegate+YozioPlugin.m
//
//  Copyright (c) 2015 Justin Unterreiner. All rights reserved.
//

#import <objc/runtime.h>
#import "AppDelegate.h"
#import "Yozio.h"
#import "YozioPlugin.h"

@implementation AppDelegate(AppDelegate_YozioPlugin)

#pragma mark Helpers

+(void)yozioPlugin_swizzleMethod:(NSString*)originalSelectorString withMethod:(NSString*)swizzledSelectorString andDefaultMethod:(NSString*)defaultSelectorString forClass:(Class)class {

    SEL originalSelector = NSSelectorFromString(originalSelectorString);
    SEL swizzledSelector = NSSelectorFromString(swizzledSelectorString);
    SEL defaultSelector = NSSelectorFromString(defaultSelectorString);

    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    Method defaultMethod = class_getInstanceMethod(class, defaultSelector);

    // First try to add the our method as the original.  Returns YES if it didn't already exist and was added.
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));

    // If we added it, then replace our call with the original name.
    if (didAddMethod) {

        // There might not have been an original method, its optional on the delegate.
        if (originalMethod) {
            
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        }
        else {
            // There is no existing method, just swap in our default below.
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(defaultMethod),
                                method_getTypeEncoding(defaultMethod));
        }
    } else {

        // The method was already there, swap methods.
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark Load

+(void)load {

    // Here we swizzle all of the AppDelegate methods we need to hook for Yozio's SDK.

    [self yozioPlugin_swizzleMethod:@"application:didFinishLaunchingWithOptions:"
                         withMethod:@"yozioPlugin_application:didFinishLaunchingWithOptions:"
                   andDefaultMethod:@"yozioPluginDefault_application:didFinishLaunchingWithOptions:"
                           forClass:[self class]];

    [self yozioPlugin_swizzleMethod:@"application:continueUserActivity:restorationHandler:"
                         withMethod:@"yozioPlugin_application:continueUserActivity:restorationHandler:"
                   andDefaultMethod:@"yozioPluginDefault_application:continueUserActivity:restorationHandler:"
                           forClass:[self class]];

    [self yozioPlugin_swizzleMethod:@"application:openURL:sourceApplication:annotation:"
                         withMethod:@"yozioPlugin_application:openURL:sourceApplication:annotation:"
                   andDefaultMethod:@"yozioPluginDefault_application:openURL:sourceApplication:annotation:"
                           forClass:[self class]];
}

#pragma mark Swizzled Method: application:didFinishLaunchingWithOptions

- (BOOL)yozioPlugin_application:(UIApplication *)application
  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Grab the plugin specific preference values from the plist.
    NSString *appKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"YozioAppKey"];
    NSString *secretKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"YozioSecretKey"];

    // Ensure we have both keys before continuing, or Yozio's SDK will crash.
    if (!appKey || !secretKey) {
        NSLog(@"YozioPlugin: Could not locate a YozioPlugin_AppKey or YozioPlugin_SecretKey in config.xml; Yozio is not active.");

        // Delegate to the original method.
        return [self yozioPlugin_application:application didFinishLaunchingWithOptions:launchOptions];
    }

    // Delegate to the Yozio SDK.
    [Yozio initializeWithAppKey:appKey
                      secretKey:secretKey
     newInstallMetaDataCallback:^(NSDictionary *metaData)
     {
         NSLog(@"YozioPlugin: Obtained metadata from a new application install: %@", metaData);

         [YozioPlugin setIsNewInstall:YES];
     }];

    // Delegate to the original method.
    return [self yozioPlugin_application:application didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)yozioPluginDefault_application:(UIApplication *)application
         didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // No-op.
    return YES;
}

#pragma mark Swizzled Method: application:continueUserActivity:restorationHandler:

- (BOOL)yozioPlugin_application:(UIApplication *)application
           continueUserActivity:(NSUserActivity *)userActivity
             restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {

    if ([NSUserActivityTypeBrowsingWeb isEqualToString: userActivity.activityType]) {

        NSString *enableUniversalLinksPreference = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"YozioIosEnableUniversalLinks"];

        bool enableUniversalLinks = enableUniversalLinksPreference
                && [enableUniversalLinksPreference compare:@"YES" options:NSCaseInsensitiveSearch] == NSOrderedSame;
        
        if (enableUniversalLinks) {

            NSString *universalLinkDomain = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"YozioIosUniversalLinkDomain"];

            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [YozioPlugin setProcessingSemaphore:semaphore];
            [YozioPlugin setWaitOnMetadata:YES];
            
            // Initialization with metadata callback
            [Yozio handleDeeplinkURL:userActivity.webpageURL
               withAssociatedDomains: universalLinkDomain ? @[universalLinkDomain] : @[@"r.yoz.io"]
            deeplinkMetaDataCallback:^(NSDictionary *metaData)
                {
                    NSLog(@"YozioPlugin: Obtained metadata from a deep link: %@", metaData);
                    if ([YozioPlugin getProcessingSemaphore] != nil) {
                        dispatch_semaphore_t semaphore = [YozioPlugin getProcessingSemaphore];
                        [YozioPlugin setWaitOnMetadata:NO];
                        dispatch_semaphore_signal(semaphore);
                    }
                }];

            [YozioPlugin setWasOpenedViaDeepLink: YES];
        }
        else {
            // Track the deep link with Yozio.
            int result = [Yozio handleOpenURL: userActivity.webpageURL];

            [YozioPlugin setWasOpenedViaDeepLink: result == YOZIO_OPEN_URL_TYPE_YOZIO_DEEPLINK];

            // This is a util function to parse meta data from query string,
            // and it will filter out Yozio internal parameters which key starts with "__y".
            NSDictionary *metaData = [Yozio getMetaDataFromDeeplink:userActivity.webpageURL];

            NSLog(@"YozioPlugin: Obtained metadata from a deep link: %@", metaData);
        }
    }

    // Delegate to the original method.
    return [self yozioPlugin_application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
}

- (BOOL)yozioPluginDefault_application:(UIApplication *)application
                  continueUserActivity:(NSUserActivity *)userActivity
                    restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    // No-op.
    return YES;
}

#pragma mark Swizzled Method: application:openURL:sourceApplication:annotation:

- (BOOL)yozioPlugin_application:(UIApplication *)application
                        openURL:(NSURL *)url
              sourceApplication:(NSString *)sourceApplication
                     annotation:(id)annotation {

    // If we already handled the deep link in continueUserActivity,
    // just run the original method and bail.
    if ([YozioPlugin wasOpenedViaDeepLink]) {
        return [self yozioPlugin_application:application
                                     openURL:url
                           sourceApplication:sourceApplication
                                  annotation:annotation];
    }
    
    // Track the deep link with Yozio.
    int result = [Yozio handleOpenURL: url];

    [YozioPlugin setWasOpenedViaDeepLink: result == YOZIO_OPEN_URL_TYPE_YOZIO_DEEPLINK];
    
    // This is a util function to parse meta data from query string,
    // and it will filter out Yozio internal parameters which key starts with "__y".
    NSDictionary *metaData = [Yozio getMetaDataFromDeeplink:url];

    NSLog(@"YozioPlugin: Obtained metadata from a deep link: %@", metaData);

    // Delegate to the original method.
    return [self yozioPlugin_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

- (BOOL)yozioPluginDefault_application:(UIApplication *)application
                               openURL:(NSURL *)url
                     sourceApplication:(NSString *)sourceApplication
                            annotation:(id)annotation {
    // No-op.
    return YES;
}

@end
