//
//  FTFriendsFlowLayout.h
//  Fametome
//
//  Created by Famille on 16/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTFriendsFlowLayout : UICollectionViewFlowLayout

@property (strong, nonatomic) NSIndexPath *currentCellPath;
@property (nonatomic) CGPoint currentCellCenter;
@property (nonatomic) CGFloat currentCellScale;

@end
