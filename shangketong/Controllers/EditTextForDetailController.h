//
//  EditTextForDetailController.h
//  shangketong
//  任务详情----编辑任务名称+任务描述
//  Created by 蒋 on 15/8/10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTextForDetailController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) NSString *textStr; //接受任务名称
@property (nonatomic, copy) void(^backTextViewValveBlock)(NSString *valueSt);
@end
