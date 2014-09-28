//
//
//  Fametome
//
//  Created by Famille on 24/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTCarouselFacesProfilViewController.h"

@interface FTCarouselFacesProfilViewController ()

@end

@implementation FTCarouselFacesProfilViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Navbar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(performDelete:)];
    
    [[FTToolBox sharedGlobalData] startLoaderForView:self.view];
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Face"];
    query.cachePolicy = kPFCachePolicyCacheOnly;
    [query whereKey:@"user" equalTo:currentUser];
    [query orderByDescending:@"createdAt"];
     _faces = (NSMutableArray *)[query findObjects];
    [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];

    /*
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            _faces = (NSMutableArray *)objects;
            [self.collectionView reloadData];
            
            // Index transmis
            NSLog(@"Index transmis: %d", (int)_currentIndex);
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:4 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
            
            [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
        }else{
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];
     */
    
    //NSLog(@"Index transmis: %d", (int)_currentIndex);
    //NSIndexPath *indexPath = [NSIndexPath indexPathForItem:4 inSection:0];
    //[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    
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

#pragma mark - Alert Methods
- (void) performDelete:(id)paramSender
{
    PFObject *face = _faces[(int)_currentIndex];
    NSString *message = [NSString stringWithFormat:@"Êtes-vous sûr de vouloir supprimer cette face '%@'?", face[@"sms"]];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Supprimer" message:message delegate:self cancelButtonTitle:@"Non" otherButtonTitles:[self confirmerButtonTitle], nil];
    [alertView show];
    //[self scrollViewDidScroll:self.collectionView.scroll]
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // On supprime la Face
        NSLog(@"Total faces: %d", _faces.count);
        NSLog(@"Confirmer la suppression de la face %d", (int)_currentIndex);
        PFObject *face = _faces[(int)_currentIndex];
        
        [[FTToolBox sharedGlobalData] startLoaderForView:self.view];
        [face deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error){
                [_faces removeObject:face];
                [self.collectionView reloadData];
                if(_faces.count == 0)
                    [[FTToolBox sharedGlobalData] redirectToProfil:self];
                
                NSLog(@"Total faces: %d", _faces.count);
            }else{
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }
            [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
        }];
    }
}

-(NSString *) confirmerButtonTitle
{
    return @"Confirmer";
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
    _currentIndex = (int *)currentIndex;
    NSLog(@"Index: %d", currentIndex);
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
    FTCarouselFacesProfilViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"faceProfilCell" forIndexPath:indexPath];
    
    PFObject *face = _faces[indexPath.row];
    cell.faceSmsLabel.text = face[@"sms"];
    
    PFFile *imageFile = face[@"image"];
    NSData *imageData = [imageFile getData];
    UIImage *image = [UIImage imageWithData:imageData];
    
    cell.faceImageView.image = image;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(320.0, 505.0);
}

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
