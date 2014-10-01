//
//  FTChooseRecipientsViewController.m
//  Fametome
//
//  Created by Famille on 07/09/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTChooseRecipientsViewController.h"

@interface FTChooseRecipientsViewController ()

@end

@implementation FTChooseRecipientsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Initialisation */
    //[[FTToolBox sharedGlobalData] designNavbar:self.navigationController.navigationBar];
    self.title = @"Destinataires";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Retour" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Envoyer" style:UIBarButtonItemStylePlain target:self action:@selector(sendMessage)];

    /* End - Initialisation */
    
    /* Backend - End */
    _friends = [[NSMutableArray alloc] init];
    [self loadData];
    /* Backend - End */
    
    _recipients = [[NSMutableArray alloc] init];
}

#pragma mark - Navbar Method
- (void) sendMessage {

    
    /* Initialisation */
    PFUser *author = [PFUser currentUser];
    NSString *authorObjectId = author.objectId;
    //NSArray *recipientsObjectId = _recipients;
    NSMutableArray *flashs = [[FTToolBox sharedGlobalData] getFlashs];
    [[FTToolBox sharedGlobalData] displayFlashs];
    
    /* Vérification d'usage */
    // 1. Flashs empty
    if(![[FTToolBox sharedGlobalData] isNetworkAvailable]){
        [[FTToolBox sharedGlobalData] networkUnavailableAlert];
    }
    else if([[FTToolBox sharedGlobalData] isFlashsEmpty]){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Petit problème..." message:@"Vous n'allez quand même pas envoyer un message vide à vos amis Appuyer sur retour et écrivez un message sympas !" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
    }
    // 2. Recipients empty
    else if(_recipients.count == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Petit problème..." message:@"Vous n'avez pas sélectionnez de destinataires !" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else {
        [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Envoie en cours" forView:self.view];
        // 1. Message
        NSLog(@"Création du message");
        PFObject *message = [PFObject objectWithClassName:@"Message"];
        message[@"authorObjectId"] = authorObjectId;
        [message addUniqueObjectsFromArray:(NSArray *)_recipients forKey:@"recipientsObjectId"];
        message[@"animation"] = @0;
        message[@"seen"] = @NO;
        message[@"time"] = @0;
    
        // 2. Flashs
        NSLog(@"Création des flashs");
        int index = 0;
        for(NSMutableDictionary *currentFlash in (NSArray *)flashs){
            PFObject *flash = [PFObject objectWithClassName:@"Flash"];
            flash[@"message"] = message;
            flash[@"index"] = [NSNumber numberWithInt:index];
            
            NSString *sms = [currentFlash objectForKey:@"sms"];
            NSData *imageData = [currentFlash objectForKey:@"imageData"];
            NSString *faceObjectId = [currentFlash objectForKey:@"faceObjectId"];
            
            if(![[FTToolBox sharedGlobalData] isFlashEmpty:currentFlash]){
                if(faceObjectId != nil){
                    NSLog(@"Flahs %d is Face.", index);
                    flash[@"faceObjectId"] = faceObjectId;
                    flash[@"sms"] = [NSNull null];
                    flash[@"image"] = [NSNull null];
                    [flash saveInBackground];
                    // Stats
                    [[PFUser currentUser] incrementKey:@"flashFaceSendCount"];
                    
                }else{
                    if(![sms isEqualToString:@""] && sms != nil){
                        NSLog(@"Flahs %d is Sms.", index);
                        flash[@"sms"] = sms;
                        flash[@"image"] = [NSNull null];
                        flash[@"faceObjectId"] = [NSNull null];
                        [flash saveInBackground];
                        // Stats
                        [[PFUser currentUser] incrementKey:@"flashSmsSendCount"];
                    }
                    else if(imageData){
                        NSLog(@"Flahs %d is Picture.", index);
                        PFFile *imageFile = [PFFile fileWithName:@"picture.png" data:imageData];
                        
                        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if(!error){
                                NSLog(@"Upload de l'image successfull !");
                                flash[@"sms"] = [NSNull null];
                                flash[@"image"] = imageFile;
                                flash[@"faceObjectId"] = [NSNull null];
                                [flash saveInBackground];
                                // Stats
                                [[PFUser currentUser] incrementKey:@"flashPhotoSendCount"];
                            }
                        }];
                    }
                }

                // Stats
                [[PFUser currentUser] incrementKey:@"flashSendCount"];
            }
            index++;
            if(index >= [flashs count])
                // Push notification
                [[FTToolBox sharedGlobalData] sendPushForMessageToRecipients:message[@"recipientsObjectId"]];
        }
        
        // Stats
        [[PFUser currentUser] incrementKey:@"messageSendCount"];
        [[PFUser currentUser] saveInBackground];
        
        // 3. Fin de l'envoie
        [self performSelector:@selector(displaySuccess) withObject:nil afterDelay:1];
    }
}

- (void) displaySuccess
{
    [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
    [[FTToolBox sharedGlobalData] displayCheckmarkWithLabelText:@"Envoie réussie" forView:self.view];
    [self performSelector:@selector(redirectToReception) withObject:nil afterDelay:1];
    [[FTToolBox sharedGlobalData] resetDisk];
}

- (void) redirectToReception
{

    [[FTToolBox sharedGlobalData] redirectToReception:self];
}

- (void) back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Refresh
- (void) loadData
{
    if(![[FTToolBox sharedGlobalData] isNetworkAvailable])
    {
        self.collectionView.emptyDataSetSource = self;
        self.collectionView.emptyDataSetDelegate = self;
    }else{
        [[FTToolBox sharedGlobalData] startLoaderForView:self.view];
        
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

#pragma mark - Handle Events
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTChooseRecipientsViewCell *cell = (FTChooseRecipientsViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    NSString *recipientObjectId = _friends[indexPath.row];
    
    if(![_recipients containsObject:recipientObjectId]){
        [_recipients addObject:recipientObjectId];
        [[FTToolBox sharedGlobalData] activeRecipient:cell];
        NSLog(@"Ajout de %@", recipientObjectId);
    }else{
        [_recipients removeObject:recipientObjectId];
        [[FTToolBox sharedGlobalData] inactiveRecipient:cell];
        NSLog(@"Retrait de %@", recipientObjectId);
    }
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
    FTChooseRecipientsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"chooseRecipientsCell" forIndexPath:indexPath];
    
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
            cell.chooseRecipientsLabel.text = username;
            
            PFFile *avatarFile = user[@"avatar"];
            [avatarFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error){
                    UIImage *avatar = [UIImage imageWithData:data];
                    
                    // On configure l'avatar de la cellule
                    if(avatar != nil)
                        cell.chooseRecipientsImageView.image = avatar;
                    
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
    cell.chooseRecipientsImageView.image = [UIImage imageNamed:@"avatar.jpg"];
    cell.chooseRecipientsLabel.text = @"Username";
    cell.chooseRecipientsCheckmark.hidden = YES;
    
    return cell;
}

#pragma mark - UICollectionView method
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(106.0, 130.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1.0;
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
    if([[FTToolBox sharedGlobalData] isNetworkAvailable]){
        return [[FTToolBox sharedGlobalData] resizeImageForEmptyControllerImage:[UIImage imageNamed:@"bookmark.png"]];
    }else{
        return [[FTToolBox sharedGlobalData] resizeImageForEmptyControllerImage:[UIImage imageNamed:@"tag.png"]];
    }
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
