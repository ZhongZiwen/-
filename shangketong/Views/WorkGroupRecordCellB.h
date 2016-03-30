//
//  WorkGroupRecordCellB.h
//  shangketong
//  主动发布  转发等可操作
//  Created by sungoin-zjp on 15-6-11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "WorkGroupCell.h"
#import "TTTAttributedLabel.h"

@interface WorkGroupRecordCellB : WorkGroupCell

///------------------头像部分UI------------------------///
///头像
@property (strong, nonatomic) IBOutlet UIButton *btnIcon;
///名字
@property (strong, nonatomic) IBOutlet UILabel *labelName;

///当前动态所属行为（如  >拜访签到）
@property (strong, nonatomic) IBOutlet UIView *viewAction;
@property (strong, nonatomic) IBOutlet UIImageView *imgActionIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelActionName;

///日期
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
///来自XXX
@property (strong, nonatomic) IBOutlet UIButton *btnFrom;
///菜单按钮  收藏/举报
@property (strong, nonatomic) IBOutlet UIButton *btnMenu;


///-------------------内容正文-----------------------///
#pragma mark - 当前内容

///赢单图标
@property (strong, nonatomic) IBOutlet UIImageView *imgPraiseIcon;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *labelContent;
///展开或收起
@property (strong, nonatomic) IBOutlet UIButton *btnExpContent;


///-------------------博文-----------------------///
@property (weak, nonatomic) IBOutlet UIView *viewBlog;
@property (weak, nonatomic) IBOutlet UILabel *labelBlogTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelBlogContent;
@property (weak, nonatomic) IBOutlet UIButton *btnBlogExp;



///----------------------位置信息--------------------///
///地址信息
#pragma mark - 地址信息
@property (weak, nonatomic) IBOutlet UIView *viewAddress;

@property (weak, nonatomic) IBOutlet UIImageView *imgAddressBg;


///图标+地址信息
@property (weak, nonatomic) IBOutlet UIButton *btnAddress;
@property (weak, nonatomic) IBOutlet UIView *viewAddressContent;
///图标
@property (weak, nonatomic) IBOutlet UIImageView *imgMapIcon;
///地址1
@property (weak, nonatomic) IBOutlet UILabel *labelAddress;
///地址2
@property (weak, nonatomic) IBOutlet UILabel *labelAddressStreet;

///----------------------任务信息-------------------///
#pragma mark - 由XXX完成

@property (strong, nonatomic) IBOutlet UILabel *labelTaskContent;


///由XXX完成
@property (strong, nonatomic) IBOutlet UILabel *labelFinishBy;


///----------------------文件信息-------------------///
#pragma mark - 文件信息

@property (weak, nonatomic) IBOutlet UIView *viewFile;

@property (weak, nonatomic) IBOutlet UIImageView *imgFileBg;

///文件图标
@property (weak, nonatomic) IBOutlet UIImageView *imgFileIcon;
///文件名称
@property (weak, nonatomic) IBOutlet UILabel *labelFileName;


///语音信息
@property (weak, nonatomic) IBOutlet UIView *viewVoice;
@property (weak, nonatomic) IBOutlet UIButton *btnVoice;
@property (weak, nonatomic) IBOutlet UIImageView *imgVoice;
@property (weak, nonatomic) IBOutlet UILabel *labelVoiceDuration;


///----------------------图片信息-------------------///
#pragma mark - 图片
@property (weak, nonatomic) IBOutlet UIView *viewImage;
@property (weak, nonatomic) IBOutlet UIImageView *img1;
@property (weak, nonatomic) IBOutlet UIImageView *img2;
@property (weak, nonatomic) IBOutlet UIImageView *img3;
@property (weak, nonatomic) IBOutlet UIImageView *img4;
@property (weak, nonatomic) IBOutlet UIImageView *img5;
@property (weak, nonatomic) IBOutlet UIImageView *img6;
@property (weak, nonatomic) IBOutlet UIImageView *img7;
@property (weak, nonatomic) IBOutlet UIImageView *img8;
@property (weak, nonatomic) IBOutlet UIImageView *img9;

///----------------------底部选项信息-------------------///
#pragma mark - 底部选项（评论、转发、赞）
///底部选项（转发、评论、赞）
@property (strong, nonatomic) IBOutlet UIView *viewOptions;
///转发
@property (strong, nonatomic) IBOutlet UIButton *btnRepost;
///评论
@property (strong, nonatomic) IBOutlet UIButton *btnReview;
///赞
@property (strong, nonatomic) IBOutlet UIButton *btnPraise;

///----------------------详情时显示-------------------///
#pragma mark - 评论数  详情时显示
///评论数  详情时显示
@property (strong, nonatomic) IBOutlet UILabel *labelReviewCount;

///----------------------转发view-------------------///

#pragma mark - 转发view
///转发view
@property (weak, nonatomic) IBOutlet UIView *viewRepost;
@property (weak, nonatomic) IBOutlet UIView *viewRepostBg;
@property (weak, nonatomic) IBOutlet UIImageView *imgRepostBg;
@property (weak, nonatomic) IBOutlet UIImageView *imgRepostArrow;



///转发name
@property (weak, nonatomic) IBOutlet UILabel *labelRepostName;

///转发动态所属行为（如  >拜访签到）
@property (weak, nonatomic) IBOutlet UIView *viewRepostAction;
@property (weak, nonatomic) IBOutlet UIImageView *imgRepostActionIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelRepostActionName;

///转发content
@property (weak, nonatomic) IBOutlet UILabel *lableRepostContent;


@property (weak, nonatomic) IBOutlet UIButton *btnRepostPriase;
@property (weak, nonatomic) IBOutlet UIButton *btnRepostReview;



#pragma mark - 转发图片
@property (weak, nonatomic) IBOutlet UIView *repostViewImage;
@property (weak, nonatomic) IBOutlet UIImageView *repostImg1;
@property (weak, nonatomic) IBOutlet UIImageView *repostImg2;
@property (weak, nonatomic) IBOutlet UIImageView *repostImg3;
@property (weak, nonatomic) IBOutlet UIImageView *repostImg4;
@property (weak, nonatomic) IBOutlet UIImageView *repostImg5;
@property (weak, nonatomic) IBOutlet UIImageView *repostImg6;
@property (weak, nonatomic) IBOutlet UIImageView *repostImg7;
@property (weak, nonatomic) IBOutlet UIImageView *repostImg8;
@property (weak, nonatomic) IBOutlet UIImageView *repostImg9;


///消息-@提到我的评论消息
@property (weak, nonatomic) IBOutlet UIView *viewCommentSource;
@property (weak, nonatomic) IBOutlet UIImageView *imgIconSource;
@property (weak, nonatomic) IBOutlet UILabel *labelNameSource;
@property (weak, nonatomic) IBOutlet UILabel *labelContentSource;



///填充详情
///填充详情
-(void)setContentDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath byCellStatus:(WorkGroupTypeStatus)cellStatus;
///获取height
+(CGFloat)getCellContentHeight:(NSDictionary *)item byCellStatus:(WorkGroupTypeStatus)cellStatus;

#pragma mark - imageview填充图片并添加点击手势
-(void)setImageAddGestureEventForImageView:(NSDictionary *)item withIndex:(NSIndexPath *)index;

#pragma mark - cell中相关事件
///cell里控件添加事件
-(void)addClickEventForCellView:(NSDictionary *)item withIndex:(NSIndexPath *)index;

@end
