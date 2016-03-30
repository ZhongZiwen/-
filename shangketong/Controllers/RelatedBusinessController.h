//
//  RelatedBusinessController.h
//  shangketong
//
//  Created by 蒋 on 15/12/12.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RelatedBusinessController : UITableViewController

///用来标记是不是审批模块的 'approval'
@property(nonatomic,strong) NSString  *flagOfRelevance;
@property(nonatomic,strong) NSString  *businessCode;

@end
