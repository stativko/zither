//
//  SSISeparator.m
//  WarrantyManager
//
//  Created by MacOs on 7/9/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSISeparator.h"

@implementation SSIHorzSeparator

- (void)awakeFromNib
{
    [super awakeFromNib];
    CGRect frame = self.frame;
    frame.size.height = 0.5f;
    self.frame = frame;
}

@end

@implementation SSIVertSeparator

- (void)awakeFromNib
{
    [super awakeFromNib];
    CGRect frame = self.frame;
    frame.size.width = 0.5f;
    self.frame = frame;
}

@end
