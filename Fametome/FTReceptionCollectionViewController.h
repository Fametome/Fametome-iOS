//
//  FTReceptionCollectionViewController.h
//  Fametome
//
//  Created by Famille on 13/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "UIScrollView+EmptyDataSet.h"
#import "FTCoreDataApi.h"
#import "FTToolBox.h"
#import "FTParseBackendApi.h"
#import "FTReceptionViewCell.h"
#import "FTMessageContentViewController.h"

#import "SlideNavigationController.h"

@interface FTReceptionCollectionViewController : UICollectionViewController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SlideNavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSString *selectedMessageObjectId;
//@property (strong, nonatomic) PFUser *author;

@end
