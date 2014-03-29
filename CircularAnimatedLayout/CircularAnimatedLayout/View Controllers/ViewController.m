//
//  ViewController.m
//  CircularAnimatedLayout
//
//  Created by Cillian on 29/03/2014.
//  Copyright (c) 2014 Cillian. All rights reserved.
//

#import "CHCircularCollectionLayout.h"
#import "ViewController.h"
#import "CollectionViewCell.h"
#import "Math.h"

static NSString *kCellIdentifier = @"UICollectionViewCell";

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UIButton *button;

@end

@implementation ViewController {
    NSArray *collectionData;
    NSArray *images;
    BOOL menuOpen;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    
    collectionData = @[@[]];
    images = @[@"box-75",@"chat-75",@"closed_topic-75",@"delete_message-75",@"moved_topic-75",@"online-75",];
    menuOpen = NO;
    
    CHCircularCollectionLayout *layout = [CHCircularCollectionLayout new];
    layout.centerPoint = CGPointMake(self.collectionView.frame.size.width/2, self.collectionView.frame.size.height/2);
    layout.cellStyle = CellStyleFixed;
    layout.sectionStyle = SectionStyleSingleRing;
    [self.collectionView setCollectionViewLayout:layout];
}

- (IBAction)button:(id)sender {
    if (!menuOpen) {
        [self insertItems];
        [self.button setTitle:@"-" forState:UIControlStateNormal];
    }
    else {
        [self withdrawItems];
        [self.button setTitle:@"+" forState:UIControlStateNormal];
    }
    menuOpen = !menuOpen;
}

- (void)insertItems {
    
    [self.collectionView performBatchUpdates:^{
        collectionData = @[@[@"meow",@"meow",@"meow",@"meow",@"meow",@"meow"]];
        NSInteger countFrom = 0;
        NSMutableArray *mutableArray = [NSMutableArray array];
        while (countFrom < [[collectionData objectAtIndex:0] count]) {
            [mutableArray addObject:[NSIndexPath indexPathForItem:countFrom inSection:0]];
            countFrom++;
        }
        [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithArray:mutableArray]];
    } completion:^(BOOL finished) {
        
        [[collectionData objectAtIndex:0] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CollectionViewCell *cell = (CollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            
            [UIView animateWithDuration:0.2 animations:^{
                cell.transform = CGAffineTransformMakeScale(1.1, 1.1);
            } completion:^(BOOL finished) {
                cell.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

- (void)withdrawItems {
    
    [self.collectionView performBatchUpdates:^{
        
        NSInteger countFrom = 0;
        NSMutableArray *mutableArray = [NSMutableArray array];
        while (countFrom < [[collectionData objectAtIndex:0] count]) {
            [mutableArray addObject:[NSIndexPath indexPathForItem:countFrom inSection:0]];
            countFrom++;
        }
        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithArray:mutableArray]];
        collectionData = @[@[]];
    } completion:nil];
}

#pragma mark - UICollectionView

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self highlightView:cell];
}

- (void)highlightView:(UIView *)view {
    view.backgroundColor = [UIColor whiteColor];
    [UIView animateWithDuration:0.5 animations:^{
        view.backgroundColor = [UIColor clearColor];
    }];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.image.image = [UIImage imageNamed:[images objectAtIndex:indexPath.row]];
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = cell.frame.size.height/2;
    cell.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.layer.borderWidth = 1.0f;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[collectionData objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return collectionData.count;
}

@end
