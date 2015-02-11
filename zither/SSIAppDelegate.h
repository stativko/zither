//
//  SSIAppDelegate.h
//  WarrantyManager
//
//  Created by MacOs on 6/13/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSIMyStuffViewController;

@interface SSIAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

+ (SSIAppDelegate *)sharedDelegate;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSString *expiringProductId;
@property (nonatomic, strong) SSIMyStuffViewController *mystuffViewController;

@end
