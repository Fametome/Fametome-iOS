//
//  FTFriendFacesViewController.h
//  Fametome
//
//  Created by Famille on 29/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTCoreDataApi.h"
#import "FTToolBox.h"
#import "SlideNavigationController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "FTFriendFaceViewCell.h"
#import "FTFacesFriendCarouselViewController.h"

@interface FTFriendFacesViewController : UICollectionViewController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SlideNavigationControllerDelegate>

// Segue
@property (nonatomic, strong) PFUser *friend;
- (void) setFriend:(PFUser *)friend;

// Carousel
@property (strong, nonatomic) NSMutableArray *faces;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end
