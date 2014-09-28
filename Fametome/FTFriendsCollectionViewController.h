//
//  FTFriendsCollectionViewController.h
//  Fametome
//
//  Created by Famille on 12/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FTToolBox.h"
#import "FTCoreDataApi.h"
#import "FTParseBackendApi.h"
#import "FTCoreDataApi.h"
#import "UIScrollView+EmptyDataSet.h"
#import "FTFriendViewCell.h"
#import "FTFriendsFlowLayout.h"

#import "SlideNavigationController.h"
#import "FTFriendProfilViewController.h"

@interface FTFriendsCollectionViewController : UICollectionViewController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SlideNavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *friends;
@property BOOL isNetworkAvailable;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end
