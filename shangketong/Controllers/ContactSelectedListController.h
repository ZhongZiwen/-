//
//  ContactSelectedListController.h
//  shangketong
//
//  Created by sungoin-zbs on 16/1/5.
//  Copyright © 2016年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactSelectedListController : UIViewController

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (copy, nonatomic) void(^refreshBlock)(id);
@end
