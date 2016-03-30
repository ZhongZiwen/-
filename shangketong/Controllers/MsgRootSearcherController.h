//
//  MsgRootSearcherController.h
//  shangketong
//
//  Created by 蒋 on 15/12/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgRootSearcherController : BaseViewController
@property (nonatomic, strong) NSArray *dataSourceArray;
@property (nonatomic, copy) void(^BlackOneGroupIdBlock)(NSString *group);
@end
