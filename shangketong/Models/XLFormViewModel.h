//
//  XLFormViewModel.h
//  shangketong
//
//  Created by sungoin-zbs on 15/9/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XLFormDescriptor, XLFormRowDescriptor;

@interface XLFormViewModel : NSObject

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableArray *moreColumns;
@property (strong, nonatomic) XLFormDescriptor *formDescriptor;
@property (strong, nonatomic) NSNumber *customerId;
@property (copy, nonatomic) void(^deselectBlock)(XLFormRowDescriptor*);

- (instancetype)initWithSourceArray:(NSMutableArray*)array moreColumsArray:(NSMutableArray*)moreArray;
- (void)refreshForm;
- (NSString*)jsonString;
@end
