//
//  CHCircularCollectionLayout.h
//  RotatingCollectionView
//
//  Created by Cillian on 22/03/2014.
//  Copyright (c) 2014 Cillian. All rights reserved.
//

#import <UIKit/UIKit.h>

enum CellStyle{
    CellStyleRotateToCenter,
    CellStyleFixed
};

enum SectionStyle{
    SectionStyleMultipleRings,
    SectionStyleSingleRing
};

@interface CHCircularCollectionLayout : UICollectionViewLayout

@property (nonatomic, assign) enum CellStyle cellStyle;
@property (nonatomic, assign) enum SectionStyle sectionStyle;

@property (assign, nonatomic) CGPoint centerPoint;

@end
