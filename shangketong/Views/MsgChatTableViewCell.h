//
//  MsgChatTableViewCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ConversationListModel;

@interface MsgChatTableViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *m_detailLabel;

+ (CGFloat)cellHeight;
- (void)configWithModel:(ConversationListModel *)model;
@end
