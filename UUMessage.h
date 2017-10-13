//
//  UUMessage.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UUMESSAGE_KEY_ICON @"strIcon"
#define UUMESSAGE_KEY_ID @"strID"
#define UUMESSAGE_KEY_TIME @"strTime"
#define UUMESSAGE_KEY_NAME @"strName"
#define UUMESSAGE_KEY_CONTNET @"strContent"
#define UUMESSAGE_KEY_PICTURE @"picture"
#define UUMESSAGE_KEY_VOICE @"voice"
#define UUMESSAGE_KEY_VOICE_TIME @"strVoiceTime"
#define UUMESSAGE_KEY_FROM @"from"
#define UUMESSAGE_KEY_TYPE @"type"

typedef NS_ENUM(NSInteger, MessageType) {
    UUMessageTypeText                       =  0, //文字
    UUMessageTypeAudio                      =  1, //語音
    UUMessageTypeImage                      =  2, //圖片
};

typedef NS_ENUM(NSInteger, MessageFrom) {
    UUMessageFromMe    = 0,   // 自己发的
    UUMessageFromOther = 1    // 别人发的
};


@interface UUMessage : NSObject

@property (nonatomic, copy) NSString *strIcon;
@property (nonatomic, copy) NSString *strId;
@property (nonatomic, copy) NSString *strTime;
@property (nonatomic, copy) NSString *strName;

@property (nonatomic, copy) NSString *strContent;
@property (nonatomic, copy) UIImage  *picture;
@property (nonatomic, copy) NSData   *voice;
@property (nonatomic, copy) NSString *strVoiceTime;

@property (nonatomic, assign) MessageType type;
@property (nonatomic, assign) MessageFrom from;

@property (nonatomic, assign) BOOL showDateLabel;

- (void)setWithDict:(NSDictionary *)dict;

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end;

@end
