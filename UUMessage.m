//
//  UUMessage.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessage.h"
#import "NSDate+Utils.h"

@implementation UUMessage

- (void)setWithDict:(NSDictionary *)dict {
    
    self.strIcon = dict[UUMESSAGE_KEY_ICON];
    self.strName = dict[UUMESSAGE_KEY_NAME];
    self.strId = dict[UUMESSAGE_KEY_ID];
    self.strTime = [self changeTheDateString:dict[UUMESSAGE_KEY_TIME]];
    self.from = [dict[UUMESSAGE_KEY_FROM] intValue];
    
    NSInteger type = [dict[UUMESSAGE_KEY_TYPE] integerValue];
    switch (type) {
        case 0:
            self.type = UUMessageTypeText;
            self.strContent = dict[UUMESSAGE_KEY_CONTNET];
            break;
        
        case 1:
            self.type = UUMessageTypeImage;
            self.picture = dict[UUMESSAGE_KEY_PICTURE];
            break;
        
        case 2:
            self.type = UUMessageTypeAudio;
            self.voice = dict[UUMESSAGE_KEY_VOICE];
            self.strVoiceTime = dict[UUMESSAGE_KEY_VOICE_TIME];
            break;
            
        default:
            NSLog(@"error UUMessage setWithDict UUMESSAGE_KEY_TYPE: %d",(int)type);
            break;
    }
}

//"08-10 晚上08:09:41.0" ->
//"昨天 上午10:09"或者"2012-08-10 凌晨07:09"
- (NSString *)changeTheDateString:(NSString *)Str {
    NSString *subString = [Str substringWithRange:NSMakeRange(0, 19)];
    NSDate *lastDate = [NSDate dateFromString:subString withFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSTimeZone *zone = [NSTimeZone systemTimeZone];
	NSInteger interval = [zone secondsFromGMTForDate:lastDate];
	lastDate = [lastDate dateByAddingTimeInterval:interval];
    
    NSString *dateStr;  //年月日
    NSString *period;   //时间段
    NSString *hour;     //时
    
    if ([lastDate year]==[[NSDate date] year]) {
        NSInteger days = [NSDate daysOffsetBetweenStartDate:lastDate endDate:[NSDate date]];
        if (days <= 2) {
            dateStr = [lastDate stringYearMonthDayCompareToday];
        }else{
            dateStr = [lastDate stringMonthDay];
        }
    }else{
        dateStr = [lastDate stringYearMonthDay];
    }
    
    if ([lastDate hour]>=5 && [lastDate hour]<12) {
        period = @"AM";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    }else if ([lastDate hour]>=12 && [lastDate hour]<=18){
        period = @"PM";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
    }else if ([lastDate hour]>18 && [lastDate hour]<=23){
        period = @"Night";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]-12];
    }else{
        period = @"Dawn";
        hour = [NSString stringWithFormat:@"%02d",(int)[lastDate hour]];
    }
    return [NSString stringWithFormat:@"%@ %@ %@:%02d",dateStr,period,hour,(int)[lastDate minute]];
}

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end {
    if (!start) {
        self.showDateLabel = YES;
        return;
    }
    
    NSString *subStart = [start substringWithRange:NSMakeRange(0, 19)];
    NSDate *startDate = [NSDate dateFromString:subStart withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *subEnd = [end substringWithRange:NSMakeRange(0, 19)];
    NSDate *endDate = [NSDate dateFromString:subEnd withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //这个是相隔的秒数
    NSTimeInterval timeInterval = [startDate timeIntervalSinceDate:endDate];
    
    //相距5分钟显示时间Label
    if (fabs (timeInterval) > 5*60) {
        self.showDateLabel = YES;
    }else{
        self.showDateLabel = NO;
    }
    
}

@end