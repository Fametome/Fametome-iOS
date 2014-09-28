//
//  FTConditionsViewController.m
//  Fametome
//
//  Created by Famille on 12/09/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTConditionsViewController.h"

@interface FTConditionsViewController ()

@end

@implementation FTConditionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Conditions d'utilisation";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Retour" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    [[FTToolBox sharedGlobalData] makeCornerRadius:_textViewFirst];
    [[FTToolBox sharedGlobalData] makeCornerRadius:_textViewSecond];
    
}

- (IBAction) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
