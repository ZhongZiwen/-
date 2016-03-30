//
//  SKTCondition.h
//  shangketong
//
//  Created by sungoin-zbs on 15/8/21.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKTFilterValue, SKTIndexPath;

@interface SKTCondition : NSObject<NSCoding>

@property (nonatomic, copy) NSString *m_itemId;
@property (nonatomic, copy) NSString *m_itemName;
@property (nonatomic, assign) NSInteger m_itemType;
@property (nonatomic, copy) NSString *m_name;
@property (nonatomic, copy) NSString *m_icon;
@property (nonatomic, copy) NSString *m_id;
@property (nonatomic, strong) SKTIndexPath *indexPath;
@property (nonatomic, strong) SKTFilterValue *titleValue;

+ (SKTCondition*)initWithItemId:(NSString*)itemId andItemName:(NSString*)itemName andType:(NSInteger)searchType andValue:(SKTFilterValue*)filterValue;
- (SKTCondition*)initWithItemId:(NSString*)itemId andItemName:(NSString*)itemName andType:(NSInteger)searchType andValue:(SKTFilterValue*)filterValue;
@end
