//
//  ContactTableViewCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/14.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "SWTableViewCell.h"

@class Contact;

@interface ContactTableViewCell : SWTableViewCell

+ (CGFloat)cellHeight;
- (void)configWithModel:(Contact*)item;
- (void)configWithoutSWWithItem:(Contact*)item;
@end
