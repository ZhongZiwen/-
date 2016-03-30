//
//  SKTSelectMemberPreController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKTSelectMemberPreController : UIViewController

@property (nonatomic, strong) NSMutableArray *sourceArray;
@property (nonatomic, copy) void(^valueBlock) (NSMutableArray *valueArray);
@end
