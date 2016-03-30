//
//  RootTabBarController.m
//  shangketong
//
//  Created by sungoin-zbs on 15/4/22.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import "RootTabBarController.h"
#import "Home_RootViewController.h"
#import "Message_RootViewController.h"
#import "CRM_RootViewController.h"
#import "Office_RootViewController.h"
#import "Me_RootViewController.h"
#import "CommonConstant.h"
#import "CommonStaticVar.h"
#import "StartChatViewController.h"
#import "IM_FMDB_FILE.h"

@interface RootTabBarController ()

@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [CommonStaticVar setContentFont:14.0 color:COLOR_WORKGROUP_CONTENT];
    
    [[FMDBManagement sharedFMDBManager] creatAddressBookTable];
    
    // 请求时间
    NSMutableDictionary *tempParams = [NSMutableDictionary dictionaryWithDictionary:COMMON_PARAMS];
    NSString *serverTime = [[NSUserDefaults standardUserDefaults] objectForKey:kAddressBookServerTime];
    if (serverTime) {
        [tempParams setObject:serverTime forKey:kAddressBookServerTime];
    }
    
    [[Net_APIManager sharedManager] request_Address_List_WithParams:tempParams andBlock:^(id data, NSError *error) {
        if (data) {
            NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *tempDict in data[@"users"]) {
                AddressBook *item = [NSObject objectOfClass:@"AddressBook" fromJSON:tempDict];
                [tempArray addObject:item];
            }
            
            if (serverTime) {
                [[FMDBManagement sharedFMDBManager] updateAddressBookWithArray:tempArray];
            }
            else {
                [[FMDBManagement sharedFMDBManager] insertAddressBookWithArray:tempArray];
            }
            
            // 保存serverTime
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:data[@"serverTime"] forKey:kAddressBookServerTime];
            [defaults synchronize];
            if (![CommonFuntion checkNullForValue:serverTime]) {
                [defaults setObject:data[@"serverTime"] forKey:@"IMAddressServerTime"];
                ///清空
                [IM_FMDB_FILE delete_IM_AllAddressBook];
                ///缓存
                [IM_FMDB_FILE getAllAddressBookContactFromServer:data[@"users"]];
                [IM_FMDB_FILE closeDataBase];
            }
        }
    }];

    if ([CommonFuntion checkNullForValue:serverTime]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [[StartChatViewController alloc] getContactDataSourceFromSever];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        });
        
    }
    
    NSLog(@"RootTabBarController---viewDidLoad-->");
    
    NSArray *controllers = @[@"Home_RootViewController", @"Message_RootViewController", @"CRM_RootViewController", @"Office_RootViewController", @"Me_RootViewController"];
    NSArray *tabbarImages = @[@"index_tabicon_home", @"index_tabicon_msg", @"index_tabicon_crm", @"index_tabicon_oa", @"index_tabicon_my"];
    NSArray *tabbarTitles = @[@"首页", @"消息", @"CRM", @"办公", @"我"];
    
    NSMutableArray *tabbarViewControllers = [[NSMutableArray alloc] initWithCapacity:5];
    for (int i = 0; i < controllers.count; i ++) {
        Class class = NSClassFromString(controllers[i]);
        UIViewController *viewController = [[class alloc] init];
        viewController.title = tabbarTitles[i];
        
        UIImage *normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", tabbarImages[i]]];
        UIImage *selectImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_highlited", tabbarImages[i]]];
        normalImage = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        selectImage = [selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:tabbarTitles[i] image:normalImage selectedImage:selectImage];
        
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_NORMAL_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_SELECTED_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
        
        viewController.tabBarItem = item;
        viewController.tabBarItem.tag = i;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [tabbarViewControllers addObject:navController];
    }
    self.viewControllers = tabbarViewControllers;
  
    
    
    
    /*
    Home_RootViewController *mainController = [[Home_RootViewController alloc] init];
    mainController.title = tabbarTitles[0];
    UITabBarItem *mainItem = [[UITabBarItem alloc] initWithTitle:tabbarTitles[0] image:[UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", tabbarImages[0]]] selectedImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_highlited", tabbarImages[0]]]];
    mainController.tabBarItem = mainItem;
    UINavigationController *mainNav = [[UINavigationController alloc] initWithRootViewController:mainController];
    
    Message_RootViewController *messageController = [[Message_RootViewController alloc] init];
    messageController.title = tabbarTitles[1];
    UITabBarItem *messageItem = [[UITabBarItem alloc] initWithTitle:tabbarTitles[1] image:[UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", tabbarImages[1]]] selectedImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_highlited", tabbarImages[1]]]];
    messageController.tabBarItem = messageItem;
    UINavigationController *messageNav = [[UINavigationController alloc] initWithRootViewController:messageController];
    
    CRM_RootViewController *crmController = [[CRM_RootViewController alloc] init];
    crmController.title = tabbarTitles[2];
    UITabBarItem *crmItem = [[UITabBarItem alloc] initWithTitle:tabbarTitles[2] image:[UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", tabbarImages[2]]] selectedImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_highlited", tabbarImages[2]]]];
    crmController.tabBarItem = crmItem;
    UINavigationController *crmNav = [[UINavigationController alloc] initWithRootViewController:crmController];
    
    Office_RootViewController *officeController = [[Office_RootViewController alloc] init];
    officeController.title = tabbarTitles[3];
    UITabBarItem *officeItem = [[UITabBarItem alloc] initWithTitle:tabbarTitles[3] image:[UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", tabbarImages[3]]] selectedImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_highlited", tabbarImages[3]]]];
    officeController.tabBarItem = officeItem;
    UINavigationController *officeNav = [[UINavigationController alloc] initWithRootViewController:officeController];
    
    Me_RootViewController *meController = [[Me_RootViewController alloc] init];
    meController.title = tabbarTitles[4];
    UITabBarItem *meItem = [[UITabBarItem alloc] initWithTitle:tabbarTitles[4] image:[UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", tabbarImages[4]]] selectedImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_highlited", tabbarImages[4]]]];
    meController.tabBarItem = meItem;
    UINavigationController *meNav = [[UINavigationController alloc] initWithRootViewController:meController];
    
    self.viewControllers = @[mainNav, messageNav, crmNav, officeNav, meNav];
    */
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







@end
