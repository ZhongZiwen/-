//
//  UIViewController+NavDropMenu.m
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "UIViewController+NavDropMenu.h"

@implementation UIViewController (NavDropMenu)

- (void)customDownMenuWithType:(TableViewCellType)type andSource:(NSArray *)sourceArray andDefaultIndex:(NSInteger)index andBlock:(void (^)(NSInteger))block {
    
    NavDropView *dropView = [[NavDropView alloc] initWithFrame:CGRectMake(0, 0, 200, 30) andType:type andSource:sourceArray andDefaultIndex:index andController:self];
    dropView.menuIndexClick = block;
    self.navigationItem.titleView = dropView;
}
@end
