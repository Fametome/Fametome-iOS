//
//  FTParametresViewController.h
//  Fametome
//
//  Created by Famille on 09/09/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FTToolBox.h"

@interface FTParametresViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

- (IBAction)logout:(id)sender;

@end
