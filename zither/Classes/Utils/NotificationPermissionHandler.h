//
//  NotificationPermissionHandler.h
//  JSwipe
//
//  Created by Kevin Weiler on 9/22/14.
//

#import <Foundation/Foundation.h>

@interface NotificationPermissionHandler : NSObject
+ (void)checkPermissions;
+ (bool)canSendNotifications;
@end
