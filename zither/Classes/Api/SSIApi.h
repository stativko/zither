//
//  SSIApi.h
//  WarrantyManager
//
//  Created by MacOs on 6/15/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIProductSearchResults.h"


@interface SSIApi : AFHTTPSessionManager

// look up product with UPC using semantics api
+ (void)getProductDetailFromUPC:(NSString *)code
                        success:(void (^)(SSIProductSearchResults *product))success
                        failure:(void (^)(NSString *error))failure;

// look up product with Text using semantics api
+ (void)getProductDetailFromText:(NSString *)text
                         success:(void (^)(SSIProductSearchResults *products))success
                         failure:(void (^)(NSString *error))failure;

+ (PFObject *)objectFromProductDict:(NSDictionary *)dict;

@end
