//
//  SSIProductCell.m
//  WarrantyManager
//
//  Created by MacOs on 6/17/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIProductCell.h"

@interface SSIProductCell ()
@property (nonatomic, strong) UIImage *placeholderImage;
@end
@implementation SSIProductCell

-(UIImage *)placeholderImage {
    if (!_placeholderImage) {
        _placeholderImage = [UIImage imageNamed:@"product_placeholder"];
    }
    return _placeholderImage;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    [self.productImageView setImage:self.placeholderImage];
}
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.backgroundColor = (highlighted == YES) ? [UIColor colorWithWhite:0.9f alpha:1] : [UIColor whiteColor];
}

- (void)setProduct:(PFObject *)product
{
    [self.productImageView setImage:self.placeholderImage];

    self.backgroundColor = [UIColor whiteColor];
    [self.lblProductName setText:product[@"productName"]];

    long remainingWarrantyDays = [SSIUtils remainingWarrantyDaysFromProduct:product];
    [self.lblWarranty setTextColor:(remainingWarrantyDays < 42) ? [UIColor colorWithRed:250.0 / 255.0 green:54.0 / 255.0 blue:100.0 / 255.0 alpha:1] : [UIColor blackColor]];
    [self.lblWarranty setText:[SSIUtils remainingWarrantyStringFromProduct:product]];


    PFFile *productImage = product[@"productImage"];
//    NSString *productImageUrl = (productImage.url!=nil) ? productImage.url : product[@"productImageUrl"];
    NSString *productImageUrl = product[@"productImageUrl"];

    if (productImage.url) {
        UIActivityIndicatorView *av = [UIActivityIndicatorView createActivityIndicatorInView:self.productImageView style:UIActivityIndicatorViewStyleGray offset:UIOffsetZero];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData * data = [productImage getData];
            UIImage *productImage = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                self.productImageView.image = productImage;
                [av removeFromSuperview];
            });
        });
    }
    else if (productImageUrl) {
        [self.productImageView cancelImageRequestOperation];

        [self.productImageView setImageWithURL:[NSURL URLWithString:productImageUrl] placeholderImage:self.placeholderImage];
    }

}

@end
