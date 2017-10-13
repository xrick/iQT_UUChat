//
//  UUMessageTemplateView.h
//  IQAgent
//
//  Created by IanFan on 2016/12/8.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UUMessageTemplateCell.h"

@protocol UUMessageTemplateViewDelegate;

@interface UUMessageTemplateView : UIView
@property (nonatomic, assign) id<UUMessageTemplateViewDelegate> delegate;
- (void)updateWithContentItem:(ContentItem *)item;
@end

@protocol UUMessageTemplateViewDelegate <NSObject>
- (void)UUMessageTemplateViewDelegateButtonTapped:(UUTemplateButton *)button;
@end
