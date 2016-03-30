//
//  OpportunityContactCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contact;

@interface OpportunityContactCell : UITableViewCell

@property (copy, nonatomic) void(^phoneBtnClickedBlock)(void);

+ (CGFloat)cellHeight;
- (void)configWithItem:(Contact*)item;
@end
