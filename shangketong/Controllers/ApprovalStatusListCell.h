//
//  ApprovalStatusListCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/6.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApprovalStatusListCell : UITableViewCell

+ (CGFloat)cellHeightWithDictionary:(NSDictionary*)dict;
- (void)configWithDictionary:(NSDictionary*)dict;
@end
