//
//  CaptchaHelpViewController.m
//  shangketong
//
//  Created by sungoin-zbs on 16/1/19.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "CaptchaHelpViewController.h"
#import "UIViewController+Expand.h"

@interface CaptchaHelpViewController ()

@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UIButton *callButton;
@end

@implementation CaptchaHelpViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = VIEW_BG_COLOR;
    
    [self.view addSubview:self.contentLabel];
    [self.view addSubview:self.callButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)callButtonPress {
    [self takePhoneWithNumber:@"400-999-0000"];
}

- (UILabel*)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        [_contentLabel setX:15.0];
        [_contentLabel setY:64.0f + 15.0f];
        [_contentLabel setWidth:kScreen_Width - 30.0f];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _contentLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
        _contentLabel.text = @"亲爱的用户，验证短信正常都会在数秒钟内发送，如果您未收到短信/邮件，请参照如下常见情况进行解决:\n\n1、由于您的手机或邮件软件设定了某些安全设置，验证短信/邮件可能被拦截进了垃圾箱。请打开垃圾短信箱读取短信，并将商客通号码添加为白名单。\n\n2、由于运营商通道故障造成了短信/邮件发送时间延迟，请耐心稍候片刻或者点击重新获取验证码。\n\n3、关于手机号验证，目前支持移动、联通和电信的所有号码，暂不支持国际及港澳台地区号码。\n\n如果您尝试了上述方式均未解决，或存有疑问，请通过热线电话400-999-0000或在线咨询获取客户协助";
        [_contentLabel sizeToFit];
    }
    return _contentLabel;
}

- (UIButton*)callButton {
    if (!_callButton) {
        _callButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_callButton setWidth:200];
        [_callButton setHeight:30];
        [_callButton setCenterX:kScreen_Width / 2.0];
        [_callButton setY:kScreen_Height - 30 - 20];
        _callButton.backgroundColor = LIGHT_BLUE_COLOR;
        _callButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_callButton setTitle:@"拨打免费热线 400-999-0000" forState:UIControlStateNormal];
        [_callButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_callButton addTarget:self action:@selector(callButtonPress) forControlEvents:UIControlEventTouchUpInside];
    }
    return _callButton;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
