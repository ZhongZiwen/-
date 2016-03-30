//
//  CommonModuleFuntion.m
//  shangketong
//
//  Created by sungoin-zjp on 15-6-24.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "CommonModuleFuntion.h"
#import "GBMoudle.h"
#import "CommonConstant.h"
#import "NSUserDefaults_Cache.h"
#import "FMDB_SKT_CACHE.h"
#import "AddressBook.h"
#import "Dynamic_Data.h"
#import "RootMenuModel.h"

@implementation CommonModuleFuntion



/**
 
  CRM 对活动成员操作类型
 
public final static int CRM_TYPE_ACTIVITY = 201;             //市场活动
public final static int CRM_TYPE_CLUE = 202;                 //销售线索
public final static int CRM_TYPE_CUSTOMER = 203;             //客户
public final static int CRM_TYPE_CONTRACT = 204;             //联系人
public final static int CRM_TYPE_OPPORTUNITY = 205;          //销售机会
public final static int CRM_TYPE_PACT = 206;                 //合同
public final static int CRM_TYPE_PRODUCT = 207;              //产品
public final static int CRM_TYPE_SALES_PRODUCT = 208;        //销售产品
public final static int CRM_TYPE_COMPETITOR = 209;           //竞争对手
public final static int CRM_TYPE_TARGET = 210;               //目标
public final static int CRM_TYPE_CLUE_POOL = 211;            //销售线索公海池
public final static int CRM_TYPE_CUSTOMER_POOL = 212;        //客户公海池
 
 */

#pragma mark - 市场活动 - statusNames 获取状态名称
/*
 {
 "value": 1,
 "name": "已计划new"
 }
 */
+(NSString *)getCampaignStatusName:(NSInteger)status{
    NSString *statusName = @"";
    BOOL isFound = FALSE;
    NSInteger count = 0;
    if (appDelegateAccessor.moudle.arrayCampaignsStatusNames) {
        count = [appDelegateAccessor.moudle.arrayCampaignsStatusNames count];
    }
    for (int i=0; !isFound && i<count; i++) {
        if ([[[appDelegateAccessor.moudle.arrayCampaignsStatusNames objectAtIndex:i] objectForKey:@"value"] integerValue] == status) {
            statusName = [[appDelegateAccessor.moudle.arrayCampaignsStatusNames objectAtIndex:i] objectForKey:@"name"];
            isFound = TRUE;
        }
    }
    return statusName;
}

#pragma mark - 公海池 - statusNames 获取状态名称
+(NSString *)getHighSeaStatusName:(NSInteger)status{
    NSString *statusName = @"";
    BOOL isFound = FALSE;
    NSInteger count = 0;
    if (appDelegateAccessor.moudle.arrayHighSeaStatusStatusNames) {
        count = [appDelegateAccessor.moudle.arrayHighSeaStatusStatusNames count];
    }
    for (int i=0; !isFound && i<count; i++) {
        if ([[[appDelegateAccessor.moudle.arrayHighSeaStatusStatusNames objectAtIndex:i] objectForKey:@"value"] integerValue] == status) {
            statusName = [[appDelegateAccessor.moudle.arrayHighSeaStatusStatusNames objectAtIndex:i] objectForKey:@"name"];
            isFound = TRUE;
        }
    }
    return statusName;
}


#pragma mark - 销售线索 - statusNames 获取状态名称
+(NSString *)getSaleLeadStatusName:(NSInteger)status{
    NSString *statusName = @"";
    BOOL isFound = FALSE;
    NSInteger count = 0;
    if (appDelegateAccessor.moudle.arraySaleLeadtatusStatusNames) {
        count = [appDelegateAccessor.moudle.arraySaleLeadtatusStatusNames count];
    }
    for (int i=0; !isFound && i<count; i++) {
        if ([[[appDelegateAccessor.moudle.arraySaleLeadtatusStatusNames objectAtIndex:i] objectForKey:@"value"] integerValue] == status) {
            statusName = [[appDelegateAccessor.moudle.arraySaleLeadtatusStatusNames objectAtIndex:i] objectForKey:@"name"];
            isFound = TRUE;
        }
    }
    return statusName;
}

#pragma mark - 根据 type system action 获取信息

/*
 type : 1，system : 1001：创建了客户（系统生成）[action : 1]
  type : 1，system : 1001：转移了客户（系统生成）[action : 4]
 type : 1，system : 1003：创建了联系人（系统生成）[action : 1]
 type : 1，system : 1003：删除了联系人（系统生成）[action : 3]
 type : 1，system : 1004：创建了销售机会（系统生成）[action : 1]
  type : 1，system : 1004：销售机会（系统生成）[action : 11]
 type : 1，system : 1005：创建了市场活动（系统生成）[action : 1]
  type : 1，system : 1010：删除了文件（系统生成）[action : 3]
  type : 1，system : 1011：添加了相关员工（系统生成）[action : 5]
 type : 1，system : 1011：移除了相关员工（系统生成）[action : 6]
  type : 1，system : 1012：创建了任务（系统生成）[action : 1]
  type : 1，system : 1012：重新启动了任务（系统生成）[action : 12]
 type : 1，system : 1016：创建了合同（系统生成）[action : 1]
 type : 1，system : 1017：创建了日程（系统生成）[action : 1]
 type : 1，system : 1019：添加了负责员工（系统生成）[action : 5]
 type : 1，system : 1019：移除了负责员工（系统生成）[action : 6]
 
 */
+(NSString *)getActionsNameByType:(NSInteger)type andSystem:(NSInteger)system andAction:(NSInteger)action{
    NSString *actionName = @"";
    
    if (type == 1) {
        if (system == 1001 && action == 1) {
            actionName = @"创建了客户";
        }else if (system == 1001 && action == 4) {
            actionName = @"转移了客户";
        }else if (system == 1003 && action == 1) {
            actionName = @"创建了联系人";
        }else if (system == 1003 && action == 3) {
            actionName = @"删除了联系人";
        }else if (system == 1004 && action == 1) {
            actionName = @"创建了销售机会";
        }else if (system == 1004 && action == 11) {
            actionName = @"销售机会";
        }else if (system == 1005 && action == 1) {
            actionName = @"创建了市场活动";
        }else if (system == 1010 && action == 3) {
            actionName = @"删除了文件";
        }else if (system == 1011 && action == 5) {
            actionName = @"添加了相关员工";
        }else if (system == 1011 && action == 6) {
            actionName = @"移除了相关员工";
        }else if (system == 1012 && action == 1) {
            actionName = @"创建了任务";
        }else if (system == 1012 && action == 12) {
            actionName = @"重新启动了任务";
        }else if (system == 1016 && action == 1) {
            actionName = @"创建了合同";
        }else if (system == 1017 && action == 1) {
            actionName = @"创建了日程";
        }else if (system == 1019 && action == 5) {
            actionName = @"添加了负责员工";
        }else if (system == 1019 && action == 6) {
            actionName = @"移除了负责员工";
        }
    }
    
    return actionName;
}


#pragma mark - 根据@姓名获取uid
+(long long)getUidByAtName:(NSString *)name fromAtList:(NSArray *)atList{
    long long uid = -1;
    NSInteger count = 0;
    if (atList) {
        count = [atList count];
    }
    for (int i=0; uid == -1 && i<count; i++) {
        if ([name isEqualToString:[[atList objectAtIndex:i] objectForKey:@"name"]]) {
            uid = [[[atList objectAtIndex:i] objectForKey:@"id"] longLongValue];
        }
    }
    return uid;
}


#pragma mark - 根据文件类型  获取其对应的图标名称
+(NSString *)getIconByFileType:(NSString *)filetype{
    NSString *icon = @"";
    
    
    
    return icon;
}


#pragma mark -根据用户选择  设置显示项(办公/CRM)
+(NSArray *)getOptionsModuleShow:(NSArray *)moduleOptions{
    //
    NSMutableDictionary *dicModuleOption = [[NSMutableDictionary alloc] init];
    
    NSInteger count = 0;
    if (moduleOptions) {
        count = [moduleOptions count];
    }
    
    RootMenuModel *item;
    for(int i=0; i< count; i++)
    {
        item = [moduleOptions objectAtIndex:i];
        ///显示
        if (item.menu_switch) {
            if ([dicModuleOption objectForKey:item.menu_group]) {
                NSMutableArray *arrNew = [[NSMutableArray alloc] initWithArray:[dicModuleOption objectForKey:item.menu_group]];
                [arrNew addObject:item];
                [dicModuleOption setObject:arrNew forKey:item.menu_group];
            }else
            {
                NSArray *arr = [[NSArray alloc] initWithObjects:item, nil];
                [dicModuleOption setObject:arr forKey:item.menu_group];
            }
        }
    }
    
    NSArray *allkey = [dicModuleOption allKeys];
    NSArray *resultAllkey = [allkey sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    NSMutableArray *arrayResult = [[NSMutableArray alloc] init];
    for (NSString *keys in resultAllkey) {
        [arrayResult addObject:[dicModuleOption objectForKey:keys]];
    }
    
//    NSLog(@"arrayResult:%@",arrayResult);
    return arrayResult;
}


#pragma mark- 初始化OA和CRM功能模块
+(void)initOAandCRMModuleOption{
    
    [self initOaModuleOption];
    [self initCRMModuleOption];
}

#pragma mark - 初始化OA模块选择
+(void)initOaModuleOption{
    NSArray *arrayOaOption = [NSUserDefaults_Cache getOAModuleOptions];
    ///做初始化操作
    if (arrayOaOption == nil || [arrayOaOption count] == 0) {
        
        //@{   @"image":@"menu_item_feed",
        ///@"title":@"工作圈",
        ///@"switch":@YES,
        ///@"group":@"groupA",
        ///@"eventIndex":@"1",
        ///@"unreadmsg",@"",
        ///@"tag","1"
        
        arrayOaOption = @[@{@"image":@"menu_item_feed", @"title":@"工作圈",@"switch":@YES,@"group":@"groupA",@"eventIndex":@"1",@"unreadmsg":@"0",@"tag":@"1"},
                                   @{@"image":@"menu_item_colleague", @"title":@"通讯录",@"switch":@YES,@"group":@"groupB",@"eventIndex":@"2",@"unreadmsg":@"0",@"tag":@"2"},
                                   @{@"image":@"menu_item_workreport", @"title":@"工作报告",@"switch":@YES,@"group":@"groupC",@"eventIndex":@"3",@"unreadmsg":@"0",@"tag":@"3"},
                                   @{@"image":@"menu_item_approval", @"title":@"审批",@"switch":@YES,@"group":@"groupC",@"eventIndex":@"4",@"unreadmsg":@"0",@"tag":@"4"},
                                   @{@"image":@"menu_item_schedule", @"title":@"日程",@"switch":@YES,@"group":@"groupD",@"eventIndex":@"5",@"unreadmsg":@"0",@"tag":@"5"},
                                   @{@"image":@"menu_item_task", @"title":@"任务",@"switch":@YES,@"group":@"groupD",@"eventIndex":@"6",@"unreadmsg":@"0",@"tag":@"6"},
                                   @{@"image":@"menu_item_rescenter", @"title":@"知识库",@"switch":@YES,@"group":@"groupE",@"eventIndex":@"7",@"unreadmsg":@"0",@"tag":@"7"}];
        
        /*
        NSMutableArray *arrModel = [[NSMutableArray alloc] init];
        
        for (int i=0; i<arrayOaOption.count; i++) {
            RootMenuModel *model = [RootMenuModel initWithDictionary:arrayOaOption[i]];
            [arrModel addObject:model];
        }
        */
        [NSUserDefaults_Cache setOAModuleOptions:arrayOaOption];
    }
}

#pragma mark - 初始化CRM模块选择
+(void)initCRMModuleOption{
    NSString *functionCodesString = appDelegateAccessor.moudle.userFunctionCodes;
    NSMutableArray *crmOptionsArray = [[NSMutableArray alloc] initWithCapacity:0];
    if ([functionCodesString rangeOfString:kCrm_activityList].location != NSNotFound) {
        [crmOptionsArray addObject:@{@"image":@"menu_item_campaign", @"title":@"市场活动",@"switch":@YES,@"group":@"groupB",@"eventIndex":@"2",@"unreadmsg":@"0",@"tag":@"2"}];
    }
    if ([functionCodesString rangeOfString:kCrm_leadPool].location != NSNotFound && !appDelegateAccessor.moudle.isOpen_cluePool) {
        [crmOptionsArray addObject:@{@"image":@"menu_item_leadHighsea", @"title":@"线索公海池",@"switch":@YES,@"group":@"groupC",@"eventIndex":@"3",@"unreadmsg":@"0",@"tag":@"3"}];
    }
    if ([functionCodesString rangeOfString:kCrm_leadList].location != NSNotFound) {
        [crmOptionsArray addObject:@{@"image":@"menu_item_lead", @"title":@"销售线索",@"switch":@YES,@"group":@"groupC",@"eventIndex":@"4",@"unreadmsg":@"0",@"tag":@"4"}];
    }
    if ([functionCodesString rangeOfString:kCrm_customerPool].location != NSNotFound && !appDelegateAccessor.moudle.isOpen_customerPool) {
        [crmOptionsArray addObject:@{@"image":@"menu_item_highsea", @"title":@"客户公海池",@"switch":@YES,@"group":@"groupC",@"eventIndex":@"5",@"unreadmsg":@"0",@"tag":@"5"}];
    }
    if ([functionCodesString rangeOfString:kCrm_customerList].location != NSNotFound) {
        [crmOptionsArray addObject:@{@"image":@"menu_item_account", @"title":@"客户",@"switch":@YES,@"group":@"groupC",@"eventIndex":@"6",@"unreadmsg":@"0",@"tag":@"6"}];
    }
    if ([functionCodesString rangeOfString:kCrm_contactList].location != NSNotFound) {
        [crmOptionsArray addObject:@{@"image":@"menu_item_contact", @"title":@"联系人",@"switch":@YES,@"group":@"groupC",@"eventIndex":@"7",@"unreadmsg":@"0",@"tag":@"7"}];
    }
    if ([functionCodesString rangeOfString:kCrm_chanceList].location != NSNotFound) {
        [crmOptionsArray addObject:@{@"image":@"menu_item_opportunity", @"title":@"销售机会",@"switch":@YES,@"group":@"groupD",@"eventIndex":@"8",@"unreadmsg":@"0",@"tag":@"8"}];
    }
    if ([functionCodesString rangeOfString:kCrm_productList].location != NSNotFound) {
        [crmOptionsArray addObject:@{@"image":@"menu_item_product", @"title":@"产品",@"switch":@YES,@"group":@"groupF",@"eventIndex":@"10",@"unreadmsg":@"0",@"tag":@"10"}];
    }
    [NSUserDefaults_Cache setCRMModuleOptions:crmOptionsArray];
    
//    NSArray *arrayCRMOption = [NSUserDefaults_Cache getCRMModuleOptions];
//    ///做初始化操作
//    if (arrayCRMOption == nil || [arrayCRMOption count] == 0) {
//        /*
//        arrayCRMOption = @[@{@"image":@"menu_item_analysis", @"title":@"仪表盘",@"switch":@YES,@"type":@"groupA",@"eventIndex":@"1"},
//                                   @{@"image":@"menu_item_campaign", @"title":@"市场活动",@"switch":@YES,@"type":@"groupB",@"eventIndex":@"2"},
//                                   @{@"image":@"menu_item_lead", @"title":@"线索公海池",@"switch":@YES,@"type":@"groupC",@"eventIndex":@"3"},
//                                     @{@"image":@"menu_item_lead", @"title":@"销售线索",@"switch":@YES,@"type":@"groupC",@"eventIndex":@"4"},
//                                     @{@"image":@"menu_item_account", @"title":@"客户公海池",@"switch":@YES,@"type":@"groupC",@"eventIndex":@"5"},
//                                     @{@"image":@"menu_item_account", @"title":@"客户",@"switch":@YES,@"type":@"groupC",@"eventIndex":@"6"},
//                                     @{@"image":@"menu_item_contact", @"title":@"联系人",@"switch":@YES,@"type":@"groupC",@"eventIndex":@"7"},
//                                   @{@"image":@"menu_item_opportunity", @"title":@"销售机会",@"switch":@YES,@"type":@"groupD",@"eventIndex":@"8"},
//                                   @{@"image":@"menu_item_activityRecord", @"title":@"活动记录",@"switch":@YES,@"type":@"groupE",@"eventIndex":@"9"},
//                                   @{@"image":@"menu_item_product", @"title":@"产品",@"switch":@YES,@"type":@"groupF",@"eventIndex":@"10"}];
//         */
//        
//        arrayCRMOption = @[@{@"image":@"menu_item_campaign", @"title":@"市场活动",@"switch":@YES,@"group":@"groupB",@"eventIndex":@"2",@"unreadmsg":@"0",@"tag":@"2"},
//                           @{@"image":@"menu_item_lead", @"title":@"线索公海池",@"switch":@YES,@"group":@"groupC",@"eventIndex":@"3",@"unreadmsg":@"0",@"tag":@"3"},
//                           @{@"image":@"menu_item_lead", @"title":@"销售线索",@"switch":@YES,@"group":@"groupC",@"eventIndex":@"4",@"unreadmsg":@"0",@"tag":@"4"},
//                           @{@"image":@"menu_item_account", @"title":@"客户公海池",@"switch":@YES,@"group":@"groupC",@"eventIndex":@"5",@"unreadmsg":@"0",@"tag":@"5"},
//                           @{@"image":@"menu_item_account", @"title":@"客户",@"switch":@YES,@"group":@"groupC",@"eventIndex":@"6",@"unreadmsg":@"0",@"tag":@"6"},
//                           @{@"image":@"menu_item_contact", @"title":@"联系人",@"switch":@YES,@"group":@"groupC",@"eventIndex":@"7",@"unreadmsg":@"0",@"tag":@"7"},
//                           @{@"image":@"menu_item_opportunity", @"title":@"销售机会",@"switch":@YES,@"group":@"groupD",@"eventIndex":@"8",@"unreadmsg":@"0",@"tag":@"8"},@{@"image":@"menu_item_product", @"title":@"产品",@"switch":@YES,@"group":@"groupF",@"eventIndex":@"10",@"unreadmsg":@"0",@"tag":@"10"}];
//        
//        /*
//        NSMutableArray *arrModel = [[NSMutableArray alloc] init];
//        
//        for (int i=0; i<arrayCRMOption.count; i++) {
//            RootMenuModel *model = [RootMenuModel initWithDictionary:arrayCRMOption[i]];
//            [arrModel addObject:model];
//        }
//         */
//        
//        [NSUserDefaults_Cache setCRMModuleOptions:arrayCRMOption];
//    }
    
}

#pragma mark - 根据手机名称获取联系人信息
///根据手机号获取当前联系人
+(AddressBook *)getContactNameByMobile:(NSString *)mobile{
    
    NSMutableArray *arrAddressBook = [[NSMutableArray alloc] init];
    ///读取缓存
    arrAddressBook = [FMDB_SKT_CACHE select_AddressBook_AllData];
    
    NSInteger count = 0;
    if (arrAddressBook) {
        count = [arrAddressBook count];
    }
    AddressBook *item = nil;
    BOOL isFound = FALSE;
    for (int i=0; !isFound && i<count; i++) {
        item = [arrAddressBook objectAtIndex:i];
        if ([item.mobile isEqualToString:mobile]) {
            isFound = TRUE;
            return item;
        }
    }
    return nil;
}



#pragma mark - 从文件读取缓存的动态数据（1页）
+(void)getDynamicCacheData{

//    __weak typeof(self) weak_self = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        ///我关注的动态
        if (appDelegateAccessor.moudle.user_focus_dynamic == nil || [appDelegateAccessor.moudle.user_focus_dynamic count] == 0) {
            NSLog(@"读取缓存----我关注的动态->");
            [Dynamic_Data getUserFocusDynamic];
        }
        
        ///公开动态
        if (appDelegateAccessor.moudle.user_public_dynamic == nil || [appDelegateAccessor.moudle.user_public_dynamic count] == 0) {
            NSLog(@"读取缓存----公开动态->");
            [Dynamic_Data getUserPublicDynamic];
        }
        
        ///我的动态
        if (appDelegateAccessor.moudle.user_my_dynamic == nil || [appDelegateAccessor.moudle.user_my_dynamic count] == 0) {
            NSLog(@"读取缓存----我的动态->");
            [Dynamic_Data getUserMyDynamic];
        }
        
        ///我的收藏
        if (appDelegateAccessor.moudle.user_favorite_dynamic == nil || [appDelegateAccessor.moudle.user_favorite_dynamic count] == 0) {
            NSLog(@"读取缓存----我的收藏->");
            [Dynamic_Data getUserFavoriteDynamic];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
    
    
    
}


/*
-(void)getExistCache{
 
    if ([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"workzone"]) {
        ///工作圈
        if (_curIndex == 0) {
            ///我关注的动态
            if (appDelegateAccessor.moudle.user_focus_dynamic == nil || [appDelegateAccessor.moudle.user_focus_dynamic count] == 0) {
                NSLog(@"读取缓存-------0-->");
                [Dynamic_Data getUserFocusDynamic];
            }
            NSLog(@"读取缓存-----1---->");
            [self.arrayWorkGroup addObjectsFromArray:appDelegateAccessor.moudle.user_focus_dynamic];
            
        }else if (_curIndex == 1){
            ///公开动态
            if (appDelegateAccessor.moudle.user_public_dynamic == nil || [appDelegateAccessor.moudle.user_public_dynamic count] == 0) {
                [Dynamic_Data getUserPublicDynamic];
            }
            
            [self.arrayWorkGroup addObjectsFromArray:appDelegateAccessor.moudle.user_public_dynamic];
        }
    }else if ([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"feed"]) {
        ///我的动态
        if (appDelegateAccessor.moudle.user_my_dynamic == nil || [appDelegateAccessor.moudle.user_my_dynamic count] == 0) {
            [Dynamic_Data getUserMyDynamic];
        }
        
        [self.arrayWorkGroup addObjectsFromArray:appDelegateAccessor.moudle.user_my_dynamic];
    }else if ([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"favorite"]) {
        ///我的收藏
        if (appDelegateAccessor.moudle.user_favorite_dynamic == nil || [appDelegateAccessor.moudle.user_favorite_dynamic count] == 0) {
            [Dynamic_Data getUserFavoriteDynamic];
        }
        
        [self.arrayWorkGroup addObjectsFromArray:appDelegateAccessor.moudle.user_favorite_dynamic];
    }else if([[CommonStaticVar getFlagOfWorkGroupViewFrom] isEqualToString:@"homeworkzone"]){
        ///首页工作圈
        if (appDelegateAccessor.moudle.user_focus_dynamic == nil || [appDelegateAccessor.moudle.user_focus_dynamic count] == 0) {
            [Dynamic_Data getUserFocusDynamic];
        }
        
        [self.arrayWorkGroup addObjectsFromArray:appDelegateAccessor.moudle.user_focus_dynamic];
    }
    
    if ([self.arrayWorkGroup count] > 0) {
        NSLog(@"getExistCache---有缓存>");
    }
    [self.tableviewWorkGroup reloadData];
}
*/



#pragma mark - 拨打电话或发送短信时标记联系人为最近联系人
+(void)setLatelyContactByMobile:(NSString *)mobile{
    AddressBook *contact = [CommonModuleFuntion getContactNameByMobile:mobile];
    
    if (contact == nil) {
        return;
    }
    
    NSMutableArray *newLatelyContacts = [[NSMutableArray alloc] init];
    NSArray *latelyContacts = [FMDB_SKT_CACHE select_AddressBook_LatelyContact_AllData];
    if (latelyContacts) {
        [newLatelyContacts addObjectsFromArray:latelyContacts];
    }
    
    NSInteger count = 0;
    if (newLatelyContacts) {
        count = [newLatelyContacts count];
    }
    AddressBook *item = nil;
    BOOL isFound = FALSE;
    for (int i=0; !isFound && i<count; i++) {
        item = [newLatelyContacts objectAtIndex:i];
        
        if ([item.mobile isEqualToString:mobile]) {
            isFound = TRUE;
            [newLatelyContacts removeObjectAtIndex:i];
        }
    }
    if (count == 0) {
        [newLatelyContacts addObject:contact];
    }else{
        [newLatelyContacts insertObject:contact  atIndex:0];
    }
    
    ///只保存5条数据
    if (newLatelyContacts && [newLatelyContacts count]>5) {
        [newLatelyContacts removeLastObject];
    }
    NSLog(@"newLatelyContacts:%@",newLatelyContacts);
    
    [FMDB_SKT_CACHE delete_AddressBook_LatelyContact_AllDataCache];
    [FMDB_SKT_CACHE saveLatelyContactDataToSQL:newLatelyContacts];
    [FMDB_SKT_CACHE closeDataBase];
    
}

@end
