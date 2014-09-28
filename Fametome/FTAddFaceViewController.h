//
//  FTAddFaceViewController.h
//  Fametome
//
//  Created by Famille on 07/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTToolBox.h"
#import "FTParseBackendApi.h"

@interface FTAddFaceViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
// Story board
@property (weak, nonatomic) IBOutlet UIImageView *faceImageView;
@property (weak, nonatomic) IBOutlet UITextField *faceSmsField;
@property (weak, nonatomic) IBOutlet UIButton *faceSubmitButton;

- (IBAction)addFaceSubmit:(id)sender;
- (IBAction)textFieldReturn:(id)sender;

@end
