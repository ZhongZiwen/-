//
//  ADTitleImagesCell.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/5/30.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADTitleImagesCell : UITableViewCell

+ (CGFloat)cellHeightWithCopysCount:(NSInteger)count;
- (void)configWithCopysArray:(NSArray*)copys;
@end
