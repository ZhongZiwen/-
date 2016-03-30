//
//  ArrayDataSource.h
//  shangketong
//
//  Created by sungoin-zbs on 15/4/28.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TableViewCellConfigureBlock) (id cell, id item);

@interface ArrayDataSource : NSObject<UITableViewDataSource>

- (id)initWithDataSource:(NSArray*)dataSource cellIdentifier:(NSString*)kCellIdentifier configureCellBlock:(TableViewCellConfigureBlock)block;

- (id)itemAtIndexPath:(NSIndexPath*)indexPath;
@end
