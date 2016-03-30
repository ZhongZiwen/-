//
//  ExportBottomTableViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/5/7.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddressBook;

@interface ExportBottomTableViewCell : UITableViewCell

+ (CGFloat)cellHeight;
- (void)configWithModel:(AddressBook*)model;
@end
