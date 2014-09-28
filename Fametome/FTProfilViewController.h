//
//  FTProfilViewController.h
//  Fametome
//
//  Created by Famille on 06/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTCoreDataApi.h"
#import "FTToolBox.h"
#import "FTParseBackendApi.h"
#import "SlideNavigationController.h"

@interface FTProfilViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, SlideNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *plusLabel;

/* INTERN */
@property(strong, nonatomic) NSMutableArray *faces;
@property(strong, nonatomic) NSMutableArray *friends;
/* INTERN - END */

/* FACES */
@property (weak, nonatomic) IBOutlet UIView *facesView;
@property (weak, nonatomic) IBOutlet UILabel *facesTitleLabel;

@property (weak, nonatomic) IBOutlet PFImageView *faceOneImageView;
@property (weak, nonatomic) IBOutlet PFImageView *faceTwoImageView;
@property (weak, nonatomic) IBOutlet PFImageView *faceThreeImageView;

@property (weak, nonatomic) IBOutlet UIButton *showAllFacesButton;
@property (weak, nonatomic) IBOutlet UIButton *showAddFaceButton;
@property (weak, nonatomic) IBOutlet UIButton *showAddFaceEmptyButton;
/* FACES - END */

/* FRIENDS */
@property (weak, nonatomic) IBOutlet UIView *friendsView;
@property (weak, nonatomic) IBOutlet UILabel *friendsTitleLabel;

@property (weak, nonatomic) IBOutlet PFImageView *friendOneImageView;
@property (weak, nonatomic) IBOutlet PFImageView *friendTwoImageView;
@property (weak, nonatomic) IBOutlet PFImageView *friendThreeImageView;

@property (weak, nonatomic) IBOutlet UIButton *showAllFriendButton;
@property (weak, nonatomic) IBOutlet UIButton *showAddFriendButton;
/* FRIENDS - END */

/* STATISTIQUES */
@property (weak, nonatomic) IBOutlet UIView *statistiquesView;

@property (weak, nonatomic) IBOutlet UILabel *friendsNumber;
@property (weak, nonatomic) IBOutlet UILabel *messagesSendNumber;
@property (weak, nonatomic) IBOutlet UILabel *facesNumber;
/* STATISTIQUES - END */


-(void)updateAvatar;
- (IBAction)addFace:(id)sender;
- (IBAction)addFriend:(id)sender;
- (IBAction)showFriends:(id)sender;

@end
