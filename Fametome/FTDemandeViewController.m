//
//  FTDemandeViewController.m
//  Fametome
//
//  Created by Famille on 12/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTDemandeViewController.h"

@interface FTDemandeViewController ()

@end

@implementation FTDemandeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isNetworkAvailable = [[FTToolBox sharedGlobalData] isNetworkAvailable];
    
    if(_isNetworkAvailable)
    {
        // On récupère directement les demandes
        [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Chargement" andDescription:@"Récupération de vos demandes" forView:self.view];
        self.demandes = [[FTParseBackendApi sharedGlobalData] getAllDemandesFor:[PFUser currentUser]];
        [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
        
        if(self.demandes.count == 0)
            self.collectionView.emptyDataSetSource = self;
            self.collectionView.emptyDataSetDelegate = self;
        
    }else{
        self.collectionView.emptyDataSetSource = self;
        self.collectionView.emptyDataSetDelegate = self;
    }
}

- (IBAction) back:(id)sender
{
    [[FTToolBox sharedGlobalData] redirectToFriends:self];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(25.0, 0, 0, 0);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _demandes.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTDemandeViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"demandeCell" forIndexPath:indexPath];
    
    PFObject *relation = _demandes[indexPath.row];
    NSString *demandeurObjectId = relation[@"demandeurObjectId"];
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:demandeurObjectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            PFUser *demandeur = (PFUser *)object;
            
            // On configure le label de la cellule
            NSString *username = demandeur.username;
            NSString *labelText = @" souhaite devenir votre ami(e).";
            cell.demandLabel.text = [username stringByAppendingString:labelText];
            
            PFFile *avatarFile = demandeur[@"avatar"];
            [avatarFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error){
                    UIImage *avatar = [UIImage imageWithData:data];
                    
                    // On configure l'avatar de la cellule
                    if(avatar != nil)
                        cell.avatarDemandeurImageView.image = avatar;
                    
                }else{
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                }
            } progressBlock:^(int percentDone) {
                // ProgressView ? pas besoin, suffisamment rapide...
            }];
            
        }else{
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];
    
    
    
    // Congiguration de la cell par défaut
    cell.demandLabel.text = @"...";
    cell.avatarDemandeurImageView.image = [UIImage imageNamed:@"avatar.jpg"];
    
    // Configuration des boutons ACCEPT et REFUSED
    [cell.demandAcceptButton addTarget:self action:@selector(demandAcceptActionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [cell.demandRefusedButton addTarget:self action:@selector(demandRefusedActionPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

/* Accepter une demande
* 1. Mettre à 1 le statut de la relation dans le backend
* 2. Ajouter le demandeur dans le cache du receveur
* 3. Push notification
*/
-(void)demandAcceptActionPressed:(UIButton *) sender {
    id superView = sender.superview;
    while (superView && ![superView isKindOfClass:[UICollectionViewCell class]]) {
        superView = [superView superview];
    }
    NSIndexPath *selectedPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)superView];
    PFObject *relation = _demandes[selectedPath.row];

    if([[FTToolBox sharedGlobalData] isNetworkAvailable])
    {
        [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Chargement" forView:self.view];
        [[FTParseBackendApi sharedGlobalData] acceptRelation:relation];
        [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
        [[FTToolBox sharedGlobalData] displayCheckmakForView:self.view];
        [self performSelector:@selector(back:) withObject:nil afterDelay:1];
    }else{
        [[FTToolBox sharedGlobalData] networkUnavailableAlert];
    }
}

/* Refuser une demande
 * 1. On supprime la relation dans le backend
 */
-(void)demandRefusedActionPressed:(UIButton *) sender {
    id superView = sender.superview;
    while (superView && ![superView isKindOfClass:[UICollectionViewCell class]]) {
        superView = [superView superview];
    }
    NSIndexPath *selectedPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)superView];
    PFObject *relation = _demandes[selectedPath.row];

    if([[FTToolBox sharedGlobalData] isNetworkAvailable])
    {
        [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Chargement" forView:self.view];
        [[FTParseBackendApi sharedGlobalData] refusedRelation:relation];
        [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
        [[FTToolBox sharedGlobalData] displayCheckmakForView:self.view];
        [self performSelector:@selector(back:) withObject:nil afterDelay:1];
    }else{
        [[FTToolBox sharedGlobalData] networkUnavailableAlert];
    }
}

#pragma mark - Data Source Implementation DZNEmptyDataSet
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text;
    
    if(_isNetworkAvailable){
        text = @"Aucune demandes";
    }else{
        text = [[FTToolBox sharedGlobalData] titleWhenNetworkUnavailable];
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text;
    
    if(_isNetworkAvailable){
        text = @"Vous n'avez reçues aucune demande d'amitiés pour le moment.";
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
 - (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"avatar.jpg"];
 }
*/

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    
    return [UIColor whiteColor];

}

@end
