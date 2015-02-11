//
//  WMAppDelegate.m
//  WarrantyManager
//
//  Created by MacOs on 6/13/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "WMAppDelegate.h"

#import "WMIPGateway.h"
#import "WMMyStuffViewController.h"

#import <Intercom/Intercom.h>

@implementation WMAppDelegate

+ (WMAppDelegate *)sharedDelegate
{
    return (WMAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Start the Intercom session.  Normally, check if we're started, but
    // since we just finished launching, it's a safe assumption.  This also
    // starts Parse.
    if ([[WMIPGateway instance] canStartIntercomSession]) {
        [[WMIPGateway instance] startIntercomSession];
    }
    
    UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotification) {

        self.expiringProductId = localNotification.userInfo[@"product"];
    }

    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    if ([PFUser currentUser]) {

        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        UIViewController *viewController = [navigationController.storyboard instantiateViewControllerWithIdentifier:@"myStuffScreen"];
        [navigationController setViewControllers:@[viewController] animated:NO];
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

@end
