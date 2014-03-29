//
//  CHCircularCollectionLayout.m
//  RotatingCollectionView
//
//  Created by Cillian on 22/03/2014.
//  Copyright (c) 2014 Cillian. All rights reserved.
//



#import "CHCircularCollectionLayout.h"
#import <math.h>
#import "Math.h"
#import "PointObj.h"

#define kCellHeight 50.0f
#define kCellWidth 50.0f

@interface CHCircularCollectionLayout()

@property (copy, nonatomic) NSArray *points;
@property (nonatomic, strong) NSMutableSet *insertedSet;
@property (nonatomic, strong) NSMutableSet *deletedSet;

@end

@implementation CHCircularCollectionLayout

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    //..
    self.insertedSet = [NSMutableSet set];
    self.deletedSet = [NSMutableSet set];
}

- (void)prepareLayout
{
    
    [super prepareLayout];
    
    // get a circle of points
    
    NSMutableArray *array = [NSMutableArray new];
    
    if (self.sectionStyle == SectionStyleMultipleRings) {
        
        for (NSInteger sectionCount = 0; sectionCount < self.collectionView.numberOfSections; sectionCount++) {
            NSMutableArray *section = [NSMutableArray new];
            
            CGFloat distanceFromCenter = 100 - (25 * sectionCount);
            NSInteger numItems = [self.collectionView numberOfItemsInSection:sectionCount];
            CGFloat angle = 360.0f/numItems;
            
            for (CGFloat currentAngle = 0; currentAngle <= 360; currentAngle+=angle) {
                CGFloat x = distanceFromCenter * cos([Math degreesToRadians:currentAngle]) + self.centerPoint.x;
                CGFloat y = distanceFromCenter * sin([Math degreesToRadians:currentAngle]) + self.centerPoint.y;
                
                PointObj *point = [[PointObj alloc] initWithX:x andY:y];
                [section addObject:point];
            }
            
            [array addObject:section];
        }
        
    }
    
    else if (self.sectionStyle == SectionStyleSingleRing) {
        
        CGFloat resetAngle = 0;
        
        for (NSInteger sectionCount = 0; sectionCount < self.collectionView.numberOfSections; sectionCount++) {
            NSMutableArray *section = [NSMutableArray new];
            
            CGFloat distanceFromCenter = 100;
            NSInteger numItems = [self.collectionView numberOfItemsInSection:sectionCount];
            CGFloat angle = 360.0f/(numItems * self.collectionView.numberOfSections);
            
            NSInteger itemCount = 0;
            for (CGFloat currentAngle = resetAngle; itemCount < [self.collectionView numberOfItemsInSection:sectionCount]; currentAngle+=angle, itemCount++) {
                CGFloat x = distanceFromCenter * cos([Math degreesToRadians:currentAngle]) + self.centerPoint.x;
                CGFloat y = distanceFromCenter * sin([Math degreesToRadians:currentAngle]) + self.centerPoint.y;
                
                PointObj *point = [[PointObj alloc] initWithX:x andY:y];
                [section addObject:point];
                resetAngle = currentAngle+angle;
            }
            
            [array addObject:section];
        }
        
    }
    
    _points = [NSArray arrayWithArray:array];
    
}

- (double)positionForAttributes:(UICollectionViewLayoutAttributes *)attributes forItemAtIndexPath:(NSIndexPath *)indexPath
{

    // the cellection view center
    CGPoint pointA = self.centerPoint;

    // the collection view cell center
    CGPoint pointC = [(PointObj *)[[self.points objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] point];
    
    // this is a virtual point
    CGPoint pointB = CGPointMake(pointA.x, pointC.y);
    
    double C = 0;
    
    double a = [Math distanceBetween:pointC and:pointB];
    double b = [Math distanceBetween:pointA and:pointC];
    double c = [Math distanceBetween:pointA and:pointB];
    
    double a2 = pow(a, 2);
    double b2 = pow(b, 2);
    double c2 = pow(c, 2);
    double ab2 = 2 * a * b;
    
    double val = (a2 + b2 - c2)/ab2;
    
    // check for dividing by zero like!
    val = ab2 == 0 ? 0 : val;
    
    double acosVal = acos(val);
    C = [Math radiansToDegrees:acosVal];
    
    double answer = 0;
    if (pointC.y + attributes.size.height/2 < self.centerPoint.y) {
        
        // top left
        if (pointC.x + attributes.size.width/2 < self.centerPoint.x) {
            answer = C - 90;
        }
        // top right
        else {
            answer = 90 - C;
        }
    }
    else {
        // bottom left
        if (pointC.x + attributes.size.width/2 < self.centerPoint.x) {
            answer = 270 - C;
        }
        // bottom right
        else {
            answer = C - 270;
        }
    }
    
    
    NSLog(@"%d: %f", indexPath.row, answer);
    return answer;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger sectionCount = 0; sectionCount < self.collectionView.numberOfSections; sectionCount++) {
        for (NSInteger itemCount = 0; itemCount < [self.collectionView numberOfItemsInSection:sectionCount]; itemCount++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:itemCount inSection:sectionCount];
            [attributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
        }
    }
    
    return attributes;
}

- (CGSize)collectionViewContentSize
{
    return self.collectionView.bounds.size;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    
    PointObj *point = [[self.points objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    attributes.size = CGSizeMake(kCellWidth, kCellHeight);
    attributes.center = CGPointMake(point.x, point.y);

    
    if (self.cellStyle == CellStyleRotateToCenter) {
        double rotation = [self positionForAttributes:attributes forItemAtIndexPath:indexPath];
        attributes.transform = CGAffineTransformMakeRotation([Math degreesToRadians:rotation]);
    }
    
    return attributes;
}

// -- insertion and deletion

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:itemIndexPath];
    
    if ([self.insertedSet containsObject:@(itemIndexPath.item)]) {
        attributes.alpha = 0;
        attributes.transform = CGAffineTransformMakeScale(0, 0);
        attributes.center = self.centerPoint;
        return attributes;
    }
    return nil;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:itemIndexPath];
    
    if ([self.deletedSet containsObject:@(itemIndexPath.item)]) {
        
        attributes.alpha = 0;
        attributes.transform = CGAffineTransformMakeScale(0, 0);
        attributes.center = self.centerPoint;
        return attributes;
    }
    return nil;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *item, NSUInteger idx, BOOL *stop) {
        if (item.updateAction == UICollectionUpdateActionInsert) {
            [self.insertedSet addObject:@(item.indexPathAfterUpdate.item)];
        }
        else if (item.updateAction == UICollectionUpdateActionDelete) {
            [self.deletedSet addObject:@(item.indexPathBeforeUpdate.item)];
        }
    }];
}

- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];
    [self.insertedSet removeAllObjects];
    [self.deletedSet removeAllObjects];
}

@end
