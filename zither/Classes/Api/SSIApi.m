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

@implementation SSIApi

+ (instancetype)sharedClient {
    static SSIApi *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SSIApi alloc] initWithBaseURL:[NSURL URLWithString:BASEURL]];
        [_sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
        [_sharedClient.requestSerializer setValue:SSI_PARSE_API forHTTPHeaderField:@"api_key"];
//        [_sharedClient setDefaultHeader:@"api_key" value:APIKEY];

    });
    
    return _sharedClient;
}

+ (void)searchVerifiedProductsWithContext:(SSIProductSearchResults *)context
                               completion:(void (^)(NSString *error))completion {
    completion(nil);
}

+ (void)searchUserProductsWithContext:(SSIProductSearchResults *)context
                              completion:(void (^)(NSString *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:kUserProductClassName];
    [query whereKey:@"barcode" equalTo:context.searchTerm];
    [query orderByDescending:@"numShares"];
    [query setLimit:20];
//    [query selectKeys:@""] TODO select keys for privacy
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error && [error.userInfo objectForKey:@"error"]) {
            completion([error.userInfo objectForKey:@"error"]);
        } else {
            if (objects.count) {
                NSMutableArray *productsToReturn = [NSMutableArray new];
                for (PFObject *product in objects) {
                    BOOL hasManual = NO;
                    BOOL hasCustService = NO;

                    if (product[@"manual"] || product[@"manual_url"]) {
                        hasManual = YES;
                    }
                    if (product[@"customerService"] || product[@"customerService_url"]) {
                        hasCustService = YES;
                    }
                    
                    if (hasManual && hasCustService) {
                        [productsToReturn setArray:@[product]];
                        break;
                    } else if (hasManual || hasCustService) {
                        [productsToReturn addObject:product];
                    }
                }
                if (productsToReturn.count >=2) {
                    productsToReturn = [[productsToReturn subarrayWithRange:NSMakeRange(0, 2)] mutableCopy];
                }
                if (productsToReturn.count == 0 && objects.count) {
                    [productsToReturn addObject:objects[0]];
                }
                context.userProducts = productsToReturn;
            }
            completion(nil);
        }
    }];
}

+ (void)searchSemanticsWithContext:(SSIProductSearchResults *)context
                        completion:(void (^)(NSString *error))completion {
    
    // constructing query
    NSDictionary *parameters = @{@"gtins": context.searchTerm};
    NSString *query = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", BASEURL, @"products"];
    NSMutableURLRequest *request = [[[SSIApi sharedClient] requestSerializer] requestWithMethod:@"GET" URLString:urlString parameters:@{@"q": query} error:nil];
    
    AFHTTPRequestOperation *httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSMutableArray *products = [NSMutableArray array];
        NSLog(@"results from semantic %@", responseDict);
        for (NSDictionary *dict in responseDict[@"results"]) {
            PFObject *newProd = [self objectFromProductDict:dict];
            newProd[@"barcode"] = context.searchTerm;
            [products addObject:newProd];
        }
        context.semanticsProducts = products;
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(@"Error occurred");
    }];
    
    [httpOperation start];
}

+ (void)getProductDetailFromUPC:(NSString *)code
                        success:(void (^)(SSIProductSearchResults *product))success
                        failure:(void (^)(NSString *error))failure
{
    if (code.length ==0) {
        failure(@"Could not read code.");
    }
    
    SSIProductSearchResults *results = [[SSIProductSearchResults alloc] initWithSearchTerm:[code uppercaseString]];
    [SSIApi searchUserProductsWithContext:results completion:^(NSString *error) {
        if (error) {
            // todo determine if retryable error
            failure(error);
        } else if ( results.verifiedProducts.count || results.userProducts.count) {
            success(results);
        } else {
            [SSIApi searchSemanticsWithContext:results completion:^(NSString *error) {
                if (error) {
                    failure(error);
                } else {
                    success(results);
                }
            }];
        }
    }];
}

+ (void)getProductDetailFromText:(NSString *)text
                         success:(void (^)(SSIProductSearchResults *products))success
                         failure:(void (^)(NSString *error))failure
{

//    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:BASEURL]];
//    [client setDefaultHeader:@"api_key" value:APIKEY];

    // constructing query
    NSDictionary *parameters = @{@"search": text};
    NSString *query = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil] encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *request = [[[SSIApi sharedClient] requestSerializer] requestWithMethod:@"GET" URLString:@"products" parameters:@{@"q": query} error:nil];

    AFHTTPRequestOperation *httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];

        NSMutableArray *products = [NSMutableArray array];
        for (NSDictionary *dict in responseDict[@"results"]) {
            PFObject *newProd =[self objectFromProductDict:dict];
            [products addObject:newProd];
        }
        SSIProductSearchResults *context = [[SSIProductSearchResults alloc] initWithSearchTerm:text];
        context.semanticsProducts = products;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        failure(@"Error occurred");
    }];

    [httpOperation start];
}

+ (PFObject *)objectFromProductDict:(NSDictionary *)dict
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *api_response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    PFObject *object = [PFObject objectWithClassName:kUserProductClassName];
    if (dict[@"barcode"]) {
        object[@"barcode"] = dict[@"barcode"];
    }
    if (dict[@"name"]) {
        object[@"productName"] = dict[@"name"];
    }
    object[@"purchasedOn"] = [NSDate date];
    object[@"warrantyYear"] = @1;
    object[@"api_response"] = api_response;

    NSArray *images = dict[@"images"];
    if ([images count] > 0) {

        object[@"productImageUrl"] = [images firstObject];
    }
    if (dict[@"productImage"]) {
        object[@"productImage"] = dict[@"productImage"];
    }

/*
    if ([dict[@"sitedetails"] count] > 0) {

        object[@"productURL"] = [dict[@"sitedetails"] firstObject][@"url"];
    }
*/
    return object;
}

@end
