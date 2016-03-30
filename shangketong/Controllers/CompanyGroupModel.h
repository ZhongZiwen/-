//
//  CompanyGroupModel.h
//  shangketong
//
//  Created by 蒋 on 15/10/16.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ContactModel;
@interface CompanyGroupModel : NSObject
@property (nonatomic, strong) NSString *group_name;
@property (nonatomic, strong) NSString *group_id;
@property (nonatomic, strong) NSString *group_images;
@property (nonatomic, assign) BOOL isHasChildren; //0有  1没有

@property (nonatomic, assign) NSInteger sectionNum;
@property (nonatomic, assign) NSInteger originIndex;

@property (nonatomic, strong) NSMutableArray *contactModelArray;

- (CompanyGroupModel *)initWithDictionary:(NSDictionary *)dict;
+ (CompanyGroupModel *)initWithDictionary:(NSDictionary *)dict;

- (NSString *)getFirstName;
- (NSString *)getLastName;
@end
