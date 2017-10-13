//
//  UUInputFunctionView.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INPUTFUNCTIONVIEW_SPEAK_HEIGHT (140 + INPUTFUNCTIONVIEW_TEXTBAR_HEIGHT)

#define INPUTFUNCTIONVIEW_TEXTBAR_HEIGHT 40

typedef NS_ENUM(NSInteger, UUInputFunctionView_Type) {
    UUInputFunctionView_Type_Keyboard     = 0,
    UUInputFunctionView_Type_Speak           ,
};

@class UUInputFunctionView;

@protocol UUInputFunctionViewDelegate <NSObject>

// text
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendMessage:(NSString *)message;

// image
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendPicture:(UIImage *)image;

// audio
- (void)UUInputFunctionView:(UUInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second;

- (void)UUInputFunctionViewVoiceSpeakButtonTapped;
- (void)UUInputFunctionViewVoiceSpeakButtonBegin;
- (void)UUInputFunctionViewVoiceSpeakButtonEnd;
- (void)UUInputFunctionViewVoiceSpeakButtonCancel;

- (void)UUInputFunctionViewVoiceUpdateToType:(UUInputFunctionView_Type)type;

@end

@interface UUInputFunctionView : UIView <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, assign) UIViewController *superVC;
@property (nonatomic, assign) id<UUInputFunctionViewDelegate>delegate;

@property (nonatomic, retain) UIButton *btnPicture;
@property (nonatomic, retain) UIButton *btnChangeVoiceState;
@property (nonatomic, retain) UIButton *btnVoiceRecord;
@property (nonatomic, retain) UITextView *textViewInput;

@property (nonatomic, assign) UUInputFunctionView_Type type;
@property (nonatomic, assign) BOOL isAbleToSendTextMessage;


- (id)initWithSuperVC:(UIViewController *)superVC;

- (void)updateSpeakButtonControlEventBySetting;

- (void)changeSendBtnIsExistText:(BOOL)isExistText;

- (void)endRecordVoiceWithDelegate:(BOOL)isDelegate;

- (void)btnChangeStateTapped:(id)sender;

@end
