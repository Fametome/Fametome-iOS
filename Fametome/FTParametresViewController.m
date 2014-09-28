//
//  FTParametresViewController.m
//  Fametome
//
//  Created by Famille on 09/09/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTParametresViewController.h"

@interface FTParametresViewController ()

@end

@implementation FTParametresViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _usernameLabel.text = [PFUser currentUser].username;
    _emailLabel.text = [PFUser currentUser].email;
    
}

- (IBAction)logout:(id)sender {
    [[FTToolBox sharedGlobalData] logout:self];
}

@end
