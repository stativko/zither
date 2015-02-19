//
//  SSIIntroViewController.m
//  WarrantyManager
//
//  Created by MacOs on 6/13/14.
//  Copyright (c) 2014 Reilly. All rights reserved.
//

#import "SSIIntroViewController.h"
#import "SSIIntroView.h"

#define NUMBER_OF_INTRO_PAGES 4

@interface SSIIntroViewController ()

@property (nonatomic, strong) UICollectionViewCell *welcomeCell;

@end

@implementation SSIIntroViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.welcomeCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"introCell1" forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];

    [self.pageControl setNumberOfPages:NUMBER_OF_INTRO_PAGES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    SSIIntroView *intro = (SSIIntroView *)[self.welcomeCell viewWithTag:1];
    [intro startAnimate];
}

- (void)actionChangePage
{
    NSIndexPath *visibleIndexPath = [NSIndexPath indexPathForItem:self.pageControl.currentPage inSection:0];
    [self.collectionView scrollToItemAtIndexPath:visibleIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (IBAction)actionDone
{
    [SSIUtils didShowIntro];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionTerms
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.silberstudios.tv/?p=12309"]];
}

#pragma mark -
#pragma mark UICollectionViewDataSource, UICollectionViewDelegate methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return NUMBER_OF_INTRO_PAGES;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {

        return self.welcomeCell;
    }

    NSString *identifier = [NSString stringWithFormat:@"introCell%d", (NSInteger)indexPath.item + 1];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView.frame.size;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self.pageControl setCurrentPage:currentPage];
}

@end
