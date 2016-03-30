//
//  ActivityHeaderView.h
//  shangketong
//
//  Created by sungoin-zbs on 16/1/5.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailModel;

@interface ActivityHeaderView : UIImageView

+ (instancetype)activityHeaderViewWithModel:(DetailModel*)item image:(UIImage*)image;
@end
