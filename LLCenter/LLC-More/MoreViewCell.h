//
//  MoreViewCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 14-12-11.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;

@property (strong, nonatomic) IBOutlet UILabel *labelTitle;

@property (strong, nonatomic) IBOutlet UIImageView *imgArrow;

@property (strong, nonatomic) IBOutlet UIImageView *imgNoticeIcon;




-(void)setCellViewFrame;


@end
