//
//  SSIProductSearchResults.h
//  zither
//
//  Created by Kevin Weiler on 2/13/15.
//  Copyright (c) 2015 Silber Studios, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSIProductSearchResults : NSObject

- (BOOL)isScannedObject;
- (instancetype)initWithSearchTerm:(NSString*)searchTerm;
@property (nonatomic, strong) NSString *searchTerm;
@property (nonatomic, strong) NSArray *verifiedProducts;
@property (nonatomic, strong) NSArray *userProducts;
@property (nonatomic, strong) NSArray *semanticsProducts;
- (NSArray *)cumulativeProducts;
@end
