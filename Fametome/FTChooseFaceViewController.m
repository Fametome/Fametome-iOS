//
//  FTChooseFaceViewController.m
//  Fametome
//
//  Created by Famille on 04/09/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTChooseFaceViewController.h"

@interface FTChooseFaceViewController ()

@end

@implementation FTChooseFaceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // FlowLayout initialisation
    FTFacesFlowLayout *faceLayout = [[FTFacesFlowLayout alloc] init];
    faceLayout.minimumInteritemSpacing = 1.0;
    faceLayout.minimumLineSpacing = 1.0;
    faceLayout.headerReferenceSize = CGSizeMake(0, 60);
    faceLayout.footerReferenceSize = CGSizeMake(0, 60);
    [self.collectionView setCollectionViewLayout:faceLayout animated:YES];
    
    // Backend
    PFUser *currentUser = [PFUser currentUser];
    _faces = [[NSMutableArray alloc] init];
    
    [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Chargement" forView:self.view];
    PFQuery *queryFaces = [PFQuery queryWithClassName:@"Face"];
    queryFaces.cachePolicy = kPFCachePolicyNetworkElseCache;
    //queryFaces.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [queryFaces whereKey:@"user" equalTo:currentUser];
    [queryFaces orderByDescending:@"createdAt"];
    [queryFaces findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            
            for(PFObject *face in objects){
                [_faces addObject: face];
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

- (void) back {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
    FTChooseFaceViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"chooseFaceCell" forIndexPath:indexPath];
    long row = [indexPath row];
    
    // Appel au serveur
    PFObject *currentFace = _faces[row];
    NSString *currentFaceObjectId = currentFace.objectId;
    
    PFQuery *queryFace = [PFQuery queryWithClassName:@"Face"];
    queryFace.cachePolicy = kPFCachePolicyNetworkElseCache;
    [queryFace getObjectInBackgroundWithId:currentFaceObjectId block:^(PFObject *object, NSError *error) {
        if(!error){
            PFObject *face = object;
            
            // On configure le label de la cellule
            NSString *sms = face[@"sms"];
            cell.chooseFaceLabel.text = sms;
            
            PFFile *faceImageFile = face[@"image"];
            [faceImageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error){
                    UIImage *faceImage = [UIImage imageWithData:data];
                    cell.chooseFaceImageView.image = faceImage;
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
    cell.chooseFaceImageView.image = [UIImage imageNamed:@"avatar.jpg"];
    cell.chooseFaceLabel.text = @"...";
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(106.0, 130.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 40.0, 0);
}

// Header
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionReusableView *reusableview = nil;
    
    if([kind isEqual:UICollectionElementKindSectionHeader]){
        FTChooseFaceHeaderView *header = nil;
        header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"chooseFaceHeader" forIndexPath:indexPath];
        header.chooseFaceHeaderTitleLabel.text = @"Choisir une face";
        reusableview = header;
    }
    
    if([kind isEqualToString:UICollectionElementKindSectionFooter]){
        FTChooseFaceFooter *footer = nil;
        footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"chooseFaceFooter" forIndexPath:indexPath];
        [[FTToolBox sharedGlobalData] makeCornerRadius: footer.takePictureButton];
        [footer.takePictureButton addTarget:self action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
        reusableview = footer;
    }
    
    return reusableview;
}

#pragma mark - Image Picker Delegate
- (void) takePicture
{
    UIImagePickerController *imagePicker = [[FTToolBox sharedGlobalData] activeCameraNormal];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:NO completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 1. Image & rotation
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *resizeImage = [[FTToolBox sharedGlobalData] resizeImageForFace:image];
    NSData *imageData = UIImagePNGRepresentation(resizeImage);
    
    // 2. Flash
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *flashs = [[NSMutableArray alloc]initWithArray:[defaults objectForKey:@"flashs"]];
    
    NSMutableDictionary *newFlash = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"sms", imageData, @"imageData", nil, @"faceObjectId", nil];
    
    [flashs replaceObjectAtIndex:[defaults integerForKey:@"currentFlashIndex"] withObject:newFlash];
    [defaults setObject:flashs forKey:@"flashs"];
    [defaults synchronize];
    //[[FTToolBox sharedGlobalData] displayFlashs];

    // 3. Redirect
    [picker dismissViewControllerAnimated:NO completion:nil];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Handle Events
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 1. Face
    PFObject *currentFace = _faces[indexPath.row];
    FTChooseFaceViewCell *currentCell = (FTChooseFaceViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    NSString *faceObjectId = currentFace.objectId;
    NSString *sms = currentCell.chooseFaceLabel.text;
    NSData *imageData = UIImagePNGRepresentation(currentCell.chooseFaceImageView.image);
    
    // 2. Flash
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *flashs = [[NSMutableArray alloc]initWithArray:[defaults objectForKey:@"flashs"]];
    
    NSMutableDictionary *newFlash = [NSMutableDictionary dictionaryWithObjectsAndKeys:sms, @"sms", imageData, @"imageData", faceObjectId, @"faceObjectId", nil];
    [flashs replaceObjectAtIndex:[defaults integerForKey:@"currentFlashIndex"] withObject:newFlash];
    [defaults setObject:flashs forKey:@"flashs"];
    [defaults synchronize];
    
    // 3. Redirect
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Data Source Implementation DZNEmptyDataSet
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"Aucune faces";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"Ajouter des faces pour pouvoir les envoyer à vos amis. Aller sur votre profil pour cela.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
 
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor darkGrayColor];
    shadow.shadowOffset = CGSizeMake(8.0f, 8.0f);
 
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:20.0]};
 
    NSAttributedString *result = [[NSAttributedString alloc] initWithString:@"OK" attributes:attributes];
 
    return result;
}


- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {

    return [[FTToolBox sharedGlobalData] resizeImageForAvatar:[UIImage imageNamed:@"photo.png"]];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    
    return [UIColor whiteColor];
}

#pragma mark - Delegate Implementation DZNEmptyDataSet
- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBAction
- (IBAction)cancelChooseFaceButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/*
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"chooseFaceSegue"]){
        //FTChooseFaceViewController *nextController = segue.destinationViewController;
        //[nextController setSelectedIndexPath:_selectedIndexPath];
    }

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
@end
