//
//  RecordSendVoiceView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordSendVoiceView : UIView

@property (copy, nonatomic) void(^recordSuccessfully)(NSString *file, NSTimeInterval duration);
@property (copy, nonatomic) void(^deleteRecordBlock)(void);
@end
