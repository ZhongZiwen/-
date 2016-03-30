//
//  KnowledgeDirectorieCell.h
//  shangketong
//
//  Created by sungoin-zjp on 15-5-27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KnowledgeDirectorieCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelCount;
@property (strong, nonatomic) IBOutlet UIImageView *imgArrow;



///设置frame
-(void)setCellFrame;
///填充详情
-(void)setContentDetails:(NSDictionary *)item;

@end
