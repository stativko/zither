//
//  SSIIPGateway.h
//  WarrantyManager
//
// There are already tons of references to Parse and Intercom spread
// throughout the code.  This is to move some of them to a central place
// for things like dependency managment.  In our use case, a user must be
// present (or at least an email) to initialize Intercom.
// Also, we'd like to test some things independently of the app.  Say,
// unit tests, for example.  This lets us to that.
// 
//  Created by Masa Jow on 2/6/15.
//  Copyright (c) 2015 Ibrahim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSIIPGateway : NSObject

+ (instancetype)instance;

- (BOOL)canStartIntercomSession;

// Returns NO if we couldn't *try* starting the session.  Not if we
// successfully started or not.  Yeah, not the greatest API.  But,
// Intercom returns void, so we can't really know until we try something
// else anyway.
- (BOOL)startIntercomSession;
- (BOOL)startIntercomSessionwithCompletion:(void (^)())completion;

- (void)beginIntercomUserSession:(NSString *)user
                      completion:(void (^)(NSError *))completion;

@property (nonatomic, readonly) BOOL isIntercomSessionStarted;

// This is typically the user data, which is what we populate this with
// if we don't have anything set yet.  In some cases, where there is no
// current user, we set it manually.
@property (nonatomic, strong) NSString *dataToHash;

// Toggles secure mode.  This must be done before any initialization, but
// obviously is safe to do after getting the instance.
@property (nonatomic) BOOL secureMode;

@end
