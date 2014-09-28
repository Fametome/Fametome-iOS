//
//  FTSendCollectionViewController.h
//  Fametome
//
//  Created by Famille on 31/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FTToolBox.h"
#import "FTSendCollectionViewCell.h"
#import "FTSendFooterReusableView.h"
#import "FTChooseFaceViewController.h"
#import "SlideNavigationController.h"

@interface FTSendCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>

// Storyboard Property

// Intern Property
@property (nonatomic, strong) PFObject *message;
@property (nonatomic, strong) NSMutableArray *flashs;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property BOOL isRefresh;

// Choose Face Method
@property BOOL mustPerform;
@property (nonatomic, strong) NSString *faceCurrentObjectId;
@property (nonatomic, strong) NSString *faceCurrentSms;
@property (nonatomic, strong) UIImage *faceCurrentImage;

// Setter Method
@property (nonatomic, strong) PFUser *destinataire;

// IBAction Method
- (IBAction)addFlash:(id)sender;

// Hide keyboard
- (IBAction)textFieldReturn:(id)sender;

@end
