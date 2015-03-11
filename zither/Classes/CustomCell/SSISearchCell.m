//
//  SSISearchCell.m
//  WarrantyManager
//
//  Created by MacOs on 6/17/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSISearchCell.h"
@interface SSISearchCell ()
@property (weak, nonatomic) IBOutlet UIImageView *manualImage;
@property (weak, nonatomic) IBOutlet UIImageView *custServiceImage;

@end
@implementation SSISearchCell

-(void)prepareForReuse {
    [super prepareForReuse];
    self.manualImage.alpha = 0;
    self.manualImage.alpha = 1;
}
- (void)setProduct:(PFObject *)product
{
    self.backgroundColor = [UIColor whiteColor];
    [self.lblProductName setText:product[@"productName"]];
    if (product[@"numShares"]) {
        [self.numSharesLabel setText:[product[@"numShares"] stringValue]];
    }

    UIImage *placeholderImage = [UIImage imageNamed:@"product_placeholder"];

    [self.productImageView cancelImageRequestOperation];
    [self.productImageView setImage:placeholderImage];

    PFFile *productImage = product[@"productImage"];
    NSString *productImageUrl = product[@"productImageUrl"];

    if (productImage.url) {
        [productImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                self.productImageView.image = image;
            }
        }];
    }
    else if (productImageUrl) {
        [self.productImageView setImageWithURL:[NSURL URLWithString:productImageUrl] placeholderImage:placeholderImage];
    }
    [self showManual:(product[@"manual"] || product[@"manual_url"])];
    [self showCustService:(product[@"customerService"] || product[@"customerService_url"])];
}

- (void)showManual:(BOOL)show {
    if (show) {
        [self.manualImage animateIn];
    } else {
        [self.manualImage animateOut];
    }
}
-(void)showCustService:(BOOL)show {
    if (show) {
        [self.custServiceImage animateIn];
    } else {
        [self.custServiceImage animateOut];
    }
}

@end
