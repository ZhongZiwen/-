//
//  LoginTableViewCell.m
//  shangketong
//
//  Created by sungoin-zbs on 15/5/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "LoginTableViewCell.h"

@interface LoginTableViewCell ()

@property (nonatomic, strong) UITextField *m_textField;
@property (nonatomic, strong) UIButton *m_captchaButton;
@end

@implementation LoginTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!_m_textField) {
            _m_textField = [[UITextField alloc] initWithFrame:CGRectZero];
            _m_textField.font = kCellTitleFont;
            _m_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            [_m_textField addTarget:self action:@selector(textValueChanged:) forControlEvents:UIControlEventEditingChanged];
            [self.contentView addSubview:_m_textField];
        }
        
        if (!_m_captchaButton) {
            _m_captchaButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _m_captchaButton.backgroundColor = [UIColor colorWithRed:66/255.0 green:139/255.0 blue:202/255.0 alpha:1];
            _m_captchaButton.layer.cornerRadius = 3;
            _m_captchaButton.clipsToBounds = YES;
            _m_captchaButton.titleLabel.font = kCellTitleFont;
            [_m_captchaButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_m_captchaButton addTarget:self action:@selector(captchaButtonPress) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_m_captchaButton];
        }
        
    }
    return self;
}

- (void)textValueChanged:(UITextField *)sender {
    if (_m_textField.text.length > MAX_LIMIT_TEXTFIELD) {
        _m_textField.text = [_m_textField.text substringToIndex:MAX_LIMIT_TEXTFIELD];
    }
    
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(_m_textField.text);
    }
}

- (void)captchaButtonPress {
    if (self.sendCaptchaBlock) {
        self.sendCaptchaBlock();
        
        [self timeOut];
    }
}

- (void)configTextFieldWithPlaceholder:(NSString *)placeholder captchaWithBool:(BOOL)isCaptcha
{
    CGRect frame;
    _m_textField.text = @"";
    
    if (isCaptcha) {    // 需要验证码
        
        frame = _m_textField.frame;
        frame = CGRectMake(kCellLeftWidth, 5, kScreen_Width-3*kCellLeftWidth-120, [LoginTableViewCell cellHeight]-2*5);
        _m_textField.frame = frame;
        _m_textField.placeholder = placeholder;
        
        frame = _m_captchaButton.frame;
        frame.origin.x = kScreen_Width-kCellLeftWidth-120;
        frame.origin.y = 5;
        frame.size.width = 120;
        frame.size.height = [LoginTableViewCell cellHeight]-2*5;
        _m_captchaButton.frame = frame;
        _m_captchaButton.hidden = NO;
        
        [self timeOut];
        
    }else{
        
        frame = _m_textField.frame;
        frame = CGRectMake(kCellLeftWidth, 5, kScreen_Width-2*kCellLeftWidth, [LoginTableViewCell cellHeight]-2*5);
        _m_textField.frame = frame;
        _m_textField.placeholder = placeholder;
        
        _m_captchaButton.hidden = YES;
    }
}

-(void)setCellInfo:(NSString *)info{
    _m_textField.text = info;
}

-(void)setTextSecure:(BOOL) isSecure{
    _m_textField.secureTextEntry = isSecure;
}


- (void)timeOut
{
    __block int timeout=60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [_m_captchaButton setTitle:@"重新获取验证码" forState:UIControlStateNormal];
                _m_captchaButton.userInteractionEnabled = YES;
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [_m_captchaButton setTitle:[NSString stringWithFormat:@"重新获取(%@)",strTime] forState:UIControlStateNormal];
                _m_captchaButton.userInteractionEnabled = NO;
                
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}

+ (CGFloat)cellHeight
{
    return 54.0f;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
