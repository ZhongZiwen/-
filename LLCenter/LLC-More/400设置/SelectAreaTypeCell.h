//
//  SelectAreaTypeCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-27.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectAreaTypeCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIButton *btnCheckBox;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIImageView *imgArrow;


@property (strong, nonatomic) IBOutlet UILabel *labelInfos;



///type  1地区  2时间
-(void)setCellFrame:(NSInteger)type;
-(void)setCellDetail:(NSDictionary *)item;

@end
