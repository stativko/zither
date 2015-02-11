//
//  SSISearchViewController.m
//  WarrantyManager
//
//  Created by MacOs on 6/17/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSISearchViewController.h"
#import "SSIEditProductViewController.h"
#import "SSISearchCell.h"

@interface SSISearchViewController ()

@property (nonatomic, strong) PFObject *productToEdit;

@end

@implementation SSISearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    if (self.searchResults) {

        [self.searchBar setAlpha:0.5f];
        [self.searchBar setUserInteractionEnabled:NO];
    }

    [self loadProductsWithSearchString:self.searchString];
}

- (void)setupNavigationBar
{
    self.navigationItem.titleView = [[UIView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.productToEdit = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editProduct"]) {

        SSIEditProductViewController *editController = segue.destinationViewController;
        editController.product = self.productToEdit;
        editController.shouldAddProduct = YES;
        self.navigationItem.title = @"Results";
    }
}

#pragma mark -
#pragma mark api calling methods
- (void)loadProductsWithSearchString:(NSString *)searchString
{
    if (![SSIUtils validateText:self.searchString]) {

        return;
    }

    [self.searchBar setText:searchString];

    [SVProgressHUD showWithStatus:@"Loading Product Details..."];
    [SSIApi getProductDetailFromText:searchString success:^(NSArray *products) {

        [SVProgressHUD dismiss];

        [self didFinishLoadingProducts:products];
    } failure:^(NSString *error) {

        [SVProgressHUD showErrorWithStatus:error];
    }];
}

- (void)didFinishLoadingProducts:(NSArray *)products
{
    self.searchResults = products;
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark user interaction methods

- (void)actionAddManually
{
    self.productToEdit = [SSIApi objectFromProductDict:@{@"name": (self.searchBar.text == nil) ? @"" : self.searchBar.text}];
    [self performSegueWithIdentifier:@"editProduct" sender:self];
}

#pragma mark -
#pragma mark UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"searchCell";
    SSISearchCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell setProduct:self.searchResults[indexPath.row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.productToEdit = self.searchResults[indexPath.row];
    [self performSegueWithIdentifier:@"editProduct" sender:self];
}

#pragma mark -
#pragma mark UISearchBarDelegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];

    self.searchString = searchBar.text;
    [self loadProductsWithSearchString:self.searchString];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

@end
