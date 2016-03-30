//
//  CommonLoginEvent.h
//  shangketong
//  session失效时默认登录
//  Created by sungoin-zjp on 15-8-26.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonLoginEvent : NSObject

///重新登录
- (void)loginInBackground;

///重新登录 LLC
-(void)loginInBackgroundLLC;

///登录成功之后重新请求
@property (nonatomic, copy) void (^RequestAgainBlock)(void);

@end
