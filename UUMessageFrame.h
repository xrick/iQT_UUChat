//
//  UUMessageFrame.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#define ChatMargin 10       //间隔
#define ChatIconWH 44       //头像宽高height、width
#define ChatPicWH 240       //图片宽高200
#define ChatContentW 240    //内容宽度180

#define ChatTimeMarginW 15  //时间文本与边框间隔宽度方向
#define ChatTimeMarginH 10  //时间文本与边框间隔高度方向

#define ChatContentTop 15   //文本内容与按钮上边缘间隔
#define ChatContentLeft 25  //文本内容与按钮左边缘间隔
#define ChatContentBottom 15 //文本内容与按钮下边缘间隔
#define ChatContentRight 15 //文本内容与按钮右边缘间隔

#define ChatTimeFont [UIFont systemFontOfSize:12]
#define ChatNameFont [UIFont systemFontOfSize:14]
#define ChatContentFont [UIFont systemFontOfSize:24]

#define ChatTemplateLeftMargin  10
#define ChatTemplateSpacing      4
#define ChatTemplateImage      184
#define ChatTemplateTitle       22
#define ChatTemplateSubTitle    18
#define ChatTemplateButton      40
#define ChatTemplateElementW   280

#define ChatTemplateTitleFont [UIFont boldSystemFontOfSize:20]
#define ChatTemplateSubtitleFont [UIFont systemFontOfSize:16]
#define ChatTemplateButtonFont [UIFont systemFontOfSize:20]

#import <Foundation/Foundation.h>
@class UUMessage;

@interface UUMessageFrame : NSObject

@property (nonatomic, assign, readonly) CGRect nameF;
@property (nonatomic, assign, readonly) CGRect iconF;
@property (nonatomic, assign, readonly) CGRect timeF;
@property (nonatomic, assign, readonly) CGRect contentF;

@property (nonatomic, assign, readonly) CGFloat cellHeight;
@property (nonatomic, assign) BOOL showTime;
//@property (nonatomic, strong) UUMessage *message;
@property (nonatomic, strong) ContentItem *contentItem;

@end
