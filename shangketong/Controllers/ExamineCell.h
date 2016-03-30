//
//  ExamineCell.h
//  shangketong
//
//  Created by 蒋 on 15/9/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExamineCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;

- (void)initWithDictionary:(NSDictionary *)dict;
- (void)setFrameForAllPhones;
@end
