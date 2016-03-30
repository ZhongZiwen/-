//
//  MsgRootSearchCell.h
//  shangketong
//  IM首页搜索----->聊天记录
//  Created by 蒋 on 15/11/20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgRootSearchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;

//1有  0没有
- (void)configWithDict:(NSArray *)array withIsMore:(NSString *)moreString;
//更多结果使用
- (void)configWithDict:(NSDictionary *)dict;
- (void)setFrameForAlliPhone;
@end
