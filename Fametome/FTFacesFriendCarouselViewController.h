//
//  FTFacesFriendCarouselViewController.h
//  Fametome
//
//  Created by Famille on 30/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FTToolBox.h"
#import "FTFacesFriendCarouselCellView.h"

@interface FTFacesFriendCarouselViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

// Segue Methods
@property (strong, readonly) NSMutableArray *faces;
- (void) setFaces:(NSMutableArray *)faces;
@property (nonatomic) int *currentIndex;
- (void) setCurrentIndex:(int *)currentIndex;
@property (nonatomic, strong) PFUser *friend;
- (void) setFriend:(PFUser *)friend;

@end
