//
//  AddToMessageController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, AddToMessageType) {
    AddToMessageTypeLead,
    AddToMessageTypeCustomer
};



@interface AddToMessageController : BaseViewController

@property (strong, nonatomic) NSNumber *activityId;
@property (assign, nonatomic) AddToMessageType addType;
@property (copy, nonatomic) void(^refreshBlock)(void);
@end
