//
//  FTChooseRecipientsViewController.h
//  Fametome
//
//  Created by Famille on 07/09/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FTToolBox.h"
#import "FTCoreDataApi.h"
#import "FTParseBackendApi.h"
#import "FTCoreDataApi.h"
#import "UIScrollView+EmptyDataSet.h"
#import "FTChooseRecipientsViewCell.h"

#import "SlideNavigationController.h"
#import "FTFriendProfilViewController.h"

@interface FTChooseRecipientsViewController : UICollectionViewController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SlideNavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSMutableArray *recipients;

@end
