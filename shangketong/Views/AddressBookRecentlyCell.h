//
//  AddressBookRecentlyCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressBookRecentlyCell : UITableViewCell

@property (copy, nonatomic) void(^iconViewTapBlock)(AddressBook*);

+ (CGFloat)cellHeight;
- (void)configWithArray:(NSArray*)array;
@end
