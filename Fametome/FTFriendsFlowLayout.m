//
//  FTFriendsFlowLayout.m
//  Fametome
//
//  Created by Famille on 16/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTFriendsFlowLayout.h"

@implementation FTFriendsFlowLayout

- (void) setCurrentCellScale:(CGFloat)scale
{
    _currentCellScale = scale;
    [self invalidateLayout];
}

- (void) setCurrentCellCenter:(CGPoint)origin
{
    _currentCellCenter = origin;
    [self invalidateLayout];
}

@end
