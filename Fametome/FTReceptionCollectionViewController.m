//
//  FTReceptionCollectionViewController.m
//  Fametome
//
//  Created by Famille on 13/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTReceptionCollectionViewController.h"

@interface FTReceptionCollectionViewController ()

@end

@implementation FTReceptionCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[FTToolBox sharedGlobalData] designNavbar:self.navigationController.navigationBar];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(performRefresh:)];
    
    _messages = [[NSMutableArray alloc] init];
    
}

// Dev -> retour à la boîte de réception fonctionnelle
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadMessages];
}

#pragma mark - Refresh
- (void) loadMessages
{
    if([[FTToolBox sharedGlobalData] isNetworkAvailable]){
        
        [_messages removeAllObjects];
        
        [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Chargement" forView:self.view];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Message"];
        [query whereKey:@"recipientsObjectId" equalTo:[PFUser currentUser].objectId];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(!error){
                for (PFObject *message in objects) {
                    [_messages addObject:message];
                }
                if(_messages.count == 0){
                    self.collectionView.emptyDataSetSource = self;
                    self.collectionView.emptyDataSetDelegate = self;
                }
                [self.collectionView reloadData];
            }else{
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }
            [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
        }];
    }else{
        self.collectionView.emptyDataSetSource = self;
        self.collectionView.emptyDataSetDelegate = self;
    }
    
}

- (void) performRefresh:(id)paramSender
{
    [self loadMessages];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTReceptionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"messageCell" forIndexPath:indexPath];
    
    // Appel au serveur
    PFObject *message = _messages[indexPath.row];
    NSString *auteurObjectId = message[@"authorObjectId"];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:auteurObjectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            PFUser *user = (PFUser *)object;
            
            // On configure le label de la cellule
            NSString *username = user.username;
            cell.auteurMessageLabel.text = [NSString stringWithFormat:@"%@ vous a envoyé un flash.", username];

            PFFile *avatarFile = user[@"avatar"];
            [avatarFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error){
                    UIImage *avatar = [UIImage imageWithData:data];
                    // On configure l'avatar de la cellule
                    if(avatar != nil)
                        cell.auteurMessageImageView.image = avatar;
                    
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
    
    // Evenement sur le bouton "Voir le message"
    [cell.messageButton addTarget:self action:@selector(showMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    // Configuration par défaut
    cell.auteurMessageImageView.image = [UIImage imageNamed:@"avatar.jpg"];
    cell.auteurMessageLabel.text = @"username vous a envoyé un flash.";
    [[FTToolBox sharedGlobalData] makeCornerRadius:cell];
    
    return cell;
    
}

-(void)showMessage:(UIButton *) sender {
    id superView = sender.superview;
    while (superView && ![superView isKindOfClass:[UICollectionViewCell class]]) {
        superView = [superView superview];
    }// this while loop finds the cell that the button is a subview of
    NSIndexPath *selectedPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)superView];
    
    //NSString *messageObjectId = _messages[selectedPath.row];
    PFObject *message = _messages[selectedPath.row];
    NSString *messageObjectId = message.objectId;
    _selectedMessageObjectId = messageObjectId;
    
    NSLog(@"Voir le message avec comme identifiant %@", self.selectedMessageObjectId);
    
    // Redirection vers une FTMessageContentViewController pour afficher le message
    [self performSegueWithIdentifier:@"showMessageSegue" sender:self];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(25.0, 0, 0, 0);
}

/* Segue Method */
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showMessageSegue"])
    {
        FTMessageContentViewController *nextController = segue.destinationViewController;
        [nextController setMessage:self.selectedMessageObjectId];
    }
}


#pragma mark - Data Source Implementation DZNEmptyDataSet

// The attributed string for the title of the empty dataset
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text;
    if([[FTToolBox sharedGlobalData] isNetworkAvailable]){
        text = @"Aucun flashs";
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
        text = @"Appuyez sur l'écran pour charger des flashs plus récents.";
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

/*
- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0]};
    
    return [[NSAttributedString alloc] initWithString:@"Rafraîchir" attributes:attributes];
}
*/

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    if([[FTToolBox sharedGlobalData] isNetworkAvailable]){
        return [[FTToolBox sharedGlobalData] resizeImageForEmptyControllerImage:[UIImage imageNamed:@"comments.png"]];
    }else{
        return [[FTToolBox sharedGlobalData] resizeImageForEmptyControllerImage:[UIImage imageNamed:@"tag.png"]];
    }
}

// The background color for the empty dataset
- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    
    return [UIColor whiteColor];
}

#pragma mark - Delegate Implementation DZNEmptyDataSet
- (void)emptyDataSetDidTapView:(UIScrollView *)scrollView {
    [self loadMessages];
    [self.collectionView reloadData];
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

@end
