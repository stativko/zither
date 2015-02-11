//
//  SSIProductDetailViewController.h
//  WarrantyManager
//
//  Created by MacOs on 6/17/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIBaseViewController.h"

@interface SSIProductDetailViewController : SSIBaseViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PFObject *product;

@property (nonatomic, weak) IBOutlet UILabel *lblProductName;
@property (nonatomic, weak) IBOutlet UILabel *lblModel;
@property (nonatomic, weak) IBOutlet UIImageView *productImageView;
//@property (nonatomic, weak) IBOutlet UILabel *lblExpires;
@property (nonatomic, weak) IBOutlet UILabel *lblWarrantyLength;
@property (nonatomic, weak) IBOutlet UILabel *lblPurchasedOn;
@property (nonatomic, weak) IBOutlet UILabel *lblPurchasedFrom;
@property (nonatomic, readonly) UILabel *lblDescription;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (IBAction)dumpApiResponse;
- (IBAction)actionProductReceipt;

@end
