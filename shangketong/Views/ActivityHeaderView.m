//
//  ActivityHeaderView.m
//  shangketong
//
//  Created by sungoin-zbs on 16/1/5.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import "ActivityHeaderView.h"

@implementation ActivityHeaderView

+ (instancetype)activityHeaderViewWithModel:(DetailModel *)item image:(UIImage *)image {
    if (!item || !image) {
        return nil;
    }
    
    ActivityHeaderView *headerView = [[ActivityHeaderView alloc] init];
    
    return headerView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
