//
//  FTProfilViewController.m
//  Fametome
//
//  Created by Famille on 06/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTProfilViewController.h"


@interface FTProfilViewController ()

@end

@implementation FTProfilViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* INITIALISATION DEFAULT */
    [[FTToolBox sharedGlobalData] designNavbar:self.navigationController.navigationBar];
    PFUser *currentUser = [PFUser currentUser];
    self.faces = [[NSMutableArray alloc] init];
    
    // Avatar + Username
    [[FTToolBox sharedGlobalData] makeCornerRadius:_plusLabel];
    [_plusLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];
    self.usernameLabel.text = currentUser.username;
    PFImageView *imageView = self.avatarImageView;
    imageView.image = [UIImage imageNamed:@"avatar.jpg"];
    imageView.file = (PFFile *)currentUser[@"avatar"];
    [imageView loadInBackground];
    
    // Ajout de l'évenement Cliquer sur *avatarImageView
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateAvatar)];
    singleTap.numberOfTapsRequired = 1;
    self.avatarImageView.userInteractionEnabled = YES;
    [self.avatarImageView addGestureRecognizer:singleTap];
    
    // Bordures
    [[FTToolBox sharedGlobalData] makeCornerRadiusAndBorder:self.usernameLabel];
    [[FTToolBox sharedGlobalData] makeCornerRadiusAndBorder:self.avatarImageView];
    [[FTToolBox sharedGlobalData] makeCornerRadius:self.facesView];
    [[FTToolBox sharedGlobalData] makeCornerRadius:self.friendsView];
    [[FTToolBox sharedGlobalData] makeCornerRadius:self.statistiquesView];
    
    // Divers
    self.showAddFaceEmptyButton.hidden = YES;
    [[FTToolBox sharedGlobalData] makeCornerRadius:self.showAddFaceEmptyButton];
    self.facesTitleLabel.text = @"...";
    
    self.showAddFriendButton.hidden = YES;
    [[FTToolBox sharedGlobalData] makeCornerRadius:self.showAddFriendButton];
    self.friendsTitleLabel.text = @"...";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadData];
}

- (void) loadData{
    /* BACKEND */
    PFUser *currentUser = [PFUser currentUser];
    [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Chargement" forView:self.view];
    
    // On récupère toutes les faces de l'utilisateur courant
    PFQuery *query = [PFQuery queryWithClassName:@"Face"];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    //query.limit = 3; -> besoin pour les stats
    [query whereKey:@"user" equalTo:currentUser];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(!error){
            self.faces = (NSMutableArray *)objects;
            
            // Initialisation
            if(self.faces.count == 0){
                self.faceOneImageView.hidden = YES;
                self.faceThreeImageView.hidden = YES;
                self.showAddFaceButton.hidden = YES;
                self.showAllFacesButton.hidden = YES;
                self.showAddFaceEmptyButton.hidden = NO;
                self.facesTitleLabel.text = @"Vous n'avez pas de faces";
                
            }else{
                self.facesTitleLabel.text = [NSString stringWithFormat:@"%d faces", self.faces.count];
                
                if(_faces.count == 1){
                    _facesTitleLabel.text = [NSString stringWithFormat:@"%d face", self.faces.count];
                }
                
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

            // Statistiques des faces
            _facesNumber.text = [NSString stringWithFormat:@"%d", _faces.count];
            
            [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
        }else{
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];
    
    
    
    /* Chargement des ObjectId des amis */
    _friends = [[NSMutableArray alloc] init];
    
    PFQuery *oneSens = [PFQuery queryWithClassName:@"Relation"];
    oneSens.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [oneSens whereKey:@"demandeurObjectId" equalTo:currentUser.objectId];
    [oneSens whereKey:@"statut" greaterThanOrEqualTo:@1];
    
    PFQuery *otherSens = [PFQuery queryWithClassName:@"Relation"];
    otherSens.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [otherSens whereKey:@"receveurObjectId" equalTo:currentUser.objectId];
    [otherSens whereKey:@"statut" greaterThanOrEqualTo:@1];
    
    PFQuery *query2 = [PFQuery orQueryWithSubqueries:@[oneSens,otherSens]];
    query2.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            
            for (PFObject *relation in objects) {
                NSString *demandeurObjectId = relation[@"demandeurObjectId"];
                NSString *receveurObjectId = relation[@"receveurObjectId"];
                
                if(relation[@"demandeurObjectId"] == currentUser.objectId){
                    [_friends addObject: receveurObjectId];
                }else{
                    [_friends addObject: demandeurObjectId];
                }
            }
            
            // Initialisation
            if(_friends.count == 0){
                _friendOneImageView.hidden = YES;
                _friendThreeImageView.hidden = YES;
                _showAllFriendButton.hidden = YES;
                _showAddFriendButton.hidden = NO;
                _friendsTitleLabel.text = @"Vous n'avez pas d'amis";
                
            }else{
                self.friendsTitleLabel.text = [NSString stringWithFormat:@"%d amis", self.friends.count];
                
                if(_friends.count >= 1){
                    
                    PFQuery *query3 = [PFUser query];
                    query3.cachePolicy = kPFCachePolicyCacheThenNetwork;
                    [query3 whereKey:@"objectId" equalTo:_friends[0]];
                    [query3 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if(!error){
                            self.friendsTitleLabel.text = [NSString stringWithFormat:@"%d amis", self.friends.count];
                            PFUser *friend1 = (PFUser *)object;
                            _friendOneImageView.image = [UIImage imageNamed:@"avatar.jpg"];
                            _friendOneImageView.file = (PFFile *)friend1[@"avatar"];
                            [_friendOneImageView loadInBackground];
                        }else{
                            NSLog(@"Error %@ %@", error, [error userInfo]);
                        }
                    }];
                }
                
                if(_friends.count >= 2){
                    
                    PFQuery *query4 = [PFUser query];
                    query4.cachePolicy = kPFCachePolicyCacheThenNetwork;
                    [query4 whereKey:@"objectId" equalTo:_friends[1]];
                    [query4 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if(!error){
                            PFUser *friend2 = (PFUser *)object;
                            _friendTwoImageView.image = [UIImage imageNamed:@"avatar.jpg"];
                            _friendTwoImageView.file = (PFFile *)friend2[@"avatar"];
                            [_friendTwoImageView loadInBackground];
                        }else{
                            NSLog(@"Error %@ %@", error, [error userInfo]);
                        }
                    }];
                }
                
                if(_friends.count >= 3){
                    
                    PFQuery *query5 = [PFUser query];
                    query5.cachePolicy = kPFCachePolicyCacheThenNetwork;
                    [query5 whereKey:@"objectId" equalTo:_friends[2]];
                    [query5 getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        if(!error){
                            PFUser *friend3 = (PFUser *)object;
                            _friendThreeImageView.image = [UIImage imageNamed:@"avatar.jpg"];
                            _friendThreeImageView.file = (PFFile *)friend3[@"avatar"];
                            [_friendThreeImageView loadInBackground];
                        }else{
                            NSLog(@"Error %@ %@", error, [error userInfo]);
                        }
                    }];
                }
                
                // Statistiques des amis
                _friendsNumber.text = [NSString stringWithFormat:@"%d", _friends.count];
                
            }
        }else{
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];
    
    /* Chargement des statistiques */
    
    // Initialisation
    _friendsNumber.text = @"...";
    _messagesSendNumber.text = @"...";
    _facesNumber.text = @"...";
    
    // Appel au serveur
    PFQuery *queryUser = [PFUser query];
    queryUser.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [queryUser whereKey:@"objectId" equalTo:currentUser.objectId];
    [queryUser getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            PFUser *user = (PFUser *)object;
            _messagesSendNumber.text = [[NSString alloc] initWithFormat:@"%d", [user[@"messageSendCount"] intValue]];
        }else{
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];
    
    /* BACKEND - END */
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

#pragma mark - Controller Event Methods
-(void)updateAvatar{
    
    if([[FTToolBox sharedGlobalData] isCameraAvailable]){
        UIImagePickerController *imagePicker = [[FTToolBox sharedGlobalData] activeCamera];
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:NO completion:nil];

    }else{
        [[FTToolBox sharedGlobalData] cameraUnavailableAlert];
    }
}

- (IBAction)addFace:(id)sender{
    // Redirection depuis le StoryBoard
}

- (IBAction)addFriend:(id)sender {
    [[FTToolBox sharedGlobalData] redirectToFriends:self];
}

- (IBAction)showFriends:(id)sender {
    [[FTToolBox sharedGlobalData] redirectToFriends:self];
}

#pragma mark - Image Picker Controller delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:NO completion:nil];
    [[FTParseBackendApi sharedGlobalData] addAvatarInBackground:image andUpdate:self.avatarImageView forUser:[PFUser currentUser] inController:self];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
