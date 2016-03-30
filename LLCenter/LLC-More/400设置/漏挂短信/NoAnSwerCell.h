//
//  NoAnSwerCell.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-14.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoAnSwerCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIButton *btnSelectIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelMsgContent;


-(void)setCellDetails:(NSDictionary *)item;
+(CGFloat)getCellHeight:(NSDictionary *)item;

@end
