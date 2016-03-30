//
//  MenuSettingCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/23.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SwitchValueChange) (BOOL isShow);
@interface MenuSettingCell : UITableViewCell

@property (nonatomic, strong) UISwitch *m_switch;

+ (CGFloat)cellHeight;
- (void)setImageView:(NSString*)imageStr titleLabel:(NSString*)titleStr switchValue:(BOOL)value;
@end
