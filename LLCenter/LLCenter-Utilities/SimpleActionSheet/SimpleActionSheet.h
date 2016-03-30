//
//  SimpleActionSheet.h
//  lianluozhongxin
//
//  Created by Vescky on 14-7-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SimpleActionSheetDelegate <NSObject>

- (void)buttonDidClickedAtIndex:(int)index;

@end

@interface SimpleActionSheet : UIView {
    NSArray *buttonsTitle;
    NSString *alertDescription;
    UIView *maskView;
}

@property (nonatomic,assign) id <SimpleActionSheetDelegate> delegate;

- (void)setButtonsTitle:(NSArray*)arr;
- (void)setAlertDescription:(NSString*)str;
- (void)showOnWindow:(UIWindow*)w;

@end
