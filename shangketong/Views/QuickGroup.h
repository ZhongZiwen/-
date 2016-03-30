//
//  QuickGroup.h
//  shangketong
//
//  Created by sungoin-zbs on 15/7/13.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuickGroup : NSObject

@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, strong) NSMutableArray *quickArray;

- (QuickGroup*)initWithName:(NSString*)groupName andQuickArray:(NSMutableArray*)quickArray;
+ (QuickGroup*)initWithName:(NSString*)groupName andQuickArray:(NSMutableArray*)quickArray;
@end
