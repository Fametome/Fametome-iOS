//
//  FTFacesViewController.h
//  Fametome
//
//  Created by Famille on 07/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTCoreDataApi.h"
#import "FTToolBox.h"
#import "FTFacesViewCell.h"
#import "Face.h"
#import "FTFacesFlowLayout.h"
#import "SlideNavigationController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "FTCarouselFacesProfilViewController.h"

@interface FTFacesViewController : UICollectionViewController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SlideNavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *faces;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end
