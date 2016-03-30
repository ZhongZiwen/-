//
//  RecordSendImagesCell.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/27.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Record.h"

@interface RecordSendImagesCell : UITableViewCell

@property (copy, nonatomic) void(^addImageBlock)(void);
@property (copy, nonatomic) void(^tapImageBlock)(NSInteger row);

+ (CGFloat)cellHeightWithObj:(id)obj;
- (void)configWithRecord:(NSArray*)array;
@end
