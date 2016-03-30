//
//  PoolGroupTableViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PoolGroupTableViewCell : UITableViewCell

@property (strong, nonatomic) UIButton *receiveBtn;
@property (copy, nonatomic) void (^receiveBtnClickedBlock) (NSInteger);

- (void)configWithObj:(id)obj;
@end
