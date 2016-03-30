//
//  ChatTableViewCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatMessage;

@interface ChatTableViewCell : UITableViewCell

@property (nonatomic, copy) void(^headImageViewClickBlock) (NSString *);

@property (nonatomic, copy) void(^BackVoiceUrlBlock)();

@property (nonatomic, copy) void(^BackMessageIdBlock)(ChatMessage *msgModel);
+ (CGFloat)cellHeightWithObject:(ChatMessage*)chatMsg withIsShow:(NSString *)showSting;
- (void)configWithObject:(ChatMessage*)chatMsg withType:(NSString *)type withIsShow:(NSString *)showSting;  //delete删除   normal正常状态

@property (nonatomic, strong) UIImageView *voiceIcon;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, assign) NSInteger index;

// ChatMessageTypeImage
@property (nonatomic, strong) UIImageView *contentImageView;

@end
