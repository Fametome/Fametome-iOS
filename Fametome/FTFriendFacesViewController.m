//
//  FTFriendFacesViewController.m
//  Fametome
//
//  Created by Famille on 29/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTFriendFacesViewController.h"

@interface FTFriendFacesViewController ()

@end

@implementation FTFriendFacesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"Affichage des Faces de %@", _friend.username);
    self.title = [NSString stringWithFormat:@"Faces de %@", _friend.username];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Retour" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    /* Backend */
    _faces = [[NSMutableArray alloc] init];
    
    [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Chargement" forView:self.view];
    PFQuery *queryFaces = [PFQuery queryWithClassName:@"Face"];
    queryFaces.cachePolicy = kPFCachePolicyNetworkElseCache;
    [queryFaces whereKey:@"user" equalTo:_friend];
    [queryFaces orderByDescending:@"createdAt"];
    [queryFaces findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            
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
    
    /* Backend - end */
}

- (IBAction) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    FTFriendFaceViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"faceFriendCell" forIndexPath:indexPath];
    long row = [indexPath row];
    
    // Appel au serveur
    NSString *currentFaceObjectId = _faces[row];
    PFQuery *queryFace = [PFQuery queryWithClassName:@"Face"];
    queryFace.cachePolicy = kPFCachePolicyNetworkElseCache;
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

#pragma mark - UICollectionViewDelegate
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(106.0, 130.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark - Handle Events
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"showFacesFriendCarouselSegue" sender:self];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showFacesFriendCarouselSegue"])
    {
        FTFacesFriendCarouselViewController *nextController = segue.destinationViewController;
        [nextController setCurrentIndex:(int *)_selectedIndexPath.row];
        [nextController setFriend:_friend];
    }
}

#pragma mark - Data Source Implementation DZNEmptyDataSet
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"Aucune faces";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = [NSString stringWithFormat:@"Votre ami %@ n'a aucune faces."];
    
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

#pragma mark - Setters methods for Segue
- (void) setFriend:(PFUser *)friend
{
    _friend = friend;
}

#pragma mark - SlideNavigationController Methods -
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return NO;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

@end
