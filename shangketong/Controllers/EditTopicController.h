//
//  EditTopicController.h
//  shangketong
//
//  Created by 蒋 on 15/9/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditTopicController : UIViewController
//@property (weak, nonatomic) IBOutlet UITextField *editTF;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (nonatomic, copy) NSString *topicTitle;
@property (nonatomic, strong) void(^BackGroupTopicBlock)(NSString *string);
@end
