//
//  SSIMyStuffViewController.h
//  WarrantyManager
//
//  Created by MacOs on 6/15/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIBaseViewController.h"

@interface SSIMyStuffViewController : SSIBaseViewController <UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *lblNoItems;
@property (nonatomic, weak) IBOutlet UILabel *lblNoSearchResults;

- (IBAction)actionAddProduct;
- (void)navigateToProductDetail:(NSString *)product;
@property (nonatomic, assign) BOOL forceRefresh;
@end
