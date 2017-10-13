//
//  UUMessageTemplateView.m
//  IQAgent
//
//  Created by IanFan on 2016/12/8.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "UUMessageTemplateView.h"
#include "UUMessageFrame.h"

#define CELL_IDENTIFIER @"Cell"

@interface UUMessageTemplateView () <UICollectionViewDelegate, UICollectionViewDataSource, UUMessageTemplateCellDelegate>
{
    UICollectionView *_collectionView;
    ContentItem *_item;
}
@end

@implementation UUMessageTemplateView


- (void)dealloc {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    _collectionView = nil;
}

- (void)updateWithContentItem:(ContentItem *)item {
    _item = item;
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    _collectionView = nil;
    [self getCollectionView];
    
    //collectionView horizontal
    
    //item to content
    
    //button delegate
    
    switch (item.message.attachment.payload.template_type) {
        case Template_Type_Button:
        {
            ChatTemplateImage;
        }
            break;
            
        case Template_Type_Generic:
        {
            
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - CollectionView

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _item.message.attachment.payload.elements.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UUMessageTemplateCell *cell = (UUMessageTemplateCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    cell.delegate = self;
    
    Element *element = [_item.message.attachment.payload.elements objectAtIndex:indexPath.row];
    
    [cell updateWithElement:element];
    
    return cell;
}

#pragma mark CHTCollectionViewDelegateWaterfallLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(ChatTemplateElementW + ChatTemplateLeftMargin*2, self.frame.size.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat spacing = 0;
    return spacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumColumnSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat spacing = 0;
    return spacing;
}

#pragma mark CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
}

#pragma mark - UUMessageTemplateCellDelegate

- (void)UUMessageTemplateCellDelegateButtonTapped:(UUTemplateButton *)button {
    if ([self.delegate respondsToSelector:@selector(UUMessageTemplateViewDelegateButtonTapped:)]) {
        [self.delegate UUMessageTemplateViewDelegateButtonTapped:button];
    }
}

#pragma mark - Factory

- (UICollectionView *)getCollectionView {
    //上下滑動的collectionView
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        collectionView.dataSource = self;
        collectionView.delegate = self;
//        collectionView.pagingEnabled = YES;
        collectionView.backgroundColor = [UIColor clearColor];
        [collectionView registerClass:[UUMessageTemplateCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
        
        [self addSubview:collectionView];
        _collectionView = collectionView;
    }
    return _collectionView;
}

@end
