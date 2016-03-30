//
//  PopupView.m
//  LewPopupViewController
//
//  Created by deng on 15/3/5.
//  Copyright (c) 2015年 pljhonglu. All rights reserved.
//

#import "PopupView.h"
#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationSpring.h"
#import "VictoryViewController.h"

@implementation PopupView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil];
        _innerView.frame = frame;
        _innerView.layer.cornerRadius = 3;
        [self addSubview:_innerView];
    }
    return self;
}


+ (instancetype)defaultPopupView{
    return [[PopupView alloc]initWithFrame:CGRectMake(0, 0, 195, 230)];
}

- (IBAction)dismissAction:(id)sender{
    appDelegateAccessor.moudle.isVictoryShowAlready = NO;
    [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationSpring new]];
}


- (IBAction)dismissViewSpringAction:(id)sender{
    appDelegateAccessor.moudle.isVictoryShowAlready = NO;
    [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationSpring new]];
    
    VictoryViewController *controller = [[VictoryViewController alloc] init];
    controller.title = @"当天签单";
    controller.strStartDate = @"";
    controller.strEndDate = @"";
    controller.hidesBottomBarWhenPushed = YES;
    
    [appDelegateAccessor.moudle.controllerCurView.navigationController pushViewController:controller animated:YES];
}


@end
