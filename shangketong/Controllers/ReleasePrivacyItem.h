//
//  ReleasePrivacyItem.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReleasePrivacyItem : NSObject

@property (nonatomic, readwrite) NSInteger indexRow;
@property (nonatomic, copy) NSString *privacyString;
@property (nonatomic, assign) long long selectedId;

- (ReleasePrivacyItem*)initWithIndex:(NSInteger)index andTitle:(NSString*)string;
+ (ReleasePrivacyItem*)initWithIndex:(NSInteger)index andTitle:(NSString*)string;
@end
