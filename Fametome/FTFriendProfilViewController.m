//
//  FTFriendProfilViewController.m
//  Fametome
//
//  Created by Famille on 26/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTFriendProfilViewController.h"

@interface FTFriendProfilViewController ()

@end

@implementation FTFriendProfilViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* INITIALISATION DEFAULT */
    NSLog(@"Friend object ID: %@", _friendObjectId);
    self.faces = [[NSMutableArray alloc] init];
    self.facesEmptyTitleLabel.hidden = YES;
    [[FTToolBox sharedGlobalData] makeCornerRadius:self.facesEmptyTitleLabel];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Retour" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    /* Initialisation - End */
    
    /* Bordures */
    [[FTToolBox sharedGlobalData] makeCornerRadiusAndBorder:self.usernameLabel];
    [[FTToolBox sharedGlobalData] makeCornerRadiusAndBorder:self.avatarImageView];
    [[FTToolBox sharedGlobalData] makeCornerRadius:self.facesView];
    [[FTToolBox sharedGlobalData] makeCornerRadius:self.statistiquesView];
    [[FTToolBox sharedGlobalData] makeCornerRadius:self.sendFlashButton];
    /* Bordures */
    
    /* Backend */
    [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Chargement" forView:self.view];
    
    /* Chargement des statistiques */
    
    // Initialisation
    _friendsNumber.text = @"...";
    _messagesSendNumber.text = @"...";
    _facesNumber.text = @"...";

    PFQuery *queryUser = [PFUser query];
    queryUser.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [queryUser whereKey:@"objectId" equalTo:_friendObjectId];
    [queryUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            PFUser *friend = (PFUser *)object;
            _friend = friend; // Pour segue method
            self.title = [NSString stringWithFormat:@"Profil de %@", friend.username];

            /* Statistiques */
            _messagesSendNumber.text = [[NSString alloc] initWithFormat:@"%d", [friend[@"messageSendCount"] intValue]];
            /* Statistiques - End */
            
            /* Avatar + Username */
            self.usernameLabel.text = friend.username;
            PFImageView *imageView = self.avatarImageView;
            imageView.image = [UIImage imageNamed:@"avatar.jpg"];
            imageView.file = (PFFile *)friend[@"avatar"];
            [imageView loadInBackground];
            /* Avatar + Username - End */
            
            /* Faces */
            PFQuery *query = [PFQuery queryWithClassName:@"Face"];
            query.cachePolicy = kPFCachePolicyNetworkElseCache;
            [query whereKey:@"user" equalTo:friend];
            //query.limit = 3; -> besoin pour les stats
            [query orderByDescending:@"createdAt"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                if(!error){
                    self.faces = (NSMutableArray *)objects;

                    if(self.faces.count == 0){
                        self.faceOneImageView.hidden = YES;
                        self.faceThreeImageView.hidden = YES;
                        self.showAllFacesButton.hidden = YES;
                        self.facesEmptyTitleLabel.hidden = NO;
                    }else{
                        if (self.faces.count >= 1){
                            PFUser *face1 = (PFUser *)self.faces[0];
                            self.faceOneImageView.file = (PFFile *)face1[@"image"];
                            [self.faceOneImageView loadInBackground];
                        }
                        
                        if (self.faces.count >= 2){
                            PFUser *face2 = (PFUser *)self.faces[1];
                            self.faceTwoImageView.file = (PFFile *)face2[@"image"];
                            [self.faceTwoImageView loadInBackground];
                        }
                        
                        if(self.faces.count >= 3){
                            PFUser *face3 = (PFUser *)self.faces[2];
                            self.faceThreeImageView.file = (PFFile *)face3[@"image"];
                            [self.faceThreeImageView loadInBackground];
                        }
                    }
                    
                    // Stats face
                    _facesNumber.text = [NSString stringWithFormat:@"%d", _faces.count];

                }else{
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                }
            }];
            /* Faces - End */

        }else{
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        
        [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
    }];
    
    // Stats nombre d'amis des amis
    PFQuery *oneSens = [PFQuery queryWithClassName:@"Relation"];
    [oneSens whereKey:@"demandeurObjectId" equalTo:_friendObjectId];
    [oneSens whereKey:@"statut" greaterThanOrEqualTo:@1];
    
    PFQuery *otherSens = [PFQuery queryWithClassName:@"Relation"];
    [otherSens whereKey:@"receveurObjectId" equalTo:_friendObjectId];
    [otherSens whereKey:@"statut" greaterThanOrEqualTo:@1];

    PFQuery *queryFriendsRelation = [PFQuery orQueryWithSubqueries:@[oneSens,otherSens]];
    [queryFriendsRelation findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(!error){
            _friendsNumber.text = [NSString stringWithFormat:@"%d", objects.count];
        }
    }];
    
    /* Backend - End */
}

- (IBAction) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - IBAction Method
- (IBAction)showFaces:(id)sender {
    NSLog(@"voir les faces");
    [self performSegueWithIdentifier:@"showFriendFacesSegue" sender:self];
}

#pragma mark - Perform Segue Method
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showFriendFacesSegue"])
    {
        FTFriendFacesViewController *nextController = segue.destinationViewController;
        [nextController setFriend:_friend];
    }
    
    if([segue.identifier isEqualToString:@"sendMessageFromFriendProfilSegue"])
    {
        FTSendCollectionViewController *nextController = segue.destinationViewController;
        [nextController setDestinataire:_friend];
    }
    
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

#pragma mark - Setters methods
- (void) setFriendObjectId:(NSString *)friendObjectId{
    _friendObjectId = friendObjectId;
}

@end
