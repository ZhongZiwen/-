//
//  XLTotalCell.h
//  shangketong
//  任务详情------评论列表
//  Created by 蒋 on 15/12/9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <XLForm/XLForm.h>
#import "TTTAttributedLabel.h"

extern NSString * const XLFormRowDescriptorTypeTotal;

@interface XLTotalCell : XLFormBaseCell

@property (strong, nonatomic) TTTAttributedLabel *contentLabel;
@end
