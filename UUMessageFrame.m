//
//  UUMessageFrame.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessageFrame.h"
#import "UUMessage.h"

@implementation UUMessageFrame

/*
- (void)setMessage:(UUMessage *)message{
    
    _message = message;
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    
    // 1、计算时间的位置
    if (_showTime){
        CGFloat timeY = ChatMargin;
        
        CGSize timeSize = [_message.strTime boundingRectWithSize:CGSizeMake(300, 100)
                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                      attributes:@{NSFontAttributeName:ChatTimeFont}
                                                         context:nil].size;
        
//        CGSize timesZie = [_message.strTime boundingRectWithSize:<#(CGSize)#> options:<#(NSStringDrawingOptions)#> attributes:<#(nullable NSDictionary<NSString *,id> *)#> context:<#(nullable NSStringDrawingContext *)#>];

        CGFloat timeX = (screenW - timeSize.width) / 2;
        _timeF = CGRectMake(timeX, timeY, timeSize.width + ChatTimeMarginW, timeSize.height + ChatTimeMarginH);
    }
    
    
    // 2、计算头像位置
    CGFloat iconX = ChatMargin;
    if (_message.from == UUMessageFromMe) {
//        iconX = screenW - ChatMargin - ChatIconWH;
        iconX = screenW;
    }
    CGFloat iconY = CGRectGetMaxY(_timeF) + ChatMargin;
    _iconF = CGRectMake(iconX, iconY, ChatIconWH, ChatIconWH);
    
    // 3、计算ID位置
    _nameF = CGRectMake(iconX, iconY+ChatIconWH, ChatIconWH, 20);
    
    // 4、计算内容位置
    CGFloat contentX = CGRectGetMaxX(_iconF)+ChatMargin;
    CGFloat contentY = iconY;
   
    //根据种类分
    CGSize contentSize;
    switch (_message.type) {
        case UUMessageTypeText:
//            contentSize = [_message.strContent sizeWithFont:ChatContentFont  constrainedToSize:CGSizeMake(ChatContentW, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            
            contentSize = [_message.strContent boundingRectWithSize:CGSizeMake(ChatContentW, CGFLOAT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:ChatContentFont}
                                                             context:nil].size;
            
            break;
        case UUMessageTypeImage:
            contentSize = CGSizeMake(ChatPicWH, ChatPicWH);
            break;
        case UUMessageTypeAudio:
            contentSize = CGSizeMake(120, 20);
            break;
        default:
            break;
    }
    if (_message.from == UUMessageFromMe) {
        contentX = iconX - contentSize.width - ChatContentLeft - ChatContentRight - ChatMargin;
    }
    _contentF = CGRectMake(contentX, contentY, contentSize.width + ChatContentLeft + ChatContentRight, contentSize.height + ChatContentTop + ChatContentBottom);
    
    _cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_nameF))  + ChatMargin;
    
}
 */

- (void)setContentItem:(ContentItem *)item {
    _contentItem = item;
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    
    // 1、计算时间的位置
    if (_showTime){
        CGFloat timeY = ChatMargin;
        
        CGSize timeSize = [_contentItem.recipient.sendTime boundingRectWithSize:CGSizeMake(300, 100)
                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                     attributes:@{NSFontAttributeName:ChatTimeFont}
                                                                        context:nil].size;
        
        //        CGSize timesZie = [_message.strTime boundingRectWithSize:<#(CGSize)#> options:<#(NSStringDrawingOptions)#> attributes:<#(nullable NSDictionary<NSString *,id> *)#> context:<#(nullable NSStringDrawingContext *)#>];
        
        CGFloat timeX = (screenW - timeSize.width) / 2;
        _timeF = CGRectMake(timeX, timeY, timeSize.width + ChatTimeMarginW, timeSize.height + ChatTimeMarginH);
    }
    
    
    // 2、计算头像位置
    CGFloat iconX = ChatMargin;
    if (_contentItem.recipient.from == Message_From_Me) {
        //        iconX = screenW - ChatMargin - ChatIconWH;
        iconX = screenW;
    }
    CGFloat iconY = CGRectGetMaxY(_timeF) + ChatMargin;
    _iconF = CGRectMake(iconX, iconY, ChatIconWH, ChatIconWH);
    
    // 3、计算ID位置
    _nameF = CGRectMake(iconX, iconY+ChatIconWH, ChatIconWH, 20);
    
    // 4、计算内容位置
    CGFloat contentX = CGRectGetMaxX(_iconF)+ChatMargin;
    CGFloat contentY = iconY;
    
    //根据种类分
    CGSize contentSize;
    switch (_contentItem.message.attachment.type) {
        case Message_Type_Text:
            //            contentSize = [_message.strContent sizeWithFont:ChatContentFont  constrainedToSize:CGSizeMake(ChatContentW, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            
            contentSize = [_contentItem.message.text boundingRectWithSize:CGSizeMake(ChatContentW, CGFLOAT_MAX)
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                               attributes:@{NSFontAttributeName:ChatContentFont}
                                                                  context:nil].size;
            break;
            
        case Message_Type_Audio:
            contentSize = CGSizeMake(120, 20);
            break;
            
        case Message_Type_Image:
            contentSize = CGSizeMake(ChatPicWH, ChatPicWH);
            break;
            
        case Message_Type_Template:
        {
            switch (_contentItem.message.attachment.payload.template_type) {
                case Template_Type_Button:
                case Template_Type_Generic:
                {
                    Element *element = [_contentItem.message.attachment.payload.elements firstObject];
                    CGFloat imageHeight = (element.image_url.length > 0)? ChatTemplateImage + ChatTemplateSpacing: 0;
//                    CGFloat titleHeight = (element.title.length > 0)? ChatTemplateTitle : 0;
                    
                    CGSize titleSize = [element.title boundingRectWithSize:CGSizeMake(ChatContentW, CGFLOAT_MAX)
                                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                                attributes:@{NSFontAttributeName:ChatTemplateTitleFont}
                                                                   context:nil].size;
                    CGFloat titleHeight = (element.title.length > 0)? titleSize.height + ChatTemplateSpacing : 0;
                    
                    CGFloat subtitleHeight = (element.subtitle.length > 0)? ChatTemplateSubTitle + ChatTemplateSpacing : 0;
                    NSUInteger maxButtonsCount = 0;
                    for (Element *e in _contentItem.message.attachment.payload.elements) {
                        if (maxButtonsCount < e.buttons.count) {
                            maxButtonsCount = e.buttons.count;
                        }
                    }
                    CGFloat buttonTotalHeight = maxButtonsCount * ChatTemplateButton;
                    CGFloat height =  imageHeight + titleHeight + subtitleHeight + buttonTotalHeight;
                    
                    contentSize = CGSizeMake(screenW - contentX - ChatContentLeft - ChatContentRight, height);
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        
        default:
            break;
    }
    if (_contentItem.recipient.from == Message_From_Me) {
        contentX = iconX - contentSize.width - ChatContentLeft - ChatContentRight - ChatMargin;
    }
    _contentF = CGRectMake(contentX, contentY, contentSize.width + ChatContentLeft + ChatContentRight, contentSize.height + ChatContentTop + ChatContentBottom);
    
    _cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_nameF))  + ChatMargin;
}

@end
