//
//  CustomNavigationView.h
//  shangketong
//
//  Created by sungoin-zbs on 16/3/9.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomNavigationView : UIView

@property (copy, nonatomic) NSString *titleString;
@property (copy, nonatomic) void (^backButtonClickedBlock) (void);
@property (copy, nonatomic) void (^rightButtonClickedBlock) (void);

- (void)startAnimation;
- (void)stopAnimation;
@end
