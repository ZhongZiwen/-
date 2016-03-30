//
//  TodayScheuleCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-6-5.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TodayScheduleDetailDelegate;

@interface TodayScheuleCell : UITableViewCell

@property (assign, nonatomic) id <TodayScheduleDetailDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIImageView *imgFlag;
@property (strong, nonatomic) IBOutlet UILabel *labelDateArea;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelFrom;
@property (strong, nonatomic) IBOutlet UIButton *btnFlagIcon;
@property (strong, nonatomic) IBOutlet UIImageView *imgExpIcon;
@property (strong, nonatomic) IBOutlet UIButton *btnGoDetails;


-(void)setCellFrame;
-(void)setCellFrameByType:(NSInteger)type;
-(void)setCellContentDetails:(NSDictionary *)item indexPath:(NSIndexPath *)indexPath;

@end


@protocol TodayScheduleDetailDelegate<NSObject>
@required

///详情
- (void)clickDetailsEvent:(NSInteger)index;

@end
