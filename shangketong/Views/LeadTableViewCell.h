//
//  LeadTableViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SWTableViewCell.h"

@class Lead;

@interface LeadTableViewCell : SWTableViewCell

+ (CGFloat)cellHeight;
- (void)configWithModel:(Lead*)item;
@end
