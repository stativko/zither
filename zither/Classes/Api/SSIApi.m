//
//  SSIApi.m
//  WarrantyManager
//
//  Created by MacOs on 6/15/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIApi.h"
#import "AFNetworking.h"
#import <Parse/Parse.h>

#define BASEURL @"https://api.semantics3.com/test/v1"       // api url
//#define APIKEY @"SEM3E892B8487C7EA8267E1B0C8CE8345157"      // api key
//#define APIKEY @"SEM33906B6C37FC2A1AAE71EFE8AFB1536B1"      // api key
#define APIKEY @"SEM34E7A133DBAF72F4F4F343C54BD0EF192"      // api key

@implementation SSIApi

+ (instancetype)sharedClient {
    static SSIApi *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SSIApi alloc] initWithBaseURL:[NSURL URLWithString:BASEURL]];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
        [_sharedClient.requestSerializer setValue:APIKEY forKey:@"api_key"];
//        [_sharedClient setDefaultHeader:@"api_key" value:APIKEY];

    });
    
    return _sharedClient;
}


+ (void)getProductDetailFromUPC:(NSString *)code
                        success:(void (^)(NSArray *products))success
                        failure:(void (^)(NSString *error))failure
{
#ifdef TESTMODE
    {
        /* testing purpose */
        NSString *responseString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"response_upc" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];

        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

        NSMutableArray *products = [NSMutableArray array];
        for (NSDictionary *dict in responseDict[@"results"]) {

            [products addObject:[self objectFromProductDict:dict]];
        }

        if ([products count] > 0) {

            success(products);
        }
        else {

            failure(@"No products found");
        }

        return;
    }
#endif

//    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:BASEURL]];
//    [client setDefaultHeader:@"api_key" value:APIKEY];

    // constructing query
    NSDictionary *parameters = @{@"upc": code};
    NSString *query = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[[SSIApi sharedClient] requestSerializer] requestWithMethod:@"GET" URLString:@"products" parameters:@{@"q": query} error:nil];
    AFHTTPRequestOperation *httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        // return result
//        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//
//        [[[UIAlertView alloc] initWithTitle:@"API Response" message:responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];

        NSMutableArray *products = [NSMutableArray array];
        for (NSDictionary *dict in responseDict[@"results"]) {

            [products addObject:[self objectFromProductDict:dict]];
        }

        if ([products count] > 0) {

            success(products);
        }
        else {

            failure(@"No products found");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        failure(@"Error occurred");
    }];

    [httpOperation start];
}

+ (void)getProductDetailFromText:(NSString *)text
                         success:(void (^)(NSArray *products))success
                         failure:(void (^)(NSString *error))failure
{
#ifdef TESTMODE
    {
        /* testing purpose */
        NSString *responseString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"response_text" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];

        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

        NSMutableArray *products = [NSMutableArray array];
        for (NSDictionary *dict in responseDict[@"results"]) {

            [products addObject:[self objectFromProductDict:dict]];
        }

        if ([products count] > 0) {

            success(products);
        }
        else {

            failure(@"No products found");
        }

        return;
    }
#endif

//    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:BASEURL]];
//    [client setDefaultHeader:@"api_key" value:APIKEY];

    // constructing query
    NSDictionary *parameters = @{@"search": text};
    NSString *query = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[[SSIApi sharedClient] requestSerializer] requestWithMethod:@"GET" URLString:@"products" parameters:@{@"q": query} error:nil];

    AFHTTPRequestOperation *httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        // return result
//        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//
//        [[[UIAlertView alloc] initWithTitle:@"API Response" message:responseString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];

        NSMutableArray *products = [NSMutableArray array];
        for (NSDictionary *dict in responseDict[@"results"]) {

            [products addObject:[self objectFromProductDict:dict]];
        }

        if ([products count] > 0) {

            success(products);
        }
        else {

            failure(@"No products found");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        failure(@"Error occurred");
    }];

    [httpOperation start];
}

+ (PFObject *)objectFromProductDict:(NSDictionary *)dict
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *api_response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    PFObject *object = [PFObject objectWithClassName:kProductClassName];

    object[@"productName"] = dict[@"name"];
    object[@"purchasedOn"] = [NSDate date];
    object[@"warrantyYear"] = @1;
    object[@"api_response"] = api_response;

    NSArray *images = dict[@"images"];
    if ([images count] > 0) {

        object[@"productImageUrl"] = [images firstObject];
    }

/*
    if ([dict[@"sitedetails"] count] > 0) {

        object[@"productURL"] = [dict[@"sitedetails"] firstObject][@"url"];
    }
*/
    return object;
}

@end
