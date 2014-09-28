//
//  FTLeftMenuViewController.h
//  Fametome
//
//  Created by Famille on 17/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SlideNavigationController.h"
#import "FTToolBox.h"

@interface FTLeftMenuViewController : UITableViewController <UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL slideOutAnimationEnabled;

// Own code
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end
