//
//  FTLoginViewController.m
//
//
//  Created by Famille on 07/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTLoginViewController.h"

@interface FTLoginViewController ()

@end

@implementation FTLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Already connected
    if([PFUser currentUser])
        [[FTToolBox sharedGlobalData] redirectToReception:self];

    // Design
    [[FTToolBox sharedGlobalData] designExternTextField:self.usernameField];
    [[FTToolBox sharedGlobalData] designExternTextField:self.passwordField];
    [[FTToolBox sharedGlobalData] designExternButton:self.loginButton];
    
    // Titre
    NSString *string = @"Fametome";
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:string];
    NSDictionary *attributesForFirstWord = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:50.0f], NSForegroundColorAttributeName: [UIColor orangeColor]};
    NSDictionary *attributesForSecondWord = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:50.0f], NSForegroundColorAttributeName: [UIColor whiteColor]};
    [title setAttributes:attributesForFirstWord range:[string rangeOfString:@"F"]];
    [title setAttributes:attributesForSecondWord range:[string rangeOfString:@"ametome"]];
    self.fametomeTitleLabel.attributedText = [[NSAttributedString alloc] initWithAttributedString:title];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [SlideNavigationController sharedInstance].navigationBar.hidden = YES;
}

#pragma mark - Keyboard Gesture
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    
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

#pragma mark - Login Method
- (IBAction)login:(id)sender
{
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [[FTParseBackendApi sharedGlobalData] login:username withPassword:password fromController:self andWithUsernameField:self.usernameField and:self.passwordField];
}
@end
