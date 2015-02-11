//
//  SSINotificationManager.m
//  WarrantyManager
//
//  Created by MacOs on 6/24/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSINotificationManager.h"

#import <Intercom/Intercom.h>

static SSINotificationManager *_notificationManager = nil;

@implementation SSINotificationManager

+ (SSINotificationManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _notificationManager = [[SSINotificationManager alloc] init];

    });

    return _notificationManager;
}

- (id)init
{
    self = [super init];
    if (self) {

//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }

    return self;
}

/*
- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self stopTimer];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self startTimer];
}

- (void)startTimer
{
    double timeInterval = 0.0f;
    [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(handleTimer:) userInfo:nil repeats:NO];
}

- (void)stopTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)handleTimer:(NSTimer *)timer
{
    //
}
*/

- (void)registerLocalNotifications
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    for (PFObject *product in self.products) {

        NSDate *expirationDate = [SSIUtils expireDateFromProduct:product];
        NSDate *purchasedDate = product[@"purchasedOn"];

        double allTime = [expirationDate timeIntervalSinceDate:purchasedDate];
        double currentTime = [expirationDate timeIntervalSinceNow];

        if (currentTime / allTime < 0.3f) {

            [self registerLocalNotificationForProduct:product];
            break;
        }
    }
}

- (void)registerLocalNotificationForProduct:(PFObject *)product
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    dateComponents.hour = 9;
    dateComponents.minute = 0;
    dateComponents.second = 0;

    NSDate *date = nil;
    for (int i = 0; i < 2; i ++) {

        date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
        if ([date timeIntervalSinceNow] > 0) {

            break;
        }

        dateComponents.day ++;
    }

    localNotification.fireDate = date;

    NSString *productName = product[@"productName"];
    if ([productName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {

        productName = @"product";
    }

    NSString *alertString = [NSString stringWithFormat:@"How is your %@ working? Warranty expiring %@!", productName, [SSIUtils stringFromDate:[SSIUtils expireDateFromProduct:product] type:DATETYPE_PRODUCTDETAIL_PURCHASEDON]];
    localNotification.alertBody = alertString;
    localNotification.hasAction = YES;
    localNotification.alertAction = @"View";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.userInfo = @{@"product": product.objectId};

    NSLog(@"Registered local notification %@", localNotification.alertBody);

    [Intercom logEventWithName:@"warranty_expired"
              optionalMetaData:@{@"product_name": productName}
                    completion:nil];

    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
