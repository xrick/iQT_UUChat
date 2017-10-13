//
//  UUMessageTemplateCell.m
//  IQAgent
//
//  Created by IanFan on 2016/12/8.
//  Copyright © 2016年 IanFan. All rights reserved.
//

#import "UUMessageTemplateCell.h"
#include "UUMessageFrame.h"
#import "UIImageView+Networking.h"

@implementation UUTemplateButton

@end

@interface UUMessageTemplateCell()
{
    Element *_element;
}
@end


@implementation UUMessageTemplateCell

- (void)updateWithElement:(Element *)element {
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    self.contentView.layer.cornerRadius = 10;
    self.contentView.layer.borderWidth = 0.5;
    self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    _element = element;
    
    CGFloat imageHeight = (element.image_url.length > 0)? ChatTemplateImage : 0;
//    CGFloat titleHeight = (element.title.length > 0)? ChatTemplateTitle : 0;
    CGSize titleSize = [element.title boundingRectWithSize:CGSizeMake(ChatContentW, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:ChatTemplateTitleFont}
                                                   context:nil].size;
    CGFloat titleHeight = titleSize.height;
    CGFloat subtitleHeight = (element.subtitle.length > 0)? ChatTemplateSubTitle : 0;
    CGFloat buttonHeight = ChatTemplateButton;
    CGFloat width = self.frame.size.width - ChatTemplateLeftMargin*2;
    width = ChatTemplateElementW;
    CGFloat leftMargin = ChatTemplateLeftMargin;
    CGFloat spacing = ChatTemplateSpacing;
    
    //image
    if (element.image_url.length > 0) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(leftMargin, ChatContentTop, width, imageHeight);
        [imageView setImage:[UIImage imageNamed:@"chat_send_message"]];
        [imageView setImageURL:[NSURL URLWithString:element.image_url]];
        [self.contentView addSubview:imageView];
    }
    
    //title
    if (element.title.length > 0) {
        UILabel *label = [[UILabel alloc] init];
        label.font = ChatTemplateTitleFont;
        label.numberOfLines = ceilf(titleHeight/(float)ChatTemplateTitle);
        label.frame = CGRectMake(leftMargin, ChatContentTop + imageHeight + spacing, width, titleHeight);
        label.text = element.title;
        [self.contentView addSubview:label];
    }
    
    //subtitle
    if (element.title.length > 0) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor grayColor];
        label.font = ChatTemplateSubtitleFont;
        label.frame = CGRectMake(leftMargin, ChatContentTop + imageHeight + titleHeight + spacing*2, width, subtitleHeight);
        label.text = element.subtitle;
        [self.contentView addSubview:label];
    }
    
    //buttons
    if (element.buttons.count > 0) {
        CGFloat oringinY = ChatContentTop + imageHeight + titleHeight + subtitleHeight + spacing *3;
        
        for (int i=0; i<element.buttons.count; i++) {
            ButtonItem *buttonItem = [element.buttons objectAtIndex:i];
            
            UUTemplateButton *button = [UUTemplateButton buttonWithType:UIButtonTypeRoundedRect];
            button.titleLabel.font = ChatTemplateButtonFont;
            button.frame = CGRectMake(leftMargin, oringinY + i*buttonHeight, width, buttonHeight);
            button.type = buttonItem.type;
            button.url = buttonItem.url;
            button.title = buttonItem.title;
            button.attributedTitle = buttonItem.attributedTitle;
            button.payload = buttonItem.payload;
            
            if (buttonItem.attributedTitle.length > 0) {
                [button setAttributedTitle:button.attributedTitle forState:UIControlStateNormal];
            }
            else {
                button.titleLabel.textColor = [UIColor blueColor];
                [button setTitle:button.title forState:UIControlStateNormal];
            }
            
            [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:button];
        }
    }
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

#pragma mark - Command

- (void)buttonTapped:(UUTemplateButton *)button {
    if ([self.delegate respondsToSelector:@selector(UUMessageTemplateCellDelegateButtonTapped:)]) {
        [self.delegate UUMessageTemplateCellDelegateButtonTapped:button];
    }
}

@end
