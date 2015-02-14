//
//  SSIProductSearchResults.m
//  zither
//
//  Created by Kevin Weiler on 2/13/15.
//  Copyright (c) 2015 Silber Studios, Inc. All rights reserved.
//

#import "SSIProductSearchResults.h"

@implementation SSIProductSearchResults

-(instancetype)initWithSearchTerm:(NSString *)searchTerm {
    self = [super init];
    if (self) {
        _searchTerm = searchTerm;
        self.userProducts = @[];
        self.verifiedProducts = @[];
        self.semanticsProducts = @[];
    }
    return self;
}
-(NSArray *)cumulativeProducts {
    return [[self.verifiedProducts arrayByAddingObjectsFromArray:self.userProducts] arrayByAddingObjectsFromArray:self.semanticsProducts];
}

-(BOOL)isScannedObject {
    return self.semanticsProducts.count;
}



@end
