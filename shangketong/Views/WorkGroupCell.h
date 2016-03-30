//
//  WorkGroupCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-5-21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WorkGroupDelegate;

@interface WorkGroupCell : UITableViewCell
@property (assign, nonatomic) id <WorkGroupDelegate>delegate;
@end


//
@protocol WorkGroupDelegate<NSObject>
@required

///点击头像事件
- (void)clickUserIconEvent:(NSInteger)section;
///点击右上角菜单事件 （收藏、 删除、 举报）
- (void)clickRightMenuEvent:(NSInteger)section;
///点击地址事件
- (void)clickAddressEvent:(NSInteger)section;
///点击文件事件
- (void)clickFileEvent:(NSInteger)section;
///点击语音事件
- (void)clickVoiceDataEvent:(NSInteger)section;
///展开全部/收起事件
- (void)clickExpContentEvent:(NSInteger)section;
///点击转发事件
- (void)clickRepostEvent:(NSInteger)section;
///点击评论事件
- (void)clickReviewEvent:(NSInteger)section;
///点击赞事件
- (void)clickPraiseEvent:(NSInteger)section;
///点击content中@字符等事件  http  #
-(void)clickContentCharType:(NSString *)type content:(NSString *)content atIndex:(NSIndexPath *)index;

///点击来自XXX事件
- (void)clickFromEvent:(NSInteger)section;

///点击转发view区域
- (void)clickRepostViewEvent:(NSInteger)section;

///点击图片事件
///section 对应当前cell在列表中的行下标
///row  对应当前图片在cell中的下标
- (void)clickImageViewEvent:(NSIndexPath *)imgIndexPath;

@end