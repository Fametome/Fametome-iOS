//
//  FTSearchFriendViewController.h
//  Fametome
//
//  Created by Famille on 11/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTToolBox.h"
#import "FTParseBackendApi.h"
#import "FTCoreDataApi.h"
#import "MBProgressHUD.h"

@interface FTSearchFriendViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *searchFriendTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchFriendButton;

- (IBAction) back:(id)sender;
- (IBAction)searchFriendSubmit:(id)sender;

@end
