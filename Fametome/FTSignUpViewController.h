//
//  FTSignUpViewController.h
//  Fametome
//
//  Created by Famille on 07/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTParseBackendApi.h"
#import "FTToolBox.h"
#import "FTParseBackendApi.h"

@interface FTSignUpViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *fametomeTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;

- (IBAction)cancelSignUp:(id)sender;
- (IBAction)signUp:(id)sender;
- (IBAction)textFieldReturn:(id)sender;
@end
