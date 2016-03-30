//
//  UIViewController+NavDropMenu.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavDropView.h"

@interface UIViewController (NavDropMenu)

- (void)customDownMenuWithType:(TableViewCellType)type andSource:(NSArray*)sourceArray andDefaultIndex:(NSInteger)index andBlock:(void (^)(NSInteger index))block;
@end
