//
//  SSIAppDelegate.m
//  WarrantyManager
//
//  Created by MacOs on 6/13/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIAppDelegate.h"

#import "SSIIPGateway.h"
#import "SSIMyStuffViewController.h"
#import "NotificationPermissionHandler.h"
#import <Crashlytics/Crashlytics.h>
#import <Intercom/Intercom.h>
#import "DDASLLogger.h"
#import "DDTTYLogger.h"

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation SSIAppDelegate

+ (SSIAppDelegate *)sharedDelegate
{
    return (SSIAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configureAppearance];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDLogDebug(@"Showing Debug");
    DDLogInfo(@"Showing Info");
    DDLogError(@"Showing Error");
    
    [Crashlytics startWithAPIKey:@"a8612eae02d0a75c907bb68c09ea8a6e62f2a18e"];
    
    [self checkPermissions];
    
    // Start the Intercom session.  Normally, check if we're started, but
    // since we just finished launching, it's a safe assumption.  This also
    // starts Parse.
    if ([[SSIIPGateway instance] canStartIntercomSession]) {
        [[SSIIPGateway instance] startIntercomSession];
    }
    
    UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {

        self.expiringProductId = localNotification.userInfo[@"product"];
    }



    if ([PFUser currentUser]) {

        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIViewController *viewController = [navigationController.storyboard instantiateViewControllerWithIdentifier:@"myStuffScreen"];
        [navigationController setViewControllers:@[viewController] animated:NO];
        if (![[[[PFInstallation currentInstallation] objectForKey:@"user"] objectId] isEqualToString:[PFUser currentUser].objectId]) {
            [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
        }
    }

    // Override point for customization after application launch.
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[[UIAlertView alloc] initWithTitle:@"" message:notification.alertBody delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:notification.alertAction, nil] show];

    [Intercom logEventWithName:@"product_warrantyalert" completion:nil];

    self.expiringProductId = notification.userInfo[@"product"];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {

        if (self.mystuffViewController) {

            [self.mystuffViewController navigateToProductDetail:self.expiringProductId];
        }
    }
}

-(void)configureAppearance {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

#pragma mark - 
#pragma mark Notifications
- (void)checkPermissions;
{
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if(!error){
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
        }];
    }
    else {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    PFUser *signedInUser = [PFUser currentUser];
    
    if (signedInUser) {
        [currentInstallation setObject:signedInUser forKey:@"user"];
    }
    [currentInstallation setDeviceTokenFromData:deviceToken];
    
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                DDLogDebug(@"Current Installation save error: %@", error);
            }
        });
    }];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
#if TARGET_IPHONE_SIMULATOR
#else
    NSString *errMsg = [NSString stringWithFormat:@"We noticed we can't send you push notifications, you can enable in your device Settings -> Push Notification -> jswipe. Error: %@", [error localizedDescription]];
    [[[UIAlertView alloc] initWithTitle:@"Push Notifications" message:errMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
#endif
}
@end
