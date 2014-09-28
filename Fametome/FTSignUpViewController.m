//
//  FTSignUpViewController.m
//  Fametome
//
//  Created by Famille on 07/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTSignUpViewController.h"

@interface FTSignUpViewController ()

@end

@implementation FTSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Design
    self.navigationController.navigationBar.hidden = YES;
    [[FTToolBox sharedGlobalData] designExternTextField:self.emailField];
    [[FTToolBox sharedGlobalData] designExternTextField:self.usernameField];
    [[FTToolBox sharedGlobalData] designExternTextField:self.passwordField];
    [[FTToolBox sharedGlobalData] designExternButton:self.signupButton];
    
    // Titre
    NSString *string = @"Inscription";
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:string];
    NSDictionary *attributesForFirstWord = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:50.0f], NSForegroundColorAttributeName: [UIColor orangeColor]};
    NSDictionary *attributesForSecondWord = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:50.0f], NSForegroundColorAttributeName: [UIColor whiteColor]};
    [title setAttributes:attributesForFirstWord range:[string rangeOfString:@"I"]];
    [title setAttributes:attributesForSecondWord range:[string rangeOfString:@"nscription"]];
    self.fametomeTitleLabel.attributedText = [[NSAttributedString alloc] initWithAttributedString:title];
}

#pragma mark - Keyboard Gesture
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if([self.emailField isFirstResponder] && [touch view] != self.emailField)
        [self.emailField resignFirstResponder];
    
    if ([self.usernameField isFirstResponder] && [touch view] != self.usernameField)
        [self.usernameField resignFirstResponder];

    if ([self.passwordField isFirstResponder] && [touch view] != self.passwordField)
        [self.passwordField resignFirstResponder];
    
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - SignUp Method
- (IBAction)cancelSignUp:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)signUp:(id)sender
{
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [[FTParseBackendApi sharedGlobalData] signUp:email withUsername:username andWithPassword:password fromController:self andWithEmailField:self.emailField and:self.usernameField and:self.passwordField];
}

@end
