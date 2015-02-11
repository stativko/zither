//
//  SSIProductCell.m
//  WarrantyManager
//
//  Created by MacOs on 6/17/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIProductCell.h"

@implementation SSIProductCell

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.backgroundColor = (highlighted == YES) ? [UIColor colorWithWhite:0.9f alpha:1] : [UIColor whiteColor];
}

- (void)setProduct:(PFObject *)product
{
    self.backgroundColor = [UIColor whiteColor];
    [self.lblProductName setText:product[@"productName"]];

    long remainingWarrantyDays = [SSIUtils remainingWarrantyDaysFromProduct:product];
    [self.lblWarranty setTextColor:(remainingWarrantyDays < 42) ? [UIColor colorWithRed:250.0 / 255.0 green:54.0 / 255.0 blue:100.0 / 255.0 alpha:1] : [UIColor blackColor]];
    [self.lblWarranty setText:[SSIUtils remainingWarrantyStringFromProduct:product]];

    UIImage *placeholderImage = [UIImage imageNamed:@"product_placeholder"];

    [self.productImageView cancelImageRequestOperation];
    [self.productImageView setImage:placeholderImage];

    PFFile *productImage = product[@"productImage"];
    NSString *productImageUrl = product[@"productImageUrl"];

    if (productImage.url) {

        [self.productImageView setImageWithURL:[NSURL URLWithString:productImage.url] placeholderImage:placeholderImage];
    }
    else if (productImageUrl) {

        [self.productImageView setImageWithURL:[NSURL URLWithString:productImageUrl] placeholderImage:placeholderImage];
    }
}

@end
