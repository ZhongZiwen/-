//
//  AddToMessageSelectedController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/11/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AddToMessageSelectedType) {
    AddToMessageSelectedTypeLead,
    AddToMessageSelectedTypeCustomer
};

@interface AddToMessageSelectedController : UIViewController

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (assign, nonatomic) AddToMessageSelectedType selectedType;
@property (copy, nonatomic) void(^refleshBlock)(id);
@end
