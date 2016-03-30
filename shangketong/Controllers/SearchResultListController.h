//
//  SearchResultListController.h
//  shangketong
//
//  Created by sungoin-zbs on 15/10/25.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchViewController.h"

@interface SearchResultListController : UIViewController

@property (assign, nonatomic) SearchViewControllerType searchType;
@property (copy, nonatomic) NSString *requestPath;
@property (copy, nonatomic) NSString *searchName;
@end
