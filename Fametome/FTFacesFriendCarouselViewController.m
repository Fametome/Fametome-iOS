//
//  FTFacesFriendCarouselViewController.m
//  Fametome
//
//  Created by Famille on 30/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTFacesFriendCarouselViewController.h"

@interface FTFacesFriendCarouselViewController ()

@end

@implementation FTFacesFriendCarouselViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Carousel des amis nb: %d", _faces.count);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Retour" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    [[FTToolBox sharedGlobalData] startLoaderForView:self.view];
    PFQuery *query = [PFQuery queryWithClassName:@"Face"];
    query.cachePolicy = kPFCachePolicyCacheOnly;
    [query whereKey:@"user" equalTo:_friend]; // modifier par l'utilisateur *friend
    [query orderByDescending:@"createdAt"];
    _faces = (NSMutableArray *)[query findObjects];
    [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
     
}

- (IBAction) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.collectionView.pagingEnabled = YES;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    NSLog(@"Index transmis: %d", (int)_currentIndex);
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(int)_currentIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

#pragma mark - Setter Method
- (void) setCurrentIndex:(int *)currentIndex
{
    _currentIndex = currentIndex;
}

- (void) setFaces:(NSMutableArray *)faces
{
    _faces = faces;
}

- (void) setFriend:(PFUser *)friend
{
    _friend = friend;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _faces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTFacesFriendCarouselCellView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"faceFriendCarouselCell" forIndexPath:indexPath];
    
    PFObject *face = _faces[indexPath.row];
    cell.faceSmsLabel.text = face[@"sms"];
    
    PFFile *imageFile = face[@"image"];
    NSData *imageData = [imageFile getData];
    UIImage *image = [UIImage imageWithData:imageData];
    
    cell.faceImageView.image = image;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    // ...
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}


@end
