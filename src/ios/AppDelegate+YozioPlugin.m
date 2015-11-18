//
//  AppDelegate+YozioPlugin.m
//
//  Copyright (c) 2015 Justin Unterreiner. All rights reserved.
//

#import <objc/runtime.h>
#import "../../../CordovaLib/Classes/CDVConfigParser.h"
#import "AppDelegate.h"
#import "Yozio.h"
#import "YozioPlugin.h"

@implementation AppDelegate(AppDelegate_YozioPlugin)

#pragma mark Helpers

+(void)swizzleMethod:(NSString*)originalSelectorString withMethod:(NSString*)swizzledSelectorString andDefaultMethod:(NSString*)defaultSelectorString forClass:(Class)class {

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        SEL originalSelector = NSSelectorFromString(originalSelectorString);// @selector(presentViewController:animated:completion:);
        SEL swizzledSelector = NSSelectorFromString(swizzledSelectorString);//@selector(fixSelectPopover_presentViewController:animated:completion:);
        SEL defaultSelector = NSSelectorFromString(defaultSelectorString);//@selector(defaultfixSelectPopover_presentViewController:animated:completion:);
        
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
    });
}

#pragma mark Load

+(void)load {
    
    // Here we swizzle all of the AppDelegate methods we need to hook for Yozio's SDK.

    [self swizzleMethod:@"application:didFinishLaunchingWithOptions:"
             withMethod:@"yozioPlugin_application:didFinishLaunchingWithOptions:"
       andDefaultMethod:@"yozioPluginDefault_application:didFinishLaunchingWithOptions:"
               forClass:[self class]];

    [self swizzleMethod:@"application:continueUserActivity:restorationHandler:"
             withMethod:@"yozioPlugin_application:continueUserActivity:restorationHandler:"
       andDefaultMethod:@"yozioPluginDefault_application:continueUserActivity:restorationHandler:"
               forClass:[self class]];

    [self swizzleMethod:@"application:openURL:sourceApplication:annotation:"
             withMethod:@"yozioPlugin_application:openURL:sourceApplication:annotation:"
       andDefaultMethod:@"yozioPluginDefault_application:openURL:sourceApplication:annotation:"
               forClass:[self class]];
}

#pragma mark Swizzled Method: application:didFinishLaunchingWithOptions

- (BOOL)yozioPlugin_application:(UIApplication *)application
  didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    CDVConfigParser* configParserDelegate = [[CDVConfigParser alloc] init];

    // Build the path to the config.xml file located in the app bundle.
    NSString* path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"xml"];

    // Ensure the config.xml file exists.
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"YozioPlugin: Could not locate config.xml to load Yozio keys from; Yozio is not active.");
        
        // Delegate to the original method.
        return [self yozioPlugin_application:application didFinishLaunchingWithOptions:launchOptions];
    }

    // Instantiate an XML parser for config.xml.
    NSURL* url = [NSURL fileURLWithPath:path];
    NSXMLParser* configParser = [[NSXMLParser alloc] initWithContentsOfURL:url];

    // Ensure we were able to instantiate the XML parser.
    if (configParser == nil) {
        NSLog(@"YozioPlugin: Failed to initialize XML parser; Yozio is not active.");
        
        // Delegate to the original method.
        return [self yozioPlugin_application:application didFinishLaunchingWithOptions:launchOptions];
    }

    // Now parse config.xml.
    [configParser setDelegate:((id < NSXMLParserDelegate >)configParserDelegate)];
    [configParser parse];

    // Grab the plugin specific preference values from config.xml.
    NSString *appKey = [configParserDelegate.settings objectForKey:@"yozioplugin_appkey"];
    NSString *secretKey = [configParserDelegate.settings objectForKey:@"yozioplugin_secretkey"];

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

        // Track the deep link with Yozio.
        [Yozio handleOpenURL: userActivity.webpageURL];

        // This is a util function to parse meta data from query string,
        // and it will filter out Yozio internal parameters which key starts with "__y".
        NSDictionary *metaData = [Yozio getMetaDataFromDeeplink:userActivity.webpageURL];

        NSLog(@"YozioPlugin: Obtained metadata from a deep link: %@", metaData);
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

    // Track the deep link with Yozio.
    [Yozio handleOpenURL: url];
    
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
