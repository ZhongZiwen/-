//
//  ActivityRecHeaderView.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityRecHeaderView : UIView

@property (copy, nonatomic) void(^iconViewClickedBlock)(NSInteger tag);
@property (copy, nonatomic) void(^userMoreClickedBlock)(void);

- (void)configWithArray:(NSArray*)sourceArray showMoreButton:(BOOL)isShow;
@end
