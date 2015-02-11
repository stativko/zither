//
//  SSINotificationManager.h
//  WarrantyManager
//
//  Created by MacOs on 6/24/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

@interface SSINotificationManager : NSObject {

    NSTimer *_timer;
}

@property (nonatomic, strong) NSArray *products;

+ (SSINotificationManager *)sharedManager;

- (void)registerLocalNotifications;

@end
