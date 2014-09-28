//
//  FTFriendProfilViewController.h
//  Fametome
//
//  Created by Famille on 26/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FTToolBox.h"
#import "FTFriendFacesViewController.h"
#import "FTSendCollectionViewController.h"

@interface FTFriendProfilViewController : UIViewController

@property (weak, nonatomic) IBOutlet PFImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendFlashButton;

/* Intern */
@property (strong, nonatomic) NSMutableArray *faces;
/* Intern - End */

/* Faces */
@property (weak, nonatomic) IBOutlet UIView *facesView;
@property (weak, nonatomic) IBOutlet UILabel *facesEmptyTitleLabel;
@property (weak, nonatomic) IBOutlet PFImageView *faceOneImageView;
@property (weak, nonatomic) IBOutlet PFImageView *faceTwoImageView;
@property (weak, nonatomic) IBOutlet PFImageView *faceThreeImageView;
@property (weak, nonatomic) IBOutlet UIButton *showAllFacesButton;
/* Faces - End */

/* Statistiques */
@property (weak, nonatomic) IBOutlet UIView *statistiquesView;
@property (weak, nonatomic) IBOutlet UILabel *friendsNumber;
@property (weak, nonatomic) IBOutlet UILabel *messagesSendNumber;
@property (weak, nonatomic) IBOutlet UILabel *facesNumber;
/* Statistiques - End */

// Setter Method for Segue
@property (nonatomic, strong) NSString *friendObjectId;
- (void) setFriendObjectId:(NSString *)friendObjectId;

@property (nonatomic, strong) PFUser *friend;

// IBAction
- (IBAction)showFaces:(id)sender;

@end
