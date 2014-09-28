//
//  FTChooseFaceViewController.h
//  Fametome
//
//  Created by Famille on 04/09/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTCoreDataApi.h"
#import "FTToolBox.h"
#import "FTChooseFaceViewCell.h"
#import "Face.h"
#import "FTFacesFlowLayout.h"
#import "SlideNavigationController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "FTCarouselFacesProfilViewController.h"
#import "FTChooseFaceHeaderView.h"
#import "FTChooseFaceFooter.h"

@interface FTChooseFaceViewController : UICollectionViewController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, SlideNavigationControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *faces;

- (IBAction)cancelChooseFaceButton:(id)sender;


@end
