//
//  FTCarouselFacesProfilViewController.h
//  Fametome
//
//  Created by Famille on 24/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FTToolBox.h"
#import "FTCarouselFacesProfilViewCell.h"

@interface FTCarouselFacesProfilViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *faces;
@property (nonatomic) int *currentIndex;
- (void) setCurrentIndex:(int *)currentIndex;

@end
