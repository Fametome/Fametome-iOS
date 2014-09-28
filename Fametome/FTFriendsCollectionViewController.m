//
//  FTFriendsCollectionViewController.m
//  Fametome
//
//  Created by Famille on 12/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTFriendsCollectionViewController.h"

@interface FTFriendsCollectionViewController ()

@end

@implementation FTFriendsCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Initialisation */
    [[FTToolBox sharedGlobalData] designNavbar:self.navigationController.navigationBar];
    
    UIBarButtonItem *firstButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showFriendSearch)];
    UIBarButtonItem *secondButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showDemandes)];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:firstButton];
    [array addObject:secondButton];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithArray:array];
    /* End - Initialisation */
    
    FTFriendsFlowLayout *layout = [[FTFriendsFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 1.0;
    layout.minimumLineSpacing = 1.0;
    [self.collectionView setCollectionViewLayout:layout animated:NO];

    /* Backend - End */
    _friends = [[NSMutableArray alloc] init];
    [self loadData];
    /* Backend - End */

}

#pragma mark - Refresh
- (void) loadData
{
    if(![[FTToolBox sharedGlobalData] isNetworkAvailable])
    {
        self.collectionView.emptyDataSetSource = self;
        self.collectionView.emptyDataSetDelegate = self;
    }else{
        [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Chargement" forView:self.view];
        
        PFQuery *oneSens = [PFQuery queryWithClassName:@"Relation"];
        [oneSens whereKey:@"demandeurObjectId" equalTo:[PFUser currentUser].objectId];
        [oneSens whereKey:@"statut" greaterThanOrEqualTo:@1];
        
        PFQuery *otherSens = [PFQuery queryWithClassName:@"Relation"];
        [otherSens whereKey:@"receveurObjectId" equalTo:[PFUser currentUser].objectId];
        [otherSens whereKey:@"statut" greaterThanOrEqualTo:@1];
        
        PFQuery *query = [PFQuery orQueryWithSubqueries:@[oneSens,otherSens]];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                [_friends removeAllObjects];
                for (PFObject *relation in objects) {
                    NSString *demandeurObjectId = relation[@"demandeurObjectId"];
                    NSString *receveurObjectId = relation[@"receveurObjectId"];
                    
                    if([relation[@"demandeurObjectId"] isEqualToString:[PFUser currentUser].objectId]){
                        [_friends addObject: receveurObjectId];
                    }else{
                        [_friends addObject: demandeurObjectId];
                    }
                }
                
                if(_friends.count == 0){
                    self.collectionView.emptyDataSetSource = self;
                    self.collectionView.emptyDataSetDelegate = self;
                }
                
                [self.collectionView reloadData];
            }else{
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }
            
            [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
        }];
    }

}


#pragma mark - Navigation methods
- (void) showDemandes
{
    [self performSegueWithIdentifier:@"seeDemandSegue" sender:self];
}

- (void) showFriendSearch
{
    [self performSegueWithIdentifier:@"searchFriendSegue" sender:self];
}

// TODO : nav
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"showFriendProfilSegue" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showFriendProfilSegue"])
    {
        FTFriendProfilViewController *nextController = segue.destinationViewController;
        [nextController setFriendObjectId:_friends[_selectedIndexPath.row]];
    }
}

#pragma mark - SlideNavigationController Methods -
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _friends.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTFriendViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"friendCell" forIndexPath:indexPath];
    
    // Appel au serveur
    NSString *userObjectId = _friends[indexPath.row];
    
    PFQuery *query = [PFUser query];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query whereKey:@"objectId" equalTo:userObjectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            PFUser *user = (PFUser *)object;
            
            // On configure le label de la cellule
            NSString *username = user.username;
            cell.friendLabel.text = username;
            
            PFFile *avatarFile = user[@"avatar"];
            [avatarFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error){
                    UIImage *avatar = [UIImage imageWithData:data];

                    // On configure l'avatar de la cellule
                    if(avatar != nil)
                        cell.friendAvatar.image = avatar;
                    
                }else{
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                }
            } progressBlock:^(int percentDone) {
                // ProgressView ? ...
            }];
            
        }else{
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];

    
    // Configuration par défaut
    cell.friendAvatar.image = [UIImage imageNamed:@"avatar.jpg"];
    cell.friendLabel.text = @"Username";
    
    return cell;
}



#pragma mark - UICollectionView method
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(106.0, 140.0);
}

#pragma mark - Data Source Implementation DZNEmptyDataSet
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text;
    if([[FTToolBox sharedGlobalData] isNetworkAvailable]){
        text = @"Aucun amis";
    }else{
        text = [[FTToolBox sharedGlobalData] titleWhenNetworkUnavailable];
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text;
    if([[FTToolBox sharedGlobalData] isNetworkAvailable]){
        text = @"Rechercher vos amis et ajouter les pour pouvoir échanger des flashs avec eux.";
    }else{
        text = [[FTToolBox sharedGlobalData] subtitleWhenNetworkUnavailable];
    }
    
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
        
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:20.0]};
    NSAttributedString *result;
    if([[FTToolBox sharedGlobalData] isNetworkAvailable])
        result = [[NSAttributedString alloc] initWithString:@"Rechercher mes amis" attributes:attributes];
    
    return result;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [[FTToolBox sharedGlobalData] resizeImageForEmptyControllerImage:[UIImage imageNamed:@"bookmark .png"]]; // Attention au nom de l'image, il y a bien un point après le 'bookmark'.
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    
    return [UIColor whiteColor];
}

#pragma mark - Delegate Implementation DZNEmptyDataSet
- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView {
    [self performSegueWithIdentifier:@"searchFriendSegue" sender:self];
}

- (void)emptyDataSetDidTapView:(UIScrollView *)scrollView {
    [self loadData];
    [self.collectionView reloadData];
}

@end
