//
//  AddressBookBaseController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/12/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressBook.h"
#import "AddressBookGroup.h"
#import "BaseViewController.h"

@interface AddressBookBaseController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISearchBar *mSearchBar;
@property (strong, nonatomic) UISearchDisplayController *mSearchDisplayController;
@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSMutableArray *groupsArray;      // 保存分组后的数据
@property (strong, nonatomic) NSMutableArray *searchResults;    // 保存搜索后的数据

- (void)sendRequest;
- (void)groupingDataSourceFrom:(NSMutableArray*)fromArray to:(NSMutableArray*)toArray;
- (void)sortForArray:(NSMutableArray*)array;
@end
