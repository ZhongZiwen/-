//
//  PresentItem.h
//  MenuDemo
//
//  Created by sungoin-zbs on 15/6/15.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PresentItem : NSObject

@property (nonatomic, copy) NSString *m_title;
@property (nonatomic, assign) BOOL isSelected;  // 默认为no，用以表示选中或非选中

+ (PresentItem*)initWithTitle:(NSString*)titleStr;
- (PresentItem*)initWithTitle:(NSString*)titleStr;
@end
