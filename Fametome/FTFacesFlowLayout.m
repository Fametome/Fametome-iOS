//
//  FTFacesFlowLayout.m
//  Fametome
//
//  Created by Famille on 07/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTFacesFlowLayout.h"

@implementation FTFacesFlowLayout

- (void)setCurrentCellScale:(CGFloat)scale
{
    _currentCellScale = scale;
    [self invalidateLayout];
    
}

- (void)setCurrentCellCenter:(CGPoint)origin
{
    _currentCellCenter = origin;
    [self invalidateLayout];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    [self modifyLayoutAttributes:attributes];
    
    return attributes;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *allAttributesInRect = [super layoutAttributesForElementsInRect:rect];
    
    for(UICollectionViewLayoutAttributes *cellAttributes in allAttributesInRect)
    {
        [self modifyLayoutAttributes:cellAttributes];
    }
    
    return allAttributesInRect;
}

- (void)modifyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    if ([layoutAttributes.indexPath isEqual:_currentCellPath])
    {
        layoutAttributes.transform3D = CATransform3DMakeScale(_currentCellScale, _currentCellScale, 1.0);
        layoutAttributes.center = _currentCellCenter;
        layoutAttributes.zIndex = 1;
    }
}

@end
