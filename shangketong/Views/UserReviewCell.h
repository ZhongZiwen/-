//
//  UserReviewCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-5-25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@protocol UserReviewDelegate;

@interface UserReviewCell : UITableViewCell

@property (assign, nonatomic) id <UserReviewDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIButton *btnIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
//@property (strong, nonatomic) IBOutlet UILabel *labelContent;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *labelContent;
@property (strong, nonatomic) IBOutlet UIImageView *imgLine;



///填充详情
-(void)setContentDetails:(NSDictionary *)item;
///type 类型
+(CGFloat)getCellContentHeight:(NSDictionary *)item;
///cell里控件添加事件
-(void)addClickEventForCellView:(NSIndexPath *)index;
@end



@protocol UserReviewDelegate<NSObject>
@required

///点击头像事件
- (void)clickUserReviewIconEvent:(NSInteger)section;
///点击content中@字符等事件  http  #
-(void)clickReviewContentCharType:(NSString *)type content:(NSString *)content atIndex:(NSIndexPath *)index;


@end
