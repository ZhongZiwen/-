//
//  LoginTableViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/5/8.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginTableViewCell : UITableViewCell

@property (copy, nonatomic) void(^sendCaptchaBlock)(void);
@property (copy, nonatomic) void(^textValueChangedBlock)(NSString*);

+ (CGFloat)cellHeight;
- (void)configTextFieldWithPlaceholder:(NSString*)placeholder captchaWithBool:(BOOL)isCaptcha;
-(void)setCellInfo:(NSString *)info;
-(void)setTextSecure:(BOOL) isSecure;
@end
