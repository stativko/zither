//
//  SSISearchCell.h
//  WarrantyManager
//
//  Created by MacOs on 6/17/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIProductCell.h"

@interface SSISearchCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *productImageView;
@property (nonatomic, weak) IBOutlet UILabel *lblProductName;
@property (weak, nonatomic) IBOutlet UILabel *numSharesLabel;

- (void)setProduct:(PFObject *)product;

@end
