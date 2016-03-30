//
//  CampaignCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-6-13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
@class Campaign;

@interface CampaignCell : SWTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelStatus;



-(void)setCellFrame;
-(void)setCellDetails:(Campaign *)item;
///设置左滑按钮
-(void)setLeftAndRightBtn:(Campaign *)item;

@end
