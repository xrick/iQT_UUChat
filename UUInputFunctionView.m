//
//  UUInputFunctionView.m
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-27.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUInputFunctionView.h"
#import "Mp3Recorder.h"
#import "UUProgressHUD.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
//category
#import "UIImage+animatedGIF.h"

@interface UUInputFunctionView ()<UITextViewDelegate,Mp3RecorderDelegate> {
    BOOL _isRecording;
    
    Mp3Recorder *_mp3Recorder;
    NSInteger _recordTime;
    NSTimer *_recordTimer;
    
    UILabel *_placeHold;
    
    UIButton *_speakButton;
    UIImageView *_speakAnimationImageView;
    
    BOOL _isDragInside;
}
@end

@implementation UUInputFunctionView

#pragma mark - LifeCycle

- (id)initWithSuperVC:(UIViewController *)superVC {
    CGRect frame = CGRectMake(0, Main_Screen_Height-INPUTFUNCTIONVIEW_TEXTBAR_HEIGHT, Main_Screen_Width, INPUTFUNCTIONVIEW_TEXTBAR_HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        self.superVC = superVC;
        
        self.backgroundColor = [UIColor whiteColor];
        //分割线
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
        
        self.isAbleToSendTextMessage = NO;
        
        [self getMp3Recorder];
        
        //類似Siri說話按鈕，有speakAnimationImageView
        [self getSpeakButton];
        _speakButton.hidden = YES;
       
        //照片
        [self getBtnPicture];
        
        //改變狀態:語音、文字、送出
        [self getBtnChangeVoiceState];

        //類似Chat按下錄音按鍵
        [self getBtnVoiceRecord];//暫不使用
        _btnVoiceRecord.hidden = YES;
        
        //输入框，有placeHold
        [self getTextViewInput];
        
        //添加通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textViewDidEndEditing:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - Command

#pragma mark VoiceRecord 錄音開始、結束、取消

- (void)btnVoiceRecordTapped {
    if (!_isRecording) {
        [self beginRecordVoice];
    }
    else {
        [self endRecordVoice];
    }
}

- (void)beginRecordVoice {
    _isRecording = YES;
    _isDragInside = YES;
    
    [self uiBeginRecorder];
    
    //[self performSelector:@selector(beginRecorder) withObject:nil afterDelay:0.3];//延遲以避免把音效錄進去
    
    [self beginTimer];
    
    if ([self.delegate respondsToSelector:@selector(UUInputFunctionViewVoiceSpeakButtonBegin)]) {
        [self.delegate UUInputFunctionViewVoiceSpeakButtonBegin];
    }
}

- (void)endRecordVoice {
    if (_isDragInside) {
        [self endRecordVoiceWithDelegate:YES];
    } else {
        [self cancelRecordVoice];
    }
}

- (void)endRecordVoiceWithDelegate:(BOOL)isDelegate {
    if (!_isRecording) {
        return;
    }
    
    if (_recordTime < 1) {
        [self cancelRecordVoice];
        
        return;
    }
    
    [self uiEndRecorder];
    
    [self endRecorder];
    
    [self endTimer];
    
    _isRecording = NO;
    
    _speakButton.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _speakButton.enabled = YES;
    });
    
    if (isDelegate) {
        if ([self.delegate respondsToSelector:@selector(UUInputFunctionViewVoiceSpeakButtonEnd)]) {
            [self.delegate UUInputFunctionViewVoiceSpeakButtonEnd];
        }
    }
}

- (void)cancelRecordVoice {
    if (!_isRecording) {
        return;
    }
    
    [self uiCancelRecorder];
    
    [self cancelRecorder];
    
    [self cancelTimer];
    
    _isRecording = NO;
    
    _speakButton.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _speakButton.enabled = YES;
    });
    
    if ([self.delegate respondsToSelector:@selector(UUInputFunctionViewVoiceSpeakButtonCancel)]) {
        [self.delegate UUInputFunctionViewVoiceSpeakButtonCancel];
    }
}

#pragma mark recorder

- (void)beginRecorder {
    [_mp3Recorder startRecord];
}

- (void)endRecorder {
    if (_recordTimer) {
        [_mp3Recorder stopRecord];
    }
}

- (void)cancelRecorder {
    if (_recordTimer) {
        [_mp3Recorder cancelRecord];
    }
}

#pragma mark playTime

- (void)beginTimer {
    [self endTimer];
    
    _recordTime = 0;
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countTime) userInfo:nil repeats:YES];
}

- (void)endTimer {
    if (_recordTimer) {
        [_recordTimer invalidate];
        _recordTimer = nil;
    }
}

- (void)cancelTimer {
    [self endTimer];
}

- (void)countTime {
    _recordTime ++;
    if (_recordTime>=60) {
        [self endRecordVoiceWithDelegate:YES];
    }
}

#pragma mark Picture

- (void)btnPictureTapped:(id)sender {
    [self.textViewInput resignFirstResponder];
    
    NSString *titleStr = IQLocalizedString(@"選擇圖片來源：", nil);
    NSString *optionStr1 = IQLocalizedString(@"📷 拍照", nil);
    NSString *optionStr2 = IQLocalizedString(@"🗻 相簿", nil);
    NSString *cancelStr = IQLocalizedString(@"✖️ 取消", nil);
    
    UIAlertController *view =   [UIAlertController
                                 alertControllerWithTitle:titleStr
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *option1 = [UIAlertAction
                              actionWithTitle:optionStr1
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [view dismissViewControllerAnimated:YES completion:nil];
                                  
                                  [self checkCameraAccessGranted];
                              }];
    
    UIAlertAction *option2 = [UIAlertAction
                              actionWithTitle:optionStr2
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  [view dismissViewControllerAnimated:YES completion:nil];
                                  
                                  [self checkAlbumAccessGranted];
                              }];
    
    UIAlertAction *cancel = [UIAlertAction
                             actionWithTitle:cancelStr
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [view addAction:option1];
    [view addAction:option2];
    [view addAction:cancel];
    view.popoverPresentationController.sourceView = self;
    
    if (isPad) {
        view.popoverPresentationController.sourceView = _btnPicture;
        view.popoverPresentationController.sourceRect = _btnPicture.frame;
    }
    
    [self.superVC presentViewController:view animated:YES completion:nil];
}

- (void)checkCameraAccessGranted {
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            // Will get here on both iOS 7 & 8 even though camera permissions weren't required
            // until iOS 8. So for iOS 7 permission will always be granted.
            if (granted) {
                // Permission has been granted. Use dispatch_async for any UI updating
                // code because this block may be executed in a thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addCarema];
                });
            } else {
                // Permission has been denied.
                dispatch_async(dispatch_get_main_queue(), ^{
                    //                    [self showCameraAccessAlert];
                });
            }
        }];
    } else {
        // We are on iOS <= 6. Just do what we need to do.
        [self addCarema];
    }
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"

- (void)checkAlbumAccessGranted {
    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        NSLog(@"%zd", [group numberOfAssets]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self openPicLibrary];
        });
    } failureBlock:^(NSError *error) {
        if (error.code == ALAssetsLibraryAccessUserDeniedError) {
            NSLog(@"user denied access, code: %zd", error.code);
            dispatch_async(dispatch_get_main_queue(), ^{
                //                [self showAlbumAccessAlert];
            });
        } else {
            NSLog(@"Other error code: %zd", error.code);
            dispatch_async(dispatch_get_main_queue(), ^{
                //                [self showAlbumAccessAlert];
            });
        }
    }];
}

#pragma GCC diagnostic pop

-(void)addCarema {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.superVC presentViewController:picker animated:YES completion:^{}];
    }else{
        //如果没有提示用户
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"Your device don't have camera" delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil];
        //        [alert show];
    }
}

-(void)openPicLibrary {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.superVC presentViewController:picker animated:YES completion:^{
        }];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.superVC dismissViewControllerAnimated:YES completion:^{
        [self.delegate UUInputFunctionView:self sendPicture:editImage];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.superVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI

#pragma mark recorder

- (void)uiBeginRecorder {
    [self.btnVoiceRecord setTitle:IQLocalizedString(@"鬆開結束", nil) forState:UIControlStateNormal];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"recording_animate" withExtension:@"gif"];
    _speakAnimationImageView.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    _speakAnimationImageView.hidden = NO;
    [_speakButton setImage:[UIImage imageNamed:@"mic-white"] forState:UIControlStateNormal];
    
    if ([IQSetting sharedInstance].ITEM_ASR_TAP.iDefault == 1) {
        [UUProgressHUD show];
    }
}

- (void)uiEndRecorder {
    [self.btnVoiceRecord setTitle:IQLocalizedString(@"按住說話", nil) forState:UIControlStateNormal];
    
    _speakAnimationImageView.image = nil;
    _speakAnimationImageView.hidden = YES;
    [_speakButton setImage:[UIImage imageNamed:@"mic-gray"] forState:UIControlStateNormal];
    
    if ([IQSetting sharedInstance].ITEM_ASR_TAP.iDefault == 1) {
        [UUProgressHUD dismissWithSuccess:IQLocalizedString(@"發送", nil)];
    }
}

- (void)uiCancelRecorder {
    [self.btnVoiceRecord setTitle:IQLocalizedString(@"按住說話", nil) forState:UIControlStateNormal];
    
    _speakAnimationImageView.image = nil;
    _speakAnimationImageView.hidden = YES;
    [_speakButton setImage:[UIImage imageNamed:@"mic-gray"] forState:UIControlStateNormal];
    
    if ([IQSetting sharedInstance].ITEM_ASR_TAP.iDefault == 1) {
        if (_recordTime < 1) {
            [UUProgressHUD dismissWithSuccess:IQLocalizedString(@"時間太短", nil)];
        }
        else {
            [UUProgressHUD dismissWithSuccess:IQLocalizedString(@"取消", nil)];
        }
    }
}

#pragma mark remind

- (void)RemindDragExit:(UIButton *)button {
    _isDragInside = NO;
    if ([IQSetting sharedInstance].ITEM_ASR_TAP.iDefault == 1) {
        [UUProgressHUD changeSubTitle:IQLocalizedString(@"鬆開手指 取消發送", nil)];
    }
}

- (void)RemindDragEnter:(UIButton *)button {
    _isDragInside = YES;
    if ([IQSetting sharedInstance].ITEM_ASR_TAP.iDefault == 1) {
        [UUProgressHUD changeSubTitle:IQLocalizedString(@"手指上滑 取消發送", nil)];
    }
}

#pragma mark - ChangeState

//改变输入与录音状态，或送出文字
- (void)btnChangeStateTapped:(id)sender {
    switch (_type) {
        case UUInputFunctionView_Type_Speak:
        {
            [self cancelRecordVoice];
            
            _type = UUInputFunctionView_Type_Keyboard;
            
            self.btnVoiceRecord.hidden = YES;
            self.textViewInput.hidden  = NO;
            _speakButton.hidden = YES;
            
            [self.btnChangeVoiceState setBackgroundImage:[UIImage imageNamed:@"chat_voice_record"] forState:UIControlStateNormal];
            [self.textViewInput becomeFirstResponder];
            
            if ([self.delegate respondsToSelector:@selector(UUInputFunctionViewVoiceUpdateToType:)]) {
                [self.delegate UUInputFunctionViewVoiceUpdateToType:_type];
            }
        }
            break;
            
        case UUInputFunctionView_Type_Keyboard:
        default:
        {
            if (self.isAbleToSendTextMessage) {
                //        NSString *resultStr = [self.textViewInput.text stringByReplacingOccurrencesOfString:@"   " withString:@""];
                NSString *resultStr = self.textViewInput.text;
                [self.delegate UUInputFunctionView:self sendMessage:resultStr];
            }
            else {
                _type = UUInputFunctionView_Type_Speak;
                
                self.btnVoiceRecord.hidden = NO;
                self.textViewInput.hidden  = YES;
                _speakButton.hidden = NO;
                
                if ([self.delegate respondsToSelector:@selector(UUInputFunctionViewVoiceUpdateToType:)]) {
                    [self.delegate UUInputFunctionViewVoiceUpdateToType:_type];
                }
                
                [self.btnChangeVoiceState setBackgroundImage:[UIImage imageNamed:@"chat_ipunt_message"] forState:UIControlStateNormal];
                [self.textViewInput resignFirstResponder];
            }
        }
            break;
    }
}

#pragma mark - Mp3RecorderDelegate

//回调录音资料
- (void)endConvertWithData:(NSData *)voiceData {
    [self.delegate UUInputFunctionView:self sendVoice:voiceData time:_recordTime+1];
   
    //缓冲消失时间 (最好有block回调消失完成)
    self.btnVoiceRecord.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.btnVoiceRecord.enabled = YES;
    });
}

- (void)failRecord {
    //缓冲消失时间 (最好有block回调消失完成)
    self.btnVoiceRecord.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.btnVoiceRecord.enabled = YES;
    });
}

- (void)beginConvert {
    
}

#pragma mark - TextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _placeHold.hidden = self.textViewInput.text.length > 0;
    
    if (self.textViewInput.text.length == 0) {
        self.textViewInput.contentOffset = CGPointZero;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self changeSendBtnIsExistText:textView.text.length>0?YES:NO];
    _placeHold.hidden = textView.text.length>0;
    
    if (self.textViewInput.text.length == 0) {
        self.textViewInput.contentOffset = CGPointZero;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    _placeHold.hidden = self.textViewInput.text.length > 0;
    
    if (self.textViewInput.text.length == 0) {
        self.textViewInput.contentOffset = CGPointZero;
    }
}

- (void)changeSendBtnIsExistText:(BOOL)isExistText
{
    self.isAbleToSendTextMessage = isExistText;
    
    [self.btnChangeVoiceState setTitle:isExistText? IQLocalizedString(@"送出", nil) : @"" forState:UIControlStateNormal];
    self.btnChangeVoiceState.frame = RECT_CHANGE_width(self.btnChangeVoiceState, isExistText?35:30);
    
    UIImage *image = [UIImage imageNamed:isExistText?@"chat_send_message":@"chat_voice_record"];
    [self.btnChangeVoiceState setBackgroundImage:image forState:UIControlStateNormal];
}

#pragma mark - Factory

- (Mp3Recorder *)getMp3Recorder {
    if (!_mp3Recorder) {
        Mp3Recorder *recorder = [[Mp3Recorder alloc] initWithDelegate:self];
        _mp3Recorder = recorder;
    }
    return _mp3Recorder;
}

- (UIButton *)getSpeakButton {
    if (!_speakButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        _speakButton = button;
        button.accessibilityLabel = @"speakButton";
        [button setImage:[UIImage imageNamed:@"mic-gray"] forState:UIControlStateNormal];
        
        [self updateSpeakButtonControlEventBySetting];
        [self addSubview:button];
        _speakButton.frame = CGRectMake(0, 0, 100, 100);
        _speakButton.center = CGPointMake(self.center.x, INPUTFUNCTIONVIEW_TEXTBAR_HEIGHT + (INPUTFUNCTIONVIEW_SPEAK_HEIGHT - INPUTFUNCTIONVIEW_TEXTBAR_HEIGHT)*0.5 - 5);
//        _speakButton.center = CGPointMake(self.center.x, INPUTFUNCTIONVIEW_SPEAK_HEIGHT*0.5);
        
        if (_speakAnimationImageView) {
            [_speakAnimationImageView removeFromSuperview];
            _speakAnimationImageView = nil;
        }
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        _speakAnimationImageView = imageView;
        [self bringSubviewToFront:_speakButton];
        _speakAnimationImageView.frame = CGRectMake(0, 0, 165, 165);
        _speakAnimationImageView.center = _speakButton.center;
    }
    return _speakButton;
}

- (void)updateSpeakButtonControlEventBySetting {
    [_speakButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
    UIButton *button = [self getSpeakButton];
    
    switch ([IQSetting sharedInstance].ITEM_ASR_TAP.iDefault) {
        case 0:
        {
            [button addTarget:self action:@selector(btnVoiceRecordTapped) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
            
        case 1:
        {
            //            [button setTitle:@"Hold to Talk" forState:UIControlStateNormal];
            //            [button setTitle:@"Release to Send" forState:UIControlStateHighlighted];
            
            [button addTarget:self action:@selector(beginRecordVoice) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(endRecordVoice) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(cancelRecordVoice) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
            
            [button addTarget:self action:@selector(RemindDragExit:) forControlEvents:UIControlEventTouchDragExit];
            [button addTarget:self action:@selector(RemindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
        }
            break;
            
        default:
            break;
    }
}

- (UIButton *)getBtnPicture {
    if (!_btnPicture) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"chat_take_picture"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button addTarget:self action:@selector(btnPictureTapped:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:button];
        
        _btnPicture = button;
        _btnPicture.frame = CGRectMake(5, 5, 30, 30);
        //        _btnPicture.frame = CGRectMake(Main_Screen_Width-40, 5, 30, 30);
    }
    return _btnPicture;
}

- (UIButton *)getBtnChangeVoiceState {
    if (!_btnChangeVoiceState) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.accessibilityLabel = @"btnChangeVoiceState";
        [button setBackgroundImage:[UIImage imageNamed:@"chat_voice_record"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button addTarget:self action:@selector(btnChangeStateTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        _btnChangeVoiceState = button;
        _btnChangeVoiceState.frame = CGRectMake(Main_Screen_Width-40, 5, 30, 30);
        //        _btnChangeVoiceState.frame = CGRectMake(5, 5, 30, 30);
    }
    return _btnChangeVoiceState;
}

- (UIButton *)getBtnVoiceRecord {
    if (!_btnVoiceRecord) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:@"chat_message_back"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [button setTitleColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [button setTitle:IQLocalizedString(@"按住說話", nil) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(btnVoiceRecordTapped) forControlEvents:UIControlEventTouchUpInside];
//        [button setTitle:@"Hold to Talk" forState:UIControlStateNormal];
//        [button setTitle:@"Release to Send" forState:UIControlStateHighlighted];
//        [button addTarget:self action:@selector(beginRecordVoice) forControlEvents:UIControlEventTouchDown];
//        [button addTarget:self action:@selector(endRecordVoice) forControlEvents:UIControlEventTouchUpInside];
//        [button addTarget:self action:@selector(cancelRecordVoice) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchCancel];
//        [button addTarget:self action:@selector(RemindDragExit:) forControlEvents:UIControlEventTouchDragExit];
//        [button addTarget:self action:@selector(RemindDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
        
//        [self addSubview:button];
        _btnVoiceRecord = button;
        _btnVoiceRecord.frame = CGRectMake(70, 5, Main_Screen_Width-70*2, 30);
    }
    return _btnVoiceRecord;
}

- (UITextView *)getTextViewInput {
    if (!_textViewInput) {
        UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(45, 5, Main_Screen_Width-2*45, 30)];
        textView.font = [UIFont systemFontOfSize:18];
        textView.layer.cornerRadius = 4;
        textView.layer.masksToBounds = YES;
        textView.delegate = self;
        textView.layer.borderWidth = 1;
        textView.layer.borderColor = [[[UIColor lightGrayColor] colorWithAlphaComponent:0.4] CGColor];
        textView.accessibilityLabel = @"textViewInput";
        [self addSubview:textView];
        _textViewInput = textView;
        
        if (_placeHold) {
            [_placeHold removeFromSuperview];
            _placeHold = nil;
        }
        //输入框的提示语
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.textViewInput.frame.size.width, self.textViewInput.frame.size.height)];
        label.font = [UIFont systemFontOfSize:18];
        label.text = IQLocalizedString(@"  輸入文字", nil); //Input the contents here
        label.textColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8];
        [_textViewInput addSubview:label];
        _placeHold = label;
    }
    return _textViewInput;
}

@end
