//
//  UIMessageInputView.m
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "UIMessageInputView.h"
#import "UIColor+expanded.h"
#import "UIView+Common.h"
#import "UIMessageInputView_Add.h"
#import "NSString+Common.h"
#import "EmotionKeyboardView.h"
#import "ChatVoiceHUD.h"
#import "VoiceToolView.h"
#import "RecordVoice.h"

#define kKeyboardView_Height 216.0
#define kPaddingLeftWidth 10.0
#define kMessageInputView_Height 50.0
#define kMessageInputView_HeightMax 100.0
#define kMessageInputView_PadingHeight 7.0
#define kMessageInputView_Font [UIFont systemFontOfSize:16]
#define kMessageInputView_Width_Tool 35.0
#define Voice_Size 150

@interface UIMessageInputView ()<UITextViewDelegate, EmotionKeyboardViewDataSource, EmotionKeyboardViewDelegate, UIGestureRecognizerDelegate>

{
    ///语音
    CGFloat xPointVoice;
    CGFloat yPointVoice;
}
@property (nonatomic, weak) UIView *rootView;
@property (nonatomic, strong) EmotionKeyboardView *emotionKeyboardView;     // 表情视图
@property (nonatomic, strong) UIMessageInputView_Add *addKeyboardView;      // 添加照片视图
@property (nonatomic, strong) UIButton *addButton, *emotionButton, *voiceButton, *atButton, *talkButton, *workReportBtn;
@property (nonatomic, assign) UIMessageInputViewState inputState;
@property (nonatomic, assign) CGFloat viewHeightOld;
@property (nonatomic, assign) NSTimeInterval animationDuration;

@property (nonatomic, strong) VoiceToolView *voiceView;
@property (nonatomic, strong) RecordVoice *recordVoice;
@property (nonatomic, strong)  NSString *pathFile;
@property (nonatomic, strong)  NSString *nameFile;
@property (nonatomic, assign) NSInteger voiceTime;
@property (nonatomic, assign) BOOL isSendVoice;

@end

@implementation UIMessageInputView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        [self addLineUp:YES andDown:NO];
        
        _viewHeightOld = kMessageInputView_Height;

        [self addSubview:self.inputTextView];

        _inputState = UIMessageInputViewStateSystem;
        _isAlwaysShow = YES;
        _animationDuration = 0.25;
    }
    return self;
}

+ (instancetype)initMessageInputViewWithType:(UIMessageInputViewType)type andRootView:(UIView *)rootView {
    return [self initMessageInputViewWithType:type andRootView:rootView placeHolder:nil];
}

+ (instancetype)initMessageInputViewWithType:(UIMessageInputViewType)type andRootView:(UIView *)rootView placeHolder:(NSString *)placeHolder {
    UIMessageInputView *messageInputView = [[UIMessageInputView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kMessageInputView_Height)];
    [messageInputView customUIWithType:type];
    if (placeHolder && [placeHolder length]) {
        messageInputView.placeHolder = placeHolder;
    }else {
        messageInputView.placeHolder = @"说点什么吧...";
    }
    
    messageInputView.rootView = rootView;
    
    return messageInputView;
}

- (void)setInputState:(UIMessageInputViewState)inputState {
    if (_inputState != inputState) {
        _inputState = inputState;
        switch (_inputState) {
            case UIMessageInputViewStateSystem:
            {
                
                [_voiceButton setImage:[UIImage imageNamed:@"IM_quicksend_voice"] forState:UIControlStateNormal];
                [_voiceButton setImage:[UIImage imageNamed:@"IM_quicksend_voice_press"] forState:UIControlStateHighlighted];
                [_emotionButton setImage:[UIImage imageNamed:@"emotionButton"] forState:UIControlStateNormal];
                [_emotionButton setImage:[UIImage imageNamed:@"emotionButton_clicked"] forState:UIControlStateHighlighted];
                [_addButton setImage:[UIImage imageNamed:@"bun_add_default"] forState:UIControlStateNormal];
                [_addButton setImage:[UIImage imageNamed:@"bun_add_click"] forState:UIControlStateHighlighted];
                
                _talkButton.hidden = YES;
                
            }
                break;
            case UIMessageInputViewStateVoice:
            {
                [_voiceButton setImage:[UIImage imageNamed:@"quicksend_keyb"] forState:UIControlStateNormal];
                [_voiceButton setImage:[UIImage imageNamed:@"quicksend_keyb_press"] forState:UIControlStateHighlighted];
                [_emotionButton setImage:[UIImage imageNamed:@"emotionButton"] forState:UIControlStateNormal];
                [_emotionButton setImage:[UIImage imageNamed:@"emotionButton_clicked"] forState:UIControlStateHighlighted];
                [_addButton setImage:[UIImage imageNamed:@"bun_add_default"] forState:UIControlStateNormal];
                [_addButton setImage:[UIImage imageNamed:@"bun_add_click"] forState:UIControlStateHighlighted];
                
                _talkButton.hidden = NO;
            }
                break;
            case UIMessageInputViewStateEmotion:
            {
                [_voiceButton setImage:[UIImage imageNamed:@"IM_quicksend_voice"] forState:UIControlStateNormal];
                [_voiceButton setImage:[UIImage imageNamed:@"IM_quicksend_voice_press"] forState:UIControlStateHighlighted];
                [_emotionButton setImage:[UIImage imageNamed:@"quicksend_keyb"] forState:UIControlStateNormal];
                [_emotionButton setImage:[UIImage imageNamed:@"quicksend_keyb_press"] forState:UIControlStateHighlighted];
                [_addButton setImage:[UIImage imageNamed:@"bun_add_default"] forState:UIControlStateNormal];
                [_addButton setImage:[UIImage imageNamed:@"bun_add_click"] forState:UIControlStateHighlighted];
                
                _talkButton.hidden = YES;
            }
                break;
            case UIMessageInputViewStateAdd:
            {
                [_voiceButton setImage:[UIImage imageNamed:@"IM_quicksend_voice"] forState:UIControlStateNormal];
                [_voiceButton setImage:[UIImage imageNamed:@"IM_quicksend_voice_press"] forState:UIControlStateHighlighted];
                [_emotionButton setImage:[UIImage imageNamed:@"emotionButton"] forState:UIControlStateNormal];
                [_emotionButton setImage:[UIImage imageNamed:@"emotionButton_clicked"] forState:UIControlStateHighlighted];
                [_addButton setImage:[UIImage imageNamed:@"quicksend_keyb"] forState:UIControlStateNormal];
                [_addButton setImage:[UIImage imageNamed:@"quicksend_keyb_press"] forState:UIControlStateHighlighted];
                
                _talkButton.hidden = YES;
            }
                break;
            default:
                break;
        }
    }
}

- (void)customUIWithType:(UIMessageInputViewType)type {
    if (type == UIMessageInputViewTypeSimple) { // 只有at按钮和textview
        [_inputTextView setWidth:(kScreen_Width-2*kPaddingLeftWidth-kMessageInputView_Width_Tool)];

        [self addSubview:self.atButton];
    }
    
    if (type == UIMessageInputViewTypeMedia) {
        
        [_inputTextView setX:kMessageInputView_Width_Tool + kPaddingLeftWidth];
        [_inputTextView setWidth:(kScreen_Width - 2*kPaddingLeftWidth - 3*kMessageInputView_Width_Tool)];

        [self addSubview:self.voiceButton];

        [self addSubview:self.talkButton];
        
        [self addSubview:self.addButton];
        
        [self addSubview:self.emotionButton];
        
        // 添加照片视图
        __weak typeof(self) weak_self = self;
        self.addKeyboardView.addButtonClickBlock = ^(NSInteger index) {
            if (weak_self.delegate && [weak_self.delegate respondsToSelector:@selector(messageInputView:addIndexClicked:)]) {
                [weak_self.delegate messageInputView:weak_self addIndexClicked:index];
            }
        };
    }
    
    if (type == UIMessageInputViewTypeWorkReport) {
        [_inputTextView setX:kMessageInputView_Width_Tool + kPaddingLeftWidth];
        [_inputTextView setWidth:kScreen_Width - 2*kPaddingLeftWidth - kMessageInputView_Width_Tool - 50];
        
        [self addSubview:self.atButton];
        [_atButton setX:kPaddingLeftWidth / 2.0];
        [self addSubview:self.workReportBtn];
    }
}

#pragma mark - event response
- (void)atButtonPress {
    if (self.atBlock) {
        self.atBlock();
    }
}

- (void)voiceButtonPress {
    CGFloat endY = kScreen_Height;
    if (self.inputState == UIMessageInputViewStateVoice) {
        self.inputState = UIMessageInputViewStateSystem;
        [self.inputTextView becomeFirstResponder];
    }else {
        self.inputState = UIMessageInputViewStateVoice;
        [self.inputTextView resignFirstResponder];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showKeyBorad" object:@(endY)];
        [UIView animateWithDuration:_animationDuration delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [self.emotionKeyboardView setY:endY];
            [self.addKeyboardView setY:endY];
            [self setY:endY - CGRectGetHeight(self.bounds)];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)addButtonPress {
    CGFloat endY = kScreen_Height;
    if (self.inputState == UIMessageInputViewStateAdd) {    // 弹出键盘，收回addview
        self.inputState = UIMessageInputViewStateSystem;
        [self.inputTextView becomeFirstResponder];
    }else {     // 弹出addView
        self.inputState = UIMessageInputViewStateAdd;
        [self.inputTextView resignFirstResponder];
        endY = kScreen_Height - kKeyboardView_Height;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showKeyBorad" object:@(endY)];
    }
    [UIView animateWithDuration:_animationDuration delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [_addKeyboardView setY:endY];
        [_emotionKeyboardView setY:kScreen_Height];
        
        if (ABS(kScreen_Height - endY) > 0.1) {
            [self setY:endY - CGRectGetHeight(self.bounds)];
        }
    } completion:^(BOOL finished) {
    }];
}

- (void)emotionButtonPress {
    CGFloat endY = kScreen_Height;
    if (self.inputState == UIMessageInputViewStateEmotion) {
        self.inputState = UIMessageInputViewStateSystem;
        [self.inputTextView becomeFirstResponder];
    }else {
        self.inputState = UIMessageInputViewStateEmotion;
        [self.inputTextView resignFirstResponder];
        endY = kScreen_Height - kKeyboardView_Height;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showKeyBorad" object:@(endY)];
    }
    
    [UIView animateWithDuration:_animationDuration delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [self.emotionKeyboardView setY:endY];
        [self.addKeyboardView setY:kScreen_Height];
        if (ABS(kScreen_Height - endY) > 0.1) {
            [self setY:endY - CGRectGetHeight(self.bounds)];
        }
    } completion:^(BOOL finished) {
    }];
}
#pragma mark -  长按录音

- (void)recordBtnLongPressed:(UILongPressGestureRecognizer*) longPressedRecognizer{
    //长按开始
    if(longPressedRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"长按开始");
        _isSendVoice = TRUE;
        [self.rootView addSubview:self.voiceView];
        _voiceView.voiceIconName = @"sound.png";
        [self.recordVoice beginRecordingByFileName:@"recordvoice"];
        __weak typeof(self) weak_self = self;
        _recordVoice.StopRecordingBlock = ^(NSString *path,NSString *name, NSInteger voiceTime){
            NSLog(@"录音文件路径:%@",path);
            NSLog(@"录音文件名:%@",name);
            NSLog(@"录音时长：%ld", voiceTime);
            weak_self.pathFile = path;
            weak_self.nameFile = name;
            weak_self.voiceTime = voiceTime;
            weak_self.recordVoice = nil;
            weak_self.voiceView = nil;
            
            if (weak_self.isSendVoice) {
                NSLog(@"发送");
                [weak_self sendCmd];
            }else{
                NSLog(@"删除");
                [weak_self removeFileFromLocal];
            }
        };
        
    }//长按结束
    else if(longPressedRecognizer.state == UIGestureRecognizerStateEnded || longPressedRecognizer.state == UIGestureRecognizerStateCancelled){
        NSLog(@"长按结束");
        if (self.voiceView) {
            [self.voiceView removeFromSuperview];
        }
        if (_recordVoice) {
            [_recordVoice stopRecording];
        }
        
        
    }else if ([longPressedRecognizer state]==UIGestureRecognizerStateChanged){
        
        CGPoint location=[longPressedRecognizer locationInView:self.rootView];
        
        if ((location.x > xPointVoice) && (location.x < xPointVoice + Voice_Size) && (location.y > yPointVoice) && (location.y < yPointVoice +Voice_Size)) {
            NSLog(@"取消发送");
            ///标记为
            _isSendVoice = FALSE;
            if (_voiceView) {
                _voiceView.voiceIconName = @"remove_allReply_clicked.png";
                _voiceView.capionTitleValue = @"松开取消发送";
                [_voiceView setVoiceSoundHide:YES];
            }
            
        }else{
            _isSendVoice = TRUE;
            if (_voiceView) {
                _voiceView.voiceIconName = @"sound.png";
                _voiceView.capionTitleValue = @"滑动至此取消发送";
                [_voiceView setVoiceSoundHide:NO];
            }
        }
    }
}
- (void)workReportBtnPress {
    [self sendTextStr];
}
-(void)sendCmd{
    NSString *path = [NSString stringWithFormat:@"%@/%@",_pathFile,_nameFile];
    NSLog(@"path:%@",path);
    ///判断 size
   NSData *data = [self getFileByPath:path];
//    NSLog(@"录音文件--%@", data);
    if (self.delegate && [self.delegate respondsToSelector:@selector(getWithVoiceFileData:withVoiceFileName:withVoiceFileTime:)]) {
        [self.delegate getWithVoiceFileData:data withVoiceFileName:self.nameFile withVoiceFileTime:self.voiceTime];
    }
    // 删除录音文件
//    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

-(NSData *)getFileByPath:(NSString *)path{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        
        NSData *data = [fileManager contentsAtPath:path];
//        NSLog(@"size:%lu",[data length]);
//        NSLog(@"size:%lu",[data length]/1024);
        NSLog(@"录音文件 size:%lu",[data length]/1024);
        return data;
    }else{
        NSLog(@"文件不存在--->");
        return nil;
    }
}

-(void)removeFileFromLocal{
    NSString *path = [NSString stringWithFormat:@"%@/%@",_pathFile,_nameFile];
    NSLog(@"path:%@",path);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err;
    [fileManager removeItemAtPath:path error:&err];
    NSLog(@"removeFileFromLocal--->");
}

#pragma mark - Keyboard Notification
- (void)keyboardChange:(NSNotification*)notification {
    if (self.inputState == UIMessageInputViewStateSystem && [self.inputTextView isFirstResponder]) {
        NSDictionary *userInfo = [notification userInfo];
        _animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
        CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        [UIView animateWithDuration:_animationDuration delay:0.0f options:[UIView animationOptionsForCurve:animationCurve] animations:^{
            CGFloat keyboardY = keyboardEndFrame.origin.y;
            if (ABS(keyboardY - kScreen_Height) < 0.1) {
                if (_isAlwaysShow) {
                    [self setY:kScreen_Height - CGRectGetHeight(self.frame)];
                }else {
                    [self setY:kScreen_Height];
                }
            }else {
                [self setY:keyboardY - CGRectGetHeight(self.frame)];
            }
        } completion:^(BOOL finished) {
        }];
    }
}
- (VoiceToolView*)voiceView {
    if (!_voiceView) {
        xPointVoice = (kScreen_Width-Voice_Size)/2;
        yPointVoice = (kScreen_Height-Voice_Size)/2-40;
        NSLog(@"xPointVoice:%f",xPointVoice);
        NSLog(@"yPointVoice:%f",yPointVoice);
        _voiceView = [[VoiceToolView alloc] initWithFrame:CGRectMake(xPointVoice, yPointVoice, Voice_Size, Voice_Size)];
    }
    return _voiceView;
}

- (RecordVoice*)recordVoice {
    if (!_recordVoice) {
        _recordVoice = [[RecordVoice alloc] initWithVoiceToll:_voiceView];
    }
    return _recordVoice;
}
#pragma mark - Public Method

-(void)notifyInputView:(NSString *)str{
    self.inputTextView.text = str;
    [self textViewDidChange:self.inputTextView];
}
- (void)prepareToShow {
    if (_isAlwaysShow) {
//        [self setY:kScreen_Height - kMessageInputView_Height];
         [self setY:kScreen_Height - _inputTextView.frame.size.height-2*7];
    }else {
        [self setY:kScreen_Height];
    }
    
    [self.rootView addSubview:self];
    [self.rootView addSubview:self.emotionKeyboardView];
    [self.rootView addSubview:self.addKeyboardView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)prepareToDismiss {
    [self isAndResignFirstResponder];
    [UIView animateWithDuration:_animationDuration delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [self setY:kScreen_Height];
    } completion:^(BOOL finished) {
        [_emotionKeyboardView removeFromSuperview];
        [_addKeyboardView removeFromSuperview];
        [self removeFromSuperview];
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)notAndBecomeFirstResponder {
    self.inputState = UIMessageInputViewStateSystem;
    if ([_inputTextView isFirstResponder]) {
        return NO;
    }else {
        [_inputTextView becomeFirstResponder];
        return YES;
    }
}

- (BOOL)isAndResignFirstResponder {
    if (self.inputState == UIMessageInputViewStateAdd || self.inputState == UIMessageInputViewStateEmotion || self.inputState == UIMessageInputViewStateVoice) {
        [UIView animateWithDuration:_animationDuration delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [_emotionKeyboardView setY:kScreen_Height];
            [_addKeyboardView setY:kScreen_Height];
            if (_isAlwaysShow) {
                [self setY:kScreen_Height-CGRectGetHeight(self.frame)];
            }else {
                [self setY:kScreen_Height];
            }
        } completion:^(BOOL finished) {
            self.inputState = UIMessageInputViewStateSystem;
        }];
        return YES;
    }else {
        if ([self.inputTextView isFirstResponder]) {
            [self.inputTextView resignFirstResponder];
            return YES;
        }else {
            return NO;
        }
    }
}

- (BOOL)isCustomFirstResponder {
    return ([_inputTextView isFirstResponder] || self.inputState == UIMessageInputViewStateAdd || self.inputState == UIMessageInputViewStateEmotion || self.inputState == UIMessageInputViewStateVoice);
}

#pragma mark - UITextViewDelegate
- (void)sendTextStr{
    NSString *sendStr = self.inputTextView.text;
    
    ///批阅可以为空
    if (_isApprove) {
        if (_delegate && [_delegate respondsToSelector:@selector(messageInputView:sendText:)]) {
            //        self.inputTextView.text = @"";
            [self.delegate messageInputView:self sendText:sendStr];
            [self textViewDidChange:self.inputTextView];
        }
    }else{
        if (sendStr && ![sendStr isEmpty] && _delegate && [_delegate respondsToSelector:@selector(messageInputView:sendText:)]) {
            //        self.inputTextView.text = @"";
            [self.delegate messageInputView:self sendText:sendStr];
            [self textViewDidChange:self.inputTextView];
        }
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self sendTextStr];
        return NO;
    }
    
    return YES;
    
    /*
    // 限制textView字数
    UITextRange *selectedRange = [textView markedTextRange];
    // 获取高亮部分
    UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
    
    // 如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && position) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < MAX_LIMIT_TEXTVIEW) {
            return YES;
        }
        else {
            return NO;
        }
    }
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = MAX_LIMIT_TEXTVIEW - comcatstr.length;
    
    if (caninputlen >= 0) {
        return YES;
    }
    else {
        NSInteger len = text.length + caninputlen;
        // 防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = [text substringWithRange:rg];
            
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
     */
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.inputState != UIMessageInputViewStateSystem) {
        self.inputState = UIMessageInputViewStateSystem;
        [UIView animateWithDuration:_animationDuration delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [_emotionKeyboardView setY:kScreen_Height];
            [_addKeyboardView setY:kScreen_Height];
        } completion:^(BOOL finished) {
            self.inputState = UIMessageInputViewStateSystem;
        }];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (self.inputState == UIMessageInputViewStateSystem) {
        [UIView animateWithDuration:_animationDuration delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            if (_isAlwaysShow) {
                [self setY:kScreen_Height- CGRectGetHeight(self.frame)];
            }else{
                [self setY:kScreen_Height];
            }
        } completion:^(BOOL finished) {
        }];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    /*
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > MAX_LIMIT_TEXTVIEW)
    {
        //截取到最大位置的字符
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_TEXTVIEW];
        
        [textView setText:s];
    }
    
    */
    
    CGFloat viewHeightNew = [textView.text getHeightWithFont:textView.font constrainedToSize:CGSizeMake(CGRectGetWidth(textView.frame)-16, kMessageInputView_HeightMax)]+16 + 2*kMessageInputView_PadingHeight;
    viewHeightNew = MAX(kMessageInputView_Height, viewHeightNew);
    if (viewHeightNew != _viewHeightOld) {
        
        CGFloat diffHeight = viewHeightNew - _viewHeightOld;
        
        CGRect viewFrame = self.frame;
        CGRect textViewFrame = textView.frame;
        
        viewFrame.size.height += diffHeight;
        viewFrame.origin.y -= diffHeight;
        textViewFrame.size.height += diffHeight;
        self.frame = viewFrame;
        textView.frame = textViewFrame;
        if (viewHeightNew < _viewHeightOld) {
            //textView的contentSize并没有根据现实内容的大小马上改变，所以在这里对它的ContentOffset处理也做一个延时
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [textView setContentOffset:CGPointMake(0, MAX(0, textView.contentSize.height - textViewFrame.size.height)) animated:YES];
            });
        }else{
            [textView setContentOffset:CGPointMake(0, MAX(0, textView.contentSize.height - textViewFrame.size.height)) animated:YES];
        }
        _viewHeightOld = viewHeightNew;
    }
}

#pragma mark - EmotionKeyboardViewDataSource
- (NSDictionary*)emotionKeyboardView:(EmotionKeyboardView *)emotionKeyboardView emotionSourceAtCategory:(EmotionKeyboardViewCategoryImage)category {
    if (EmotionKeyboardViewCategoryImageQQ == category) {
        // 导入表情资源
        NSString *path = [[NSBundle mainBundle] pathForResource:@"emotionImage" ofType:@"plist"];
        NSDictionary *emotionDict = [NSDictionary dictionaryWithContentsOfFile:path];
        return emotionDict;
    }
    return nil;
}

#pragma mark - EmotionKeyboardViewDelegate
- (void)emotionKeyBoardView:(EmotionKeyboardView *)emotionKeyboardView didUseEmotion:(NSString *)emotion {
    NSRange selectedRange = self.inputTextView.selectedRange;
    self.inputTextView.text = [self.inputTextView.text stringByReplacingCharactersInRange:selectedRange withString:emotion];
    self.inputTextView.selectedRange = NSMakeRange(selectedRange.location + emotion.length, 0);
    [self textViewDidChange:self.inputTextView];
}

- (void)emotionKeyBoardViewDidPressBackSpace:(EmotionKeyboardView *)emotionKeyboardView {
    [self.inputTextView deleteBackward];
}

- (void)emotionKeyBoardViewDidPressSendButton:(EmotionKeyboardView *)emotionKeyboardView {
    [self sendTextStr];
}

#pragma mark - getters and setters
- (void)setPlaceHolder:(NSString *)placeHolder {
    if (_placeHolder != placeHolder) {
        _placeHolder = placeHolder;
        if (_inputTextView) {
            _inputTextView.placeholder = placeHolder;
        }
    }
}

- (void)setIsApprove:(BOOL)isApprove {
    if (isApprove) {
        [_workReportBtn setTitle:@"批阅" forState:UIControlStateNormal];
    }else {
        [_workReportBtn setTitle:@"评论" forState:UIControlStateNormal];
    }
    
    _isApprove = isApprove;
}

- (UIPlaceHolderTextView*)inputTextView {
    if (!_inputTextView) {
        CGFloat inputTextViewHeight = kMessageInputView_Height - 2*kMessageInputView_PadingHeight;
        _inputTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, kMessageInputView_PadingHeight, kScreen_Width-2*kPaddingLeftWidth, inputTextViewHeight)];
        _inputTextView.layer.borderWidth = 0.5;
        _inputTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _inputTextView.layer.cornerRadius = 10.0;
        _inputTextView.font = kMessageInputView_Font;
        _inputTextView.returnKeyType = UIReturnKeySend;
        _inputTextView.scrollsToTop = NO;
        _inputTextView.delegate = self;
    }
    return _inputTextView;
}

- (UIButton*)atButton {
    if (!_atButton) {
        _atButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _atButton.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth/2.0 - kMessageInputView_Width_Tool, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2.0, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool);
        [_atButton setImage:[UIImage imageNamed:@"feed_comments_at"] forState:UIControlStateNormal];
        [_atButton addTarget:self action:@selector(atButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _atButton;
}

- (UIButton*)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _voiceButton.frame = CGRectMake(kPaddingLeftWidth/2.0, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2.0, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool);
        [_voiceButton setImage:[UIImage imageNamed:@"IM_quicksend_voice"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"IM_quicksend_voice_press"] forState:UIControlStateHighlighted];
        [_voiceButton addTarget:self action:@selector(voiceButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (UIButton*)addButton {
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addButton.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth/2 - kMessageInputView_Width_Tool, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2.0, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool);
        [_addButton setImage:[UIImage imageNamed:@"bun_add_default"] forState:UIControlStateNormal];
        [_addButton setImage:[UIImage imageNamed:@"bun_add_click"] forState:UIControlStateHighlighted];
        [_addButton addTarget:self action:@selector(addButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

- (UIButton*)emotionButton {
    if (!_emotionButton) {
        _emotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _emotionButton.frame = CGRectMake(kScreen_Width - kPaddingLeftWidth/2.0 - 2*kMessageInputView_Width_Tool, (kMessageInputView_Height - kMessageInputView_Width_Tool)/2.0, kMessageInputView_Width_Tool, kMessageInputView_Width_Tool);
        [_emotionButton setImage:[UIImage imageNamed:@"emotionButton"] forState:UIControlStateNormal];
        [_emotionButton setImage:[UIImage imageNamed:@"emotionButton_clicked"] forState:UIControlStateHighlighted];
        [_emotionButton addTarget:self action:@selector(emotionButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emotionButton;
}

- (UIButton*)talkButton {
    if (!_talkButton) {
        _talkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _talkButton.frame = _inputTextView.frame;
        _talkButton.backgroundColor = [UIColor whiteColor];
        _talkButton.hidden = YES;
        _talkButton.clipsToBounds = YES;
        _talkButton.layer.masksToBounds = YES;
        _talkButton.layer.cornerRadius = 5.0f;
        _talkButton.layer.borderWidth = 0.5;
        _talkButton.layer.borderColor = [UIColor colorWithHexString:@"909090"].CGColor;
        _talkButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_talkButton setTitle:@"按住说话" forState:UIControlStateNormal];
        [_talkButton setTitleColor:[UIColor colorWithHexString:@"5d5d5d"] forState:UIControlStateNormal];
        [_talkButton setBackgroundImage:[UIImage imageNamed:@"quicksend_speak.png"] forState:UIControlStateNormal];
        //添加长按手势
        UILongPressGestureRecognizer *longPrees = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(recordBtnLongPressed:)];
        longPrees.delegate = self;
        [_talkButton addGestureRecognizer:longPrees];
    }
    return _talkButton;
}

- (UIButton*)workReportBtn {
    if (!_workReportBtn) {
        _workReportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _workReportBtn.frame = CGRectMake(kScreen_Width - 50 - kPaddingLeftWidth / 2.0, kPaddingLeftWidth, 50, kMessageInputView_Height - 2*kPaddingLeftWidth);
        _workReportBtn.layer.cornerRadius = 5.0f;
        _workReportBtn.layer.borderWidth = 0.5;
        _workReportBtn.layer.borderColor = [UIColor grayColor].CGColor;
        _workReportBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_workReportBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_workReportBtn addTarget:self action:@selector(workReportBtnPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _workReportBtn;
}

- (UIMessageInputView_Add*)addKeyboardView {
    if (!_addKeyboardView) {
        _addKeyboardView = [[UIMessageInputView_Add alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kKeyboardView_Height)];
        [_addKeyboardView setY:kScreen_Height];
    }
    return _addKeyboardView;
}

- (EmotionKeyboardView*)emotionKeyboardView {
    if (!_emotionKeyboardView) {
        _emotionKeyboardView = [[EmotionKeyboardView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kKeyboardView_Height)];
        _emotionKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _emotionKeyboardView.dataSource = self;
        _emotionKeyboardView.delegate = self;
        [_emotionKeyboardView setY:kScreen_Height];
    }
    return _emotionKeyboardView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end