//
//  EditItemModel.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-9-10.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditItemModel : NSObject

@property(nonatomic,strong) NSString *itemId;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *content;
@property(nonatomic,strong) NSString *placeholder;
@property(nonatomic,strong) NSString *cellType;
@property(nonatomic,strong) NSString *keyStr;
@property(nonatomic,strong) NSString *keyType;
///是否可编辑
@property(nonatomic,strong) NSString *enabled;
///标识
@property(nonatomic,strong) NSString *itemTag;

- (NSDictionary *) encodedEditItemModel;
@end
