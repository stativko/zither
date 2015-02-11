//
//  SSISearchViewController.h
//  WarrantyManager
//
//  Created by MacOs on 6/17/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIBaseViewController.h"

@interface SSISearchViewController : SSIBaseViewController <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) NSString *searchString;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (IBAction)actionAddManually;

@end
