//
//  FTMessageContentViewController.h
//  Fametome
//
//  Created by Famille on 13/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FTToolBox.h"
#import "FTCoreDataApi.h"
#import "FTParseBackendApi.h"
#import "FTFlashContentViewController.h"
#import "MBProgressHUD.h"

@interface FTMessageContentViewController : UIViewController <UIPageViewControllerDataSource>

// UIPageViewController
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) NSArray *pageContent;
- (void) goToNextPage;

// Intern
@property (strong, nonatomic) NSMutableArray *flashsToDelete; // Flashs potentiellement à supprimer.
@property (strong, nonatomic) NSMutableArray *flashs; // Flashs fonctionnement interne.
@property (strong, nonatomic) PFUser *author;

// Prepare For Segue
@property (nonatomic, strong) NSString *messageObjectId;
- (void) setMessage:(NSString *)messageObjectId;

@end
