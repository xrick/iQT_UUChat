//
//  UUMessageCell.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUMessageCell.h"
#import "UUMessage.h"
#import "UUMessageFrame.h"
#import "UUAVAudioPlayer.h"
//#import "UIImageView+AFNetworking.h"
//#import "UIButton+AFNetworking.h"
#import "UUImageAvatarBrowser.h"

@interface UUMessageCell ()<UUAVAudioPlayerDelegate, UUMessageTemplateViewDelegate>
{
    AVAudioPlayer *player;
    NSString *voiceURL;
    NSData *songData;
    
    UUAVAudioPlayer *audio;
    
    UIView *headImageBackView;
    BOOL contentVoiceIsPlaying;
}
@end

@implementation UUMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        // 1、创建时间
        self.labelTime = [[UILabel alloc] init];
        self.labelTime.textAlignment = NSTextAlignmentCenter;
        self.labelTime.textColor = [UIColor grayColor];
        self.labelTime.font = ChatTimeFont;
        [self.contentView addSubview:self.labelTime];
        
        // 2、创建头像
        headImageBackView = [[UIView alloc]init];
        headImageBackView.layer.cornerRadius = 22;
        headImageBackView.layer.masksToBounds = YES;
        headImageBackView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
        [self.contentView addSubview:headImageBackView];
        self.btnHeadImage = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnHeadImage.layer.cornerRadius = 20;
        self.btnHeadImage.layer.masksToBounds = YES;
        [self.btnHeadImage addTarget:self action:@selector(btnHeadImageClick:)  forControlEvents:UIControlEventTouchUpInside];
        [headImageBackView addSubview:self.btnHeadImage];
        
        // 3、创建头像下标
        self.labelNum = [[UILabel alloc] init];
        self.labelNum.textColor = [UIColor grayColor];
        self.labelNum.textAlignment = NSTextAlignmentCenter;
        self.labelNum.font = ChatNameFont;
        [self.contentView addSubview:self.labelNum];
        
        // 4、创建内容
        self.btnContent = [UUMessageContentButton buttonWithType:UIButtonTypeCustom];
        [self.btnContent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.btnContent.titleLabel.font = ChatContentFont;
        self.btnContent.titleLabel.numberOfLines = 0;
        [self.btnContent addTarget:self action:@selector(btnContentClick)  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnContent];
        
        self.templateView = [[UUMessageTemplateView alloc] init];
        self.templateView.delegate = self;
        [self.contentView addSubview:self.templateView];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(UUAVAudioPlayerDidFinishPlay) name:@"VoicePlayHasInterrupt" object:nil];
        
        //红外线感应监听
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sensorStateChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
        contentVoiceIsPlaying = NO;

    }
    return self;
}

//头像点击
//- (void)btnHeadImageClick:(UIButton *)button{
//    if ([self.delegate respondsToSelector:@selector(headImageDidClick:userId:)])  {
//        [self.delegate headImageDidClick:self userId:self.messageFrame.message.strId];
//    }
//}
- (void)btnHeadImageClick:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(headImageDidClick:userId:)])  {
        [self.delegate headImageDidClick:self userId:self.messageFrame.contentItem.recipient.userID];
    }
}

- (void)btnContentClick{
    //play audio
    if (self.messageFrame.contentItem.message.attachment.type == Message_Type_Audio) {
        if(!contentVoiceIsPlaying){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
            contentVoiceIsPlaying = YES;
            audio = [UUAVAudioPlayer sharedInstance];
            audio.delegate = self;
            //        [audio playSongWithUrl:voiceURL];
            [audio playSongWithData:songData];
        }else{
            [self UUAVAudioPlayerDidFinishPlay];
        }
    }
    //show the picture
    else if (self.messageFrame.contentItem.message.attachment.type == Message_Type_Image)
    {
        if (self.btnContent.backImageView) {
            [UUImageAvatarBrowser showImage:self.btnContent.backImageView];
        }
        if ([self.delegate isKindOfClass:[UIViewController class]]) {
            [[(UIViewController *)self.delegate view] endEditing:YES];
        }
    }
    // show text and gonna copy that
    else if (self.messageFrame.contentItem.message.attachment.type == Message_Type_Text)
    {
        [self.btnContent becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:self.btnContent.frame inView:self.btnContent.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}
/*
- (void)btnContentClick{
    //play audio
    if (self.messageFrame.message.type == UUMessageTypeAudio) {
        if(!contentVoiceIsPlaying){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VoicePlayHasInterrupt" object:nil];
            contentVoiceIsPlaying = YES;
            audio = [UUAVAudioPlayer sharedInstance];
            audio.delegate = self;
            //        [audio playSongWithUrl:voiceURL];
            [audio playSongWithData:songData];
        }else{
            [self UUAVAudioPlayerDidFinishPlay];
        }
    }
    //show the picture
    else if (self.messageFrame.message.type == UUMessageTypeImage)
    {
        if (self.btnContent.backImageView) {
            [UUImageAvatarBrowser showImage:self.btnContent.backImageView];
        }
        if ([self.delegate isKindOfClass:[UIViewController class]]) {
            [[(UIViewController *)self.delegate view] endEditing:YES];
        }
    }
    // show text and gonna copy that
    else if (self.messageFrame.message.type == UUMessageTypeText)
    {
        [self.btnContent becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:self.btnContent.frame inView:self.btnContent.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}
 */

- (void)UUAVAudioPlayerBeiginLoadVoice
{
    [self.btnContent benginLoadVoice];
}
- (void)UUAVAudioPlayerBeiginPlay
{
    //开启红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    [self.btnContent didLoadVoice];
}
- (void)UUAVAudioPlayerDidFinishPlay
{
    //关闭红外线感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    contentVoiceIsPlaying = NO;
    [self.btnContent stopPlay];
    [[UUAVAudioPlayer sharedInstance]stopSound];
}


//内容及Frame设置
- (void)setMessageFrame:(UUMessageFrame *)messageFrame{
    
    NSLog(@"設置Frame");
    _messageFrame = messageFrame;
//    UUMessage *message = messageFrame.message;
    
    ContentItem *item = messageFrame.contentItem;
    
    // 1、设置时间
    self.labelTime.text = item.recipient.sendTime;
    self.labelTime.frame = messageFrame.timeF;
    
    // 2、设置头像
    headImageBackView.frame = messageFrame.iconF;
    self.btnHeadImage.frame = CGRectMake(2, 2, ChatIconWH-4, ChatIconWH-4);
    [self.btnHeadImage setImage:[UIImage imageNamed:item.recipient.userIcon] forState:UIControlStateNormal];
    if (item.recipient.from == Message_From_Other) {
        headImageBackView.hidden = NO;
    }
    else {
        headImageBackView.hidden = YES;
    }
    //    [self.btnHeadImage setBackgroundImageForState:UIControlStateNormal
    //                                          withURL:[NSURL URLWithString:message.strIcon]
    //                                 placeholderImage:[UIImage imageNamed:@"headImage.jpeg"]];
    
    // 3、设置下标
    self.labelNum.text = item.recipient.userName;
    if (messageFrame.nameF.origin.x > 160) {
        self.labelNum.hidden = YES;
        self.labelNum.frame = CGRectMake(messageFrame.nameF.origin.x - 50, messageFrame.nameF.origin.y + 3, 100, messageFrame.nameF.size.height);
        self.labelNum.textAlignment = NSTextAlignmentRight;
    }else{
        self.labelNum.hidden = NO;
        self.labelNum.frame = CGRectMake(messageFrame.nameF.origin.x, messageFrame.nameF.origin.y + 3, 80, messageFrame.nameF.size.height);
        self.labelNum.textAlignment = NSTextAlignmentLeft;
    }
    
    // 4、设置内容
    
    //prepare for reuse
    [self.btnContent setTitle:@"" forState:UIControlStateNormal];
    self.btnContent.voiceBackView.hidden = YES;
    self.btnContent.backImageView.hidden = YES;
    
    self.btnContent.frame = messageFrame.contentF;
    
    self.templateView.frame = messageFrame.contentF;
    
    if (item.recipient.from == Message_From_Me) {
        self.btnContent.isMyMessage = YES;
        [self.btnContent setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentRight, ChatContentBottom, ChatContentLeft);
    }else{
        self.btnContent.isMyMessage = NO;
        [self.btnContent setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentLeft, ChatContentBottom, ChatContentRight);
    }
    
    //背景气泡图
    switch (item.message.attachment.type) {
        case Message_Type_Text:
        case Message_Type_Audio:
        case Message_Type_Image:
        case Message_Type_Video:
        case Message_Type_File:
        {
            UIImage *normal;
            if (item.recipient.from == Message_From_Me) {
                normal = [UIImage imageNamed:@"chatto_bg_normal"];
                normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
            }
            else{
                normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
                normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
            }
            [self.btnContent setBackgroundImage:normal forState:UIControlStateNormal];
            [self.btnContent setBackgroundImage:normal forState:UIControlStateHighlighted];
        }
            break;
        default:
            break;
    }
    
    self.btnContent.hidden = NO;
    self.templateView.hidden = YES;
    switch (item.message.attachment.type) {
        case Message_Type_Text:
            [self.btnContent setTitle:item.message.text forState:UIControlStateNormal];
            break;
            
        case Message_Type_Audio:
        {
            self.btnContent.voiceBackView.hidden = NO;
            self.btnContent.second.text = [NSString stringWithFormat:@"%@'s Voice",item.message.attachment.payload.voiceTime];
            songData = item.message.attachment.payload.data;
            //            voiceURL = [NSString stringWithFormat:@"%@%@",RESOURCE_URL_HOST,message.strVoice];
        }
            break;
            
        case Message_Type_Image:
        {
            self.btnContent.backImageView.hidden = NO;
            self.btnContent.backImageView.image = item.message.attachment.payload.image;
            self.btnContent.backImageView.frame = CGRectMake(0, 0, self.btnContent.frame.size.width, self.btnContent.frame.size.height);
            [self makeMaskView:self.btnContent.backImageView withImage:normal];
        }
            break;
        
        case Message_Type_Template:
        {
            NSLog(@"左右滑動。");
            self.btnContent.hidden = YES;
            self.templateView.hidden = NO;
            [self.templateView updateWithContentItem:item];
        }
            break;
            
        default:
            break;
    }
}
/*
- (void)setMessageFrame:(UUMessageFrame *)messageFrame{

    _messageFrame = messageFrame;
    UUMessage *message = messageFrame.message;
    
    // 1、设置时间
    self.labelTime.text = message.strTime;
    self.labelTime.frame = messageFrame.timeF;
    
    // 2、设置头像
    headImageBackView.frame = messageFrame.iconF;
    self.btnHeadImage.frame = CGRectMake(2, 2, ChatIconWH-4, ChatIconWH-4);
    
    if (message.from == UUMessageFromOther) {
        headImageBackView.hidden = NO;
        [self.btnHeadImage setImage:[UIImage imageNamed:@"chat_headImage_other.png"] forState:UIControlStateNormal];
    }
    else {
        headImageBackView.hidden = YES;
        [self.btnHeadImage setImage:[UIImage imageNamed:@"chat_headImage_me.png"] forState:UIControlStateNormal];
    }
//    [self.btnHeadImage setBackgroundImageForState:UIControlStateNormal
//                                          withURL:[NSURL URLWithString:message.strIcon]
//                                 placeholderImage:[UIImage imageNamed:@"headImage.jpeg"]];
    
    // 3、设置下标
    self.labelNum.text = message.strName;
    if (messageFrame.nameF.origin.x > 160) {
        self.labelNum.hidden = YES;
        self.labelNum.frame = CGRectMake(messageFrame.nameF.origin.x - 50, messageFrame.nameF.origin.y + 3, 100, messageFrame.nameF.size.height);
        self.labelNum.textAlignment = NSTextAlignmentRight;
    }else{
        self.labelNum.hidden = NO;
        self.labelNum.frame = CGRectMake(messageFrame.nameF.origin.x, messageFrame.nameF.origin.y + 3, 80, messageFrame.nameF.size.height);
        self.labelNum.textAlignment = NSTextAlignmentLeft;
    }

    // 4、设置内容
    
    //prepare for reuse
    [self.btnContent setTitle:@"" forState:UIControlStateNormal];
    self.btnContent.voiceBackView.hidden = YES;
    self.btnContent.backImageView.hidden = YES;

    self.btnContent.frame = messageFrame.contentF;
    
    if (message.from == UUMessageFromMe) {
        self.btnContent.isMyMessage = YES;
        [self.btnContent setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentRight, ChatContentBottom, ChatContentLeft);
    }else{
        self.btnContent.isMyMessage = NO;
        [self.btnContent setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentLeft, ChatContentBottom, ChatContentRight);
    }
    
    //背景气泡图
    UIImage *normal;
    if (message.from == UUMessageFromMe) {
        normal = [UIImage imageNamed:@"chatto_bg_normal"];
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
    }
    else{
        normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
    }
    [self.btnContent setBackgroundImage:normal forState:UIControlStateNormal];
    [self.btnContent setBackgroundImage:normal forState:UIControlStateHighlighted];

    switch (message.type) {
        case UUMessageTypeText:
            [self.btnContent setTitle:message.strContent forState:UIControlStateNormal];
            break;
        case UUMessageTypeImage:
        {
            self.btnContent.backImageView.hidden = NO;
            self.btnContent.backImageView.image = message.picture;
            self.btnContent.backImageView.frame = CGRectMake(0, 0, self.btnContent.frame.size.width, self.btnContent.frame.size.height);
            [self makeMaskView:self.btnContent.backImageView withImage:normal];
        }
            break;
        case UUMessageTypeAudio:
        {
            self.btnContent.voiceBackView.hidden = NO;
            self.btnContent.second.text = [NSString stringWithFormat:@"%@'s Voice",message.strVoiceTime];
            songData = message.voice;
//            voiceURL = [NSString stringWithFormat:@"%@%@",RESOURCE_URL_HOST,message.strVoice];
        }
            break;
            
        default:
            break;
    }
}
*/

- (void)makeMaskView:(UIView *)view withImage:(UIImage *)image
{
    UIImageView *imageViewMask = [[UIImageView alloc] initWithImage:image];
    imageViewMask.frame = CGRectInset(view.frame, 0.0f, 0.0f);
    view.layer.mask = imageViewMask.layer;
}

//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    if ([[UIDevice currentDevice] proximityState] == YES){
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else{
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

#pragma mark - UUMessageTemplateViewDelegate

- (void)UUMessageTemplateViewDelegateButtonTapped:(UUTemplateButton *)button {
    if ([self.delegate respondsToSelector:@selector(cellTemplateButtonTapped:)]) {
        [self.delegate cellTemplateButtonTapped:button];
    }
}

@end



