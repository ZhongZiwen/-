//
//  ActivityRecordFileView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/18.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityRecordFileView : UIView

@property (copy, nonatomic) void(^fileBtnClickBlock)(id);

- (void)configWithObj:(id)obj;
@end
