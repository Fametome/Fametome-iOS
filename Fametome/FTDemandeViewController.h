//
//  FTDemandeViewController.h
//  Fametome
//
//  Created by Famille on 12/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTParseBackendApi.h"
#import "MBProgressHUD.h"
#import "FTDemandeViewCell.h"
#import "UIScrollView+EmptyDataSet.h"

@interface FTDemandeViewController : UICollectionViewController <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (strong, nonatomic) NSMutableArray *demandes;
@property BOOL isNetworkAvailable;

@end
