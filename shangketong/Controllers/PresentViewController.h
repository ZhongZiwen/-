//
//  PresentViewController.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PresentItem;

@interface PresentViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, copy) void(^addBlock)(PresentItem*);
@property (nonatomic, copy) void(^deleteBlock)(PresentItem*);
@end
