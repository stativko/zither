//
//  SSIIPGateway.m
//  WarrantyManager
//
//  Created by Masa Jow on 2/6/15.
//  Copyright (c) 2015 Ibrahim. All rights reserved.
//

#import "SSIIPGateway.h"

#import "Intercom.h"
#import <Parse/Parse.h>

NSString * const ParseAppId = @"mMTrB3wQLb8nSlyL3BhQ48rVRfkHefHiFZ5JMqsw";
NSString * const ParseClientKey = @"ptnM4TbedUjnCbxR7tduX7gwnORxIPrYAyg1sL6T";

NSString * const IntercomAppId = @"tkzcha3c";
NSString * const IntercomApiKey = @"ios_sdk-155d0612097f2299cb0c1b56ceaa9182634c97d3";

// Some string constants
NSString * const kParseCloudFunctionName = @"hash_data";
NSString * const kParseCloudFunctionDataParameterKey = @"data";

NSString * const kIntercomSecurityOptionsDataKey = @"data";
NSString * const kIntercomSecurityOptionsHashKey = @"hmac";


@interface SSIIPGateway()

- (void)_setIntercomApiKeyWithData:(NSString *)data
                        hashedData:(NSString *)hashedData;

@property (nonatomic) BOOL isIntercomSessionStarted;

@end


@implementation SSIIPGateway


+ (instancetype)instance
{
    static SSIIPGateway *instance;
    
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[SSIIPGateway alloc] init];
    });
    
    return instance;
}

// Obviously, this isn't really hidden, even though it's not in the .h
// meh.
- (instancetype)init
{
    if ((self = [super init]) != nil) {
        self.isIntercomSessionStarted = NO;
        self.secureMode = YES;

        // Go ahead and start parse.  This might have to be done *after*
        // didFinishLaunching, but in all likelihood, that's already been
        // called, or we're calling this function from there.

        // This is the line of code that needs to be updated:
        [Parse initializeWithConfiguration:[ParseClientConfiguration
                                            configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) { configuration.applicationId = @"mMTrB3wQLb8nSlyL3BhQ48rVRfkHefHiFZ5JMqsw";
                                                // apparently this is no longer needed, but if it is, uncomment this next line:
                                                // configuration.clientKey = @"ptnM4TbedUjnCbxR7tduX7gwnORxIPrYAyg1sL6T";
                                                configuration.server = @"https://zitherapp.herokuapp.com/parse"; }]];

        // taken from: https://github.com/ParsePlatform/parse-server/wiki/Parse-Server-Guide#using-parse-sdks-with-parse-server
        // [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        //    configuration.applicationId = @"YOUR_APP_ID";
        //    configuration.clientKey = @"";
        //    configuration.server = @"http://localhost:1337/parse";
        // }]];
        
        if ([PFUser currentUser] != nil) {
            self.dataToHash = [PFUser currentUser].email;
        }

    }
    
    return self;
}

- (BOOL)canStartIntercomSession
{
    if (self.secureMode)
        return self.dataToHash != nil;
    else
        return YES;
}

- (BOOL)startIntercomSession
{
    return [self startIntercomSessionwithCompletion:nil];
}

- (BOOL)startIntercomSessionwithCompletion:(void (^)())completion
{
    if (![self canStartIntercomSession]) {
        NSLog(@"Attempting to startIntercomSession before it's ready");
        // We shouldn't be calling this function without checking.  Still,
        // not good to silently return;
        return NO;
    }

    if (self.secureMode == NO) {
        // If we're not in secure mode, we can just go ahead and set the api
        // key.
        [self _setIntercomApiKeyWithData:nil
                              hashedData:nil];
        return YES;
    }
    
    NSString *unhashed = self.dataToHash;

    // This actually is more parse than Intercom.  But, we if all the
    // parse stuff clears, then we can do the Intercom.
    [PFCloud
     callFunctionInBackground:kParseCloudFunctionName
               withParameters:@{kParseCloudFunctionDataParameterKey:unhashed}
                        block:^(NSString *hashed, NSError *error) {
                            if (!error) {
                                // Successfully computed hash.
                                [self _setIntercomApiKeyWithData:unhashed
                                                      hashedData:hashed];
                            } else {
                                NSLog(@"Unable to compute remote hash: %@",
                                      error.localizedDescription);
                            }
                            if (completion)
                                completion();
                        }];
    return YES;
}

- (void)beginIntercomUserSession:(NSString *)user
                      completion:(void (^)(NSError *))completion
{
    [Intercom beginSessionForUserWithEmail:user
                                completion:^(NSError *error) {
                                    if (error) {
                                        NSLog(@"Error in beginSessionForUserWithEmail: %@",
                                              error.localizedDescription);
                                    } else {
                                        completion(error);
                                    }
                                }];
   
}

- (void)_setIntercomApiKeyWithData:(NSString *)data
                        hashedData:(NSString *)hashedData
{
    self.isIntercomSessionStarted = NO;

    if (self.secureMode) {
        if ((data == nil) || (hashedData == nil)) {
            NSLog(@"Attempting to set Intercom API key in secure mode without hash data");
            return;
        }
        [Intercom setApiKey:IntercomApiKey
                   forAppId:IntercomAppId
            securityOptions:@{kIntercomSecurityOptionsDataKey:data,
                              kIntercomSecurityOptionsHashKey:hashedData}];
    } else {
        [Intercom setApiKey:IntercomApiKey
                   forAppId:IntercomAppId];
    }

    self.isIntercomSessionStarted = YES;
}

@end
