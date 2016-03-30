//
//  FilterViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/17.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterValue, AddressBook;

@interface FilterViewCell : UITableViewCell

- (void)configWithSearchType:(NSInteger)type model:(FilterValue*)model row:(NSInteger)row;
// 选择员工
- (void)configWithModel:(AddressBook*)addressBook;
@end
