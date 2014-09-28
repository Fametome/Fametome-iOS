//
//  FTFacesViewController.m
//  Fametome
//
//  Created by Famille on 07/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTFacesViewController.h"

@interface FTFacesViewController ()

@end

@implementation FTFacesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // FlowLayout initialisation
    FTFacesFlowLayout *faceLayout = [[FTFacesFlowLayout alloc] init];
    faceLayout.minimumInteritemSpacing = 1.0;
    faceLayout.minimumLineSpacing = 1.0;
    [self.collectionView setCollectionViewLayout:faceLayout animated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Backend
    PFUser *currentUser = [PFUser currentUser];
    _faces = [[NSMutableArray alloc] init];
    
    [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Chargement" forView:self.view];
    PFQuery *queryFaces = [PFQuery queryWithClassName:@"Face"];
    queryFaces.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [queryFaces whereKey:@"user" equalTo:currentUser];
    [queryFaces orderByDescending:@"createdAt"];
    [queryFaces findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            [_faces removeAllObjects];
            
            for(PFObject *face in objects){
                [_faces addObject: face.objectId];
            }
            
            if(_faces.count == 0){
                self.collectionView.emptyDataSetSource = self;
                self.collectionView.emptyDataSetDelegate = self;
            }
            
            [self.collectionView reloadData];
            [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
            
        }else{
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _faces.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTFacesViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"faceCell" forIndexPath:indexPath];
    long row = [indexPath row];

    // Appel au serveur
    NSString *currentFaceObjectId = _faces[row];
    PFQuery *queryFace = [PFQuery queryWithClassName:@"Face"];
    queryFace.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [queryFace getObjectInBackgroundWithId:currentFaceObjectId block:^(PFObject *object, NSError *error) {
        if(!error){
            PFObject *face = object;
            
            // On configure le label de la cellule
            NSString *sms = face[@"sms"];
            cell.faceSmsLabel.text = sms;
            
            PFFile *faceImageFile = face[@"image"];
            [faceImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error){
                    UIImage *faceImage = [UIImage imageWithData:data];
                    cell.faceImageView.image = faceImage;
                }else{
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                }
            } progressBlock:^(int percentDone) {
                //...
            }];
            
        }else{
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];
    
    // Configuration par défaut
    cell.faceImageView.image = [UIImage imageNamed:@"avatar.jpg"];
    cell.faceSmsLabel.text = @"...";
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(106.0, 130.0);
}

#pragma mark - Handle Events
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"showFacesProfilSegue" sender:self];

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showFacesProfilSegue"])
    {
        FTCarouselFacesProfilViewController *nextController = segue.destinationViewController;
        [nextController setCurrentIndex:(int *)_selectedIndexPath.row];
    }
}

/*
- (void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTFacesViewCell *cell = (FTFacesViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    cell.alpha = 1.0f;
}
*/

#pragma mark - SlideNavigationController Methods -
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return NO;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

#pragma mark - Data Source Implementation DZNEmptyDataSet
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"Aucune faces";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"Ajouter des faces pour pouvoir les consulter..";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}
/*
- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor darkGrayColor];
    shadow.shadowOffset = CGSizeMake(8.0f, 8.0f);
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont boldSystemFontOfSize:20.0]
                                 //NSBackgroundColorAttributeName: [UIColor grayColor],
                                 //NSShadowAttributeName: shadow
                                 };
    
    NSAttributedString *result = [[NSAttributedString alloc] initWithString:@"Rechercher mes amis" attributes:attributes];
    
    return result;
}*/

/*
 - (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
 
 return [UIImage imageNamed:@"avatar.jpg"];
 }*/

// The background color for the empty dataset
- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    
    return [UIColor whiteColor];
}

#pragma mark - Delegate Implementation DZNEmptyDataSet
/*- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView {
    [self performSegueWithIdentifier:@"searchFriendSegue" sender:self];
}*/

@end
