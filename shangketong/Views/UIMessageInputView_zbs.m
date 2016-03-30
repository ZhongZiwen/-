//
//  UIMessageInputView.m
//  shangketong
//
//  Created by sungoin-zbs on 15/10/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "UIMessageInputView_zbs.h"
#import "UIPlaceHolderTextView.h"
#import "UIMessageInputView_Add.h"
#import "UIMessageInputView_Voice.h"
#import "UIMessageInputView_Emotion.h"

#define kKeyboardView_Height 216.0
#define kMessageInputView_Height 50.0
#define kMessageInputView_HeightMax 120.0
#define kMessageInputView_PadingHeight 7.0
#define kMessageInputView_Width_Button 35.0

@interface UIMessageInputView_zbs ()<UITextViewDelegate>

@property (strong, nonatomic) UIMessageInputView_Add *addKeyboardView;
@property (strong, nonatomic) UIMessageInputView_Voice *voiceKeyboardView;
@property (strong, nonatomic) UIMessageInputView_Emotion *emotionKeyboardView;

@property (strong, nonatomic) UIButton *voiceButton;
@property (strong, nonatomic) UIButton *emotionButton;
@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) UIButton *photoButton;        // 市场活动详情中添加图片按钮
@property (strong, nonatomic) UIButton *recordButton;       // 添加活动类型记录
@property (strong, nonatomic) UIButton *arrowButton;        // 箭头按钮(回收语音界面)
@property (strong, nonatomic) UIButton *atButton;

@property (assign, nonatomic) CGFloat viewHeightOld;
@property (assign, nonatomic) NSTimeInterval animationDuration;
@property (assign, nonatomic) UIMessageInputViewState inputState;

// 根据类型设置UI样式
- (void)configUIWithType:(UIMessageInputViewType)type;
@end

@implementation UIMessageInputView_zbs

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        [self addLineUp:YES andDown:NO andColor:[UIColor lightGrayColor]];
        
        _viewHeightOld = CGRectGetHeight(frame);
        _animationDuration = 0.25;
        _inputState = UIMessageInputViewStateSystem;
        _isAlwaysShow = NO;
        
        
    }
    return self;
}

+ (instancetype)initMessageInputViewWithType:(UIMessageInputViewType)type {
    return [self initMessageInputViewWithType:type placeHolder:nil];
}

+ (instancetype)initMessageInputViewWithType:(UIMessageInputViewType)type placeHolder:(NSString *)placeHolder {
    UIMessageInputView_zbs *messageInputView = [[UIMessageInputView_zbs alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kMessageInputView_Height)];
    [messageInputView configUIWithType:type];
    if (placeHolder) {
        messageInputView.placeHolder = placeHolder;
    }else {
        messageInputView.placeHolder = @"说点什么吧...";
    }
    return messageInputView;
}

#pragma mark - event response
- (void)voiceButtonPress {
    CGFloat endY = kScreen_Height;
    if (_inputState == UIMessageInputViewStateVoice) {
        self.inputState = UIMessageInputViewStateSystem;
        [_inputTextView becomeFirstResponder];
    }else {
        self.inputState = UIMessageInputViewStateVoice;
        [_inputTextView resignFirstResponder];
        endY = kScreen_Height - kKeyboardView_Height;
    }
    
    [UIView animateWithDuration:_animationDuration delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
        [_voiceKeyboardView setY:endY];
        [_addKeyboardView setY:kScreen_Height];
        [_emotionKeyboardView setY:kScreen_Height];
        if (ABS(kScreen_Height - endY) > 0.1) {
            [self setY:endY - kMessageInputView_Height];
        }
    } completion:nil];
}

- (void)emotionButtonPress {
    
}

- (void)addButtonPress {
    
}

- (void)photoButtonPress {
    [self isAndResignFirstResponder];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (_delegate && [_delegate respondsToSelector:@selector(messageInputView:photoType:)]) {
            [_delegate messageInputView:self photoType:0];
        }
    }];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (_delegate && [_delegate respondsToSelector:@selector(messageInputView:photoType:)]) {
            [_delegate messageInputView:self photoType:1];
        }
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:cameraAction];
    [alertController addAction:photoAction];
    [kKeyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)recordButtonPress {
    if (_delegate && [_delegate respondsToSelector:@selector(messageInputViewRecord)]) {
        [_delegate messageInputViewRecord];
    }
}

- (void)arrowButtonPress {
    [self isAndResignFirstResponder];
}

- (void)atButtonPress {
    if (_delegate && [_delegate respondsToSelector:@selector(messageInputViewAt)]) {
        [_delegate messageInputViewAt];
    }
}

#pragma mark - public method
- (void)prepareToShowWithView:(UIView*)view {
    
    [self setY:_isAlwaysShow ? kScreen_Height - CGRectGetHeight(self.bounds) : kScreen_Height];
    [view addSubview:self];
    
    switch (_type) {
        case UIMessageInputViewTypeRecord: {
            [view addSubview:self.voiceKeyboardView];
        }
            break;
        case UIMessageInputViewTypeComment:
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)prepareToDismiss {
    if (![self superview]) {
        return;
    }
    
    [self isAndResignFirstResponder];
    //    [UIView animateWithDuration:_animationDuration delay:0.0 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
    //        [self setY:kScreen_Height];
    //    } completion:^(BOOL finished) {
    //        [_emotionKeyboardView removeFromSuperview];
    //        [_addKeyboardView removeFromSuperview];
    //        [_voiceKeyboardView removeFromSuperview];
    //        [self removeFromSuperview];
    //    }];
    
    [_emotionKeyboardView removeFromSuperview];
    [_addKeyboardView removeFromSuperview];
    [_voiceKeyboardView removeFromSuperview];
    [self removeFromSuperview];
    
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
    if (_inputState == UIMessageInputViewStateAdd || _inputState == UIMessageInputViewStateEmotion || _inputState == UIMessageInputViewStateVoice) {
        [UIView animateWithDuration:_animationDuration delay:0.0f options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{
            [_emotionKeyboardView setY:kScreen_Height];
            [_addKeyboardView setY:kScreen_Height];
            [_voiceKeyboardView setY:kScreen_Height];
            
            [self setY:_isAlwaysShow ? kScreen_Height - CGRectGetHeight(self.bounds) : kScreen_Height];
            
        } completion:^(BOOL finished) {
            self.inputState = UIMessageInputViewStateSystem;
        }];
        
        return YES;
    }
    
    if ([_inputTextView isFirstResponder]) {
        [_inputTextView resignFirstResponder];
        return YES;
    }else {
        return NO;
    }
}

#pragma mark - private method
- (void)configUIWithType:(UIMessageInputViewType)type {
    _type = type;
    
    switch (_type) {
        case UIMessageInputViewTypeRecord: {
            [self addSubview:self.recordButton];
            [self addSubview:self.photoButton];
            [self addSubview:self.inputTextView];
            [self addSubview:self.arrowButton];
            [self addSubview:self.voiceButton];
            
            [_recordButton setX:7];
            [_photoButton setX:CGRectGetMaxX(_recordButton.frame)];
            [_inputTextView setX:CGRectGetMaxX(_photoButton.frame) + 7];
            [_inputTextView setWidth:kScreen_Width - 4 * kMessageInputView_PadingHeight - 3 * kMessageInputView_Width_Button];
            [_arrowButton setX:CGRectGetMinX(_inputTextView.frame)];
            [_arrowButton setWidth:CGRectGetWidth(_inputTextView.bounds)];
            [_voiceButton setX:CGRectGetMaxX(_inputTextView.frame) + 7];
        }
            break;
        case UIMessageInputViewTypeComment: {
            
            [self addSubview:self.inputTextView];
            [self addSubview:self.atButton];
            
            [_inputTextView setX:7];
            [_inputTextView setWidth:kScreen_Width - 3 * kMessageInputView_PadingHeight - kMessageInputView_Width_Button];
            [_atButton setX:CGRectGetMaxX(_inputTextView.frame) + 7];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UITextViewDelegate
- (void)sendTextStr{
    NSString *sendStr = self.inputTextView.text;
    if (sendStr && ![sendStr isEmpty] && _delegate && [_delegate respondsToSelector:@selector(messageInputView:sendText:)]) {
        [self.delegate messageInputView:self sendText:sendStr];
        self.inputTextView.text = @"";
        [self textViewDidChange:self.inputTextView];
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

#pragma mark - KeyBoard Notification Handlers
- (void)keyboardChange:(NSNotification*)notification {
    if ([notification name] == UIKeyboardDidChangeFrameNotification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    }
    
    if (self.inputState == UIMessageInputViewStateSystem && [_inputTextView isFirstResponder]) {
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

#pragma mark - setters and getters
- (void)setInputState:(UIMessageInputViewState)inputState {
    if (_inputState == inputState) return;
    
    _inputState = inputState;
    switch (_inputState) {
        case UIMessageInputViewStateSystem: {
            [_addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
            [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
            [_voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
        }
            break;
        case UIMessageInputViewStateEmotion: {
            [_addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
            [_emotionButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
            [_voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
        }
            break;
        case UIMessageInputViewStateAdd: {
            [_addButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
            [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
            [_voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
        }
            break;
        case UIMessageInputViewStateVoice: {
            [_addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
            [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
            [_voiceButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
    _arrowButton.hidden = !(_inputState == UIMessageInputViewStateVoice);
}

- (void)setPlaceHolder:(NSString *)placeHolder {
    if (_placeHolder != placeHolder) {
        _placeHolder = placeHolder;
        if (_inputTextView) {
            _inputTextView.placeholder = placeHolder;
        }
    }
}

- (UIPlaceHolderTextView*)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(0, 0, 0, kMessageInputView_Height - 2 * kMessageInputView_PadingHeight)];
        [_inputTextView setCenterY:CGRectGetHeight(self.bounds) / 2];
        _inputTextView.layer.borderWidth = 0.5;
        _inputTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _inputTextView.layer.cornerRadius = CGRectGetHeight(_inputTextView.bounds) / 2;
        _inputTextView.font = [UIFont systemFontOfSize:16];
        _inputTextView.returnKeyType = UIReturnKeySend;
        _inputTextView.scrollsToTop = NO;
        _inputTextView.delegate = self;
        
        // 输入框缩进
        UIEdgeInsets insets = _inputTextView.textContainerInset;
        insets.left += 8.0;
        insets.right += 8.0;
        _inputTextView.textContainerInset = insets;
    }
    return _inputTextView;
}

- (UIButton*)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voiceButton setWidth:kMessageInputView_Width_Button];
        [_voiceButton setHeight:kMessageInputView_Width_Button];
        [_voiceButton setCenterY:CGRectGetHeight(self.bounds) / 2];
        [_voiceButton setImage:[UIImage imageNamed:@"keyboard_voice"] forState:UIControlStateNormal];
        [_voiceButton addTarget:self action:@selector(voiceButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (UIButton*)emotionButton {
    if (!_emotionButton) {
        _emotionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_emotionButton setWidth:kMessageInputView_Width_Button];
        [_emotionButton setHeight:kMessageInputView_Width_Button];
        [_emotionButton setCenterY:CGRectGetHeight(self.bounds) / 2];
        [_emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
        [_emotionButton addTarget:self action:@selector(emotionButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emotionButton;
}

- (UIButton*)addButton {
    if (!_addButton) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setWidth:kMessageInputView_Width_Button];
        [_addButton setHeight:kMessageInputView_Width_Button];
        [_addButton setCenterY:CGRectGetHeight(self.bounds) / 2];
        [_addButton setImage:[UIImage imageNamed:@"keyboard_add"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

- (UIButton*)photoButton {
    if (!_photoButton) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoButton setWidth:kMessageInputView_Width_Button];
        [_photoButton setHeight:kMessageInputView_Width_Button];
        [_photoButton setCenterY:CGRectGetHeight(self.bounds) / 2];
        [_photoButton setImage:[UIImage imageNamed:@"activity_img"] forState:UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(photoButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoButton;
}

- (UIButton*)recordButton {
    if (!_recordButton) {
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordButton setWidth:kMessageInputView_Width_Button];
        [_recordButton setHeight:kMessageInputView_Width_Button];
        [_recordButton setCenterY:CGRectGetHeight(self.bounds) / 2];
        [_recordButton setImage:[UIImage imageNamed:@"quicksend_activitylist"] forState:UIControlStateNormal];
        [_recordButton addTarget:self action:@selector(recordButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordButton;
}

- (UIButton*)arrowButton {
    if (!_arrowButton) {
        _arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _arrowButton.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        [_arrowButton setHeight:kMessageInputView_Height - 2 * kMessageInputView_PadingHeight];
        [_arrowButton setCenterY:kMessageInputView_Height / 2];
        _arrowButton.hidden = YES;
        [_arrowButton setImage:[UIImage imageNamed:@"keyboard_arrow_down"] forState:UIControlStateNormal];
        [_arrowButton addTarget:self action:@selector(arrowButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _arrowButton;
}

- (UIButton*)atButton {
    if (!_atButton) {
        _atButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_atButton setWidth:kMessageInputView_Width_Button];
        [_atButton setHeight:kMessageInputView_Width_Button];
        [_atButton setCenterY:CGRectGetHeight(self.bounds) / 2];
        [_atButton setImage:[UIImage imageNamed:@"keyboard_at"] forState:UIControlStateNormal];
        [_atButton addTarget:self action:@selector(atButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _atButton;
}

- (UIMessageInputView_Add*)addKeyboardView {
    if (!_addKeyboardView) {
        _addKeyboardView = [[UIMessageInputView_Add alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kKeyboardView_Height)];
        _addKeyboardView.addButtonClickBlock = ^(NSInteger index) {
            
        };
    }
    return _addKeyboardView;
}

- (UIMessageInputView_Voice*)voiceKeyboardView {
    if (!_voiceKeyboardView) {
        __weak typeof(self) weak_self = self;
        _voiceKeyboardView = [[UIMessageInputView_Voice alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kKeyboardView_Height)];
        _voiceKeyboardView.recordSuccessfully = ^(NSString *file, NSTimeInterval duration) {
            if (weak_self.delegate && [weak_self.delegate respondsToSelector:@selector(messageInputView:sendVoice:duration:)]) {
                [weak_self.delegate messageInputView:weak_self sendVoice:file duration:duration];
            }
        };
    }
    return _voiceKeyboardView;
}

- (UIMessageInputView_Emotion*)emotionKeyboardView {
    if (!_emotionKeyboardView) {
        _emotionKeyboardView = [[UIMessageInputView_Emotion alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, kKeyboardView_Height)];
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
