//
//  SSIProductCell.h
//  WarrantyManager
//
//  Created by MacOs on 6/17/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSIProductCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *productImageView;
@property (nonatomic, weak) IBOutlet UILabel *lblProductName;
@property (nonatomic, weak) IBOutlet UILabel *lblWarranty;

- (void)setProduct:(id)product;

@end
