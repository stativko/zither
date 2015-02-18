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
@property (nonatomic, strong) PFObject *copiedProduct;

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
    self.copiedProduct = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editProduct"]) {

        SSIEditProductViewController *editController = segue.destinationViewController;
        editController.product = self.productToEdit;
        editController.copiedProduct = self.copiedProduct;
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
    [SSIApi getProductDetailFromText:searchString success:^(SSIProductSearchResults *products) {

        [SVProgressHUD dismiss];
        self.searchResults = products;
        [self.tableView reloadData];
    } failure:^(NSString *error) {

        [SVProgressHUD showErrorWithStatus:error];
    }];
}

#pragma mark -
#pragma mark user interaction methods

- (void)actionAddManually
{
    NSMutableDictionary *dict = [@{@"name": (self.searchBar.text == nil) ? @"" : self.searchBar.text} mutableCopy];
//    if (self.searchResults) {
//        [dict setObject:self.searchResults.searchTerm forKey:@"barcode"];
//    }
    self.productToEdit = [SSIApi objectFromProductDict:dict];
    [self performSegueWithIdentifier:@"editProduct" sender:self];
}

#pragma mark -
#pragma mark UITableViewDataSource, UITableViewDelegate methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.searchResults cumulativeProducts].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"searchCell";
    SSISearchCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell setProduct:self.searchResults.cumulativeProducts[indexPath.row]];

    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject *copyProduct = self.searchResults.cumulativeProducts[indexPath.row];
    NSDictionary *productToEdit =
    @{@"barcode" : copyProduct[@"barcode"] ? copyProduct[@"barcode"] : @"missing"};
    self.productToEdit = [SSIApi objectFromProductDict:productToEdit];

    if (![self.searchResults isScannedObject]) {
        self.copiedProduct = copyProduct;
        self.productToEdit[@"copiedFrom"] = self.copiedProduct;
    }

    if (copyProduct[@"productImage"]) {
        self.productToEdit[@"productImage"] = copyProduct[@"productImage"];
    }
    if (copyProduct[@"productImageUrl"]) {
        self.productToEdit[@"productImageUrl"] = copyProduct[@"productImageUrl"];
    }
    if (copyProduct[@"productName"]) {
        self.productToEdit[@"productName"] = copyProduct[@"productName"];
    }
    if (copyProduct[@"manual"]) {
        self.productToEdit[@"manual"] = copyProduct[@"manual"];
    }
    if (copyProduct[@"manual_url"]) {
        self.productToEdit[@"manual_url"] = copyProduct[@"manual_url"];
    }
    if (copyProduct[@"customerService"]) {
        self.productToEdit[@"customerService"] = copyProduct[@"customerService"];
    }
    if (copyProduct[@"customerService_url"]) {
        self.productToEdit[@"customerService_url"] = copyProduct[@"customerService_url"];
    }
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
