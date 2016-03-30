//
//  ExportAddress.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/29.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XLForm.h>

@interface ExportAddress : NSObject<XLFormOptionObject>

@property (strong, nonatomic) NSMutableArray *selectedArray;

+ (instancetype)initWithArray:(NSMutableArray*)array;
- (instancetype)initWithArray:(NSMutableArray*)array;
@end
