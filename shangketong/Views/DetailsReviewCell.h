//
//  DetailsReviewCell.h
//  shangketong
//  评论操作内容
//  Created by sungoin-zjp on 15-6-10.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkGroupCell.h"
#import "TTTAttributedLabel.h"

@interface DetailsReviewCell : WorkGroupCell


///抬头日期
@property (weak, nonatomic) IBOutlet UIView *viewDate;
@property (weak, nonatomic) IBOutlet UIImageView *imgLineTop;
@property (weak, nonatomic) IBOutlet UIButton *btnDate;



///背景view
@property (strong, nonatomic) IBOutlet UIView *viewBg;
///背景img
@property (strong, nonatomic) IBOutlet UIImageView *imgBg;


///类型图标
@property (strong, nonatomic) IBOutlet UIImageView *imgActivityFeedIcon;
///来自XXX
@property (strong, nonatomic) IBOutlet UILabel *labelBelongName;
///日期
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
///分割线
@property (strong, nonatomic) IBOutlet UIImageView *imgLine;


///头像
@property (strong, nonatomic) IBOutlet UIButton *btnIcon;
///姓名
@property (strong, nonatomic) IBOutlet UILabel *labelName;
///正文
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *labelContent;

//@property(strong,nonatomic)IBOutlet UILabel *labelContent;

///评论个数
@property (strong, nonatomic) IBOutlet UIButton *btnReviewCount;
///cell之间的分割线（竖向）
@property (strong, nonatomic) IBOutlet UIImageView *imgCellSplit;



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


///语音信息
@property (weak, nonatomic) IBOutlet UIView *viewVoice;
@property (weak, nonatomic) IBOutlet UIButton *btnVoice;
@property (weak, nonatomic) IBOutlet UIImageView *imgVoice;
@property (weak, nonatomic) IBOutlet UILabel *labelVoiceDuration;

///文件信息
@property (weak, nonatomic) IBOutlet UIView *viewFile;
///btn  用以点击事件
@property (weak, nonatomic) IBOutlet UIButton *btnFile;
@property (weak, nonatomic) IBOutlet UIImageView *imgFileBg;

///文件图标
@property (weak, nonatomic) IBOutlet UIImageView *imgFileIcon;
///文件名称
@property (weak, nonatomic) IBOutlet UILabel *labelFileName;


///底部任务view （该任务由.....）
@property (weak, nonatomic) IBOutlet UIView *viewTask;
@property (weak, nonatomic) IBOutlet UIImageView *imgTaskLine;
///内容
@property (weak, nonatomic) IBOutlet UILabel *labelTaskContent;
///该任务于2015-07-01 19：00由张彬 创建
@property (weak, nonatomic) IBOutlet UILabel *labelTaskMarkInfo;


-(void)setCellDetails:(NSDictionary *)preItem andCurItem:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;
+(CGFloat)getCellContentHeight:(NSDictionary *)preItem andCurItem:(NSDictionary *)item  indexPath:(NSIndexPath *)indexPath;;
-(void)setImageAddGestureEventForImageView:(NSDictionary *)item withIndex:(NSIndexPath *)index;
///cell里控件添加事件
-(void)addClickEventForCellView:(NSIndexPath *)index;


@end
