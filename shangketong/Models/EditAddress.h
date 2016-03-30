//
//  EditAddress.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XLForm.h>

@interface EditAddress : NSObject<XLFormOptionObject>

@property (strong, nonatomic) NSMutableArray *sourceArray;

+ (instancetype)initWithArray:(NSMutableArray*)array;
- (instancetype)initWithArray:(NSMutableArray*)array;
@end
