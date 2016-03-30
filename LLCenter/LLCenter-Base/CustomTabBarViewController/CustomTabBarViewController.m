//
//  CustomTabBarViewController.m
//  lianluozhongxin
//
//  Created by Vescky on 14-7-4.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import "CustomTabBarViewController.h"
#import "LLCenterUtility.h"



#import "CallListViewController.h"
#import "MoreViewController.h"

#import "FMDB_LLC_AUDIO.h"


#define TabBarItemTag 88888
#define TabBarTextTag 99999

@implementation CustomTabBarViewController

@synthesize currentSelectedIndex;
@synthesize buttons;
@synthesize selectedImages,unselectedImages,titles;
@synthesize isBarHidden,customTabBarView;

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = kView_BG_Color;
//    [self hideRealTabBar];
//    [self initLLCenterViewController];
//    [self customTabBar];
    [self initTabBarController];
     [[FMDB_LLC_AUDIO sharedFMDB_LLC_AUDIO_Manager] creatAudioTable];
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)hideRealTabBar{
    for(UIView *view in self.view.subviews){
        if([view isKindOfClass:[UITabBar class]]){
            view.hidden = YES;
            break;
        }
    }
}

- (void)customTabBar{
    //创建自定义的tabbar view
    customTabBarView = [[UIView alloc] initWithFrame:self.tabBar.frame];
    customTabBarView.backgroundColor = [UIColor whiteColor];
    customTabBarView.layer.borderColor = GetColorWithRGB(229.0f, 229.0f, 229.0f).CGColor;
    customTabBarView.layer.borderWidth = 1.0f;
    
    //创建按钮
    int viewCount = self.viewControllers.count > 5 ? 5 : self.viewControllers.count;
    self.buttons = [NSMutableArray arrayWithCapacity:viewCount];
    double _width = DEVICE_BOUNDS_WIDTH / viewCount;
    double _height = self.tabBar.frame.size.height;
    for (int i = 0; i < viewCount; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (selectedImages && i < [selectedImages count]) {
            [btn setImage:[UIImage imageNamed:[selectedImages objectAtIndex:i]] forState:UIControlStateNormal];
        }
        if (unselectedImages && i < [unselectedImages count]) {
            [btn setImage:[UIImage imageNamed:[unselectedImages objectAtIndex:i]] forState:UIControlStateSelected];
        }
        btn.frame = CGRectMake(i*_width + 5, -5, _width, _height);
        [btn addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = TabBarItemTag + i;
        
        if (i < [titles count]) {
            NSString *vcTitle = [titles objectAtIndex:i];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*_width + 4, customTabBarView.frame.size.height - 18, _width, 20)];
            label.textAlignment = 1;
            label.text = vcTitle;
            label.textColor = GetColorWithRGB(29, 45, 65);
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:12.0];
            label.tag = TabBarTextTag + i;
            label.hidden = YES;
            [customTabBarView addSubview:label];
        }
        
        [self.buttons addObject:btn];
        [customTabBarView addSubview:btn];
    }
    customTabBarView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    
    [self selectedTab:[self.buttons objectAtIndex:0]];
    [self.view addSubview:customTabBarView];
    //for test
//    customTabBarView.backgroundColor = [UIColor redColor];
//    self.view.backgroundColor = [UIColor greenColor];
}

- (void)selectedTab:(UIButton *)button{
     NSLog(@"selectedTab----:%ti",button.tag);
    if (self.currentSelectedIndex == button.tag) {
        return;
    }
    
    switch (button.tag) {
        case TabBarItemTag:
            self.title = @"话单";
            break;
        case TabBarItemTag+1:
            self.title = @"更多";
            break;
            
        default:
            break;
    }
    
    int lastButtonSelectedIndex = self.currentSelectedIndex;
    int lastLabelSelectedIndex = lastButtonSelectedIndex + TabBarTextTag - TabBarItemTag;
    int currentButtonSelectedIndex = button.tag;
    int currentLabelSelectedIndex = currentButtonSelectedIndex + TabBarTextTag - TabBarItemTag;
    
    button.selected = YES;
    UIButton *lastButton = (UIButton*)[customTabBarView viewWithTag:lastButtonSelectedIndex];
    if ([lastButton isKindOfClass:[UIButton class]]) {
        lastButton.selected = NO;
    }
    
    UILabel *label = (UILabel*)[customTabBarView viewWithTag:currentLabelSelectedIndex];
    if ([label isKindOfClass:[UILabel class]]) {
        label.textColor = GetColorWithRGB(27, 126, 254);
    }
    
    UILabel *lastLabel = (UILabel*)[customTabBarView viewWithTag:lastLabelSelectedIndex];
    if ([lastLabel isKindOfClass:[UILabel class]]) {
        lastLabel.textColor = GetColorWithRGB(29, 45, 65);
    }
    
    self.currentSelectedIndex = currentButtonSelectedIndex;
    self.selectedIndex = currentButtonSelectedIndex - TabBarItemTag;
   
}



- (void)setCustomTabBarHidden:(bool)isHidden animated:(bool)animated {
    isBarHidden = isHidden;
    customTabBarView.hidden = isHidden;
}




#pragma mark - 初始化联络中心
-(void)initLLCenterViewController{
    
    UINavigationController* navControloler = [[UINavigationController alloc] init];
    
    //定义tabbar的4个viewcontroller
    //    CustomerManageViewController *vc1 = [[CustomerManageViewController alloc] init];
    CallListViewController *vc2 = [[CallListViewController alloc] init];
    //    ContactBookViewController *vc3 = [[ContactBookViewController alloc] init];
    MoreViewController *vc4 = [[MoreViewController alloc] init];
    
    
    //创建导航栈队列
    //    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    //    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:vc3];
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:vc4];
    
    
    
    //创建tabbarcontroller
    NSArray *arrVCs = [[NSArray alloc] initWithObjects:nav2,nav4, nil];
    
    self.selectedImages = [[NSMutableArray alloc] initWithObjects:@"tabbar_calllist_normal.png",@"tabbar_more_normal.png", nil];
    self.unselectedImages = [[NSMutableArray alloc] initWithObjects:@"tabbar_calllist_selected.png",@"tabbar_more_selected.png", nil];
    self.titles = [[NSMutableArray alloc] initWithObjects:@"话单",@"更多", nil];
    
    self.viewControllers = arrVCs;
    //     [self.tabBarController setSelectedIndex:3];
    [self setHidesBottomBarWhenPushed:YES];
    
}



-(void)initTabBarController{
    NSArray *controllers = @[@"CustomerManageViewController",@"CallListViewController", @"SitListViewController",@"MoreViewController"];
    NSArray *tabbarImages = @[@"tabbar_manager",@"tabbar_calllist", @"tabbar_sit",@"tabbar_more"];
    NSArray *tabbarTitles = @[@"CRM",@"话单", @"坐席", @"更多"];
    
    
//    NSArray *controllers = @[@"CustomerManageViewController",@"CallListViewController"];
//    NSArray *tabbarImages = @[@"tabbar_manager",@"tabbar_calllist"];
//    NSArray *tabbarTitles = @[@"CRM",@"话单"];
    
    NSMutableArray *tabbarViewControllers = [[NSMutableArray alloc] initWithCapacity:5];
    for (int i = 0; i < controllers.count; i ++) {
        Class class = NSClassFromString(controllers[i]);
        UIViewController *viewController = [[class alloc] init];
        viewController.title = tabbarTitles[i];
        
        UIImage *normalImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", tabbarImages[i]]];
        UIImage *selectImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", tabbarImages[i]]];
        normalImage = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        selectImage = [selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:tabbarTitles[i] image:normalImage selectedImage:selectImage];
        ///0079ff
        
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_NORMAL_COLOR,NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
        
        [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:TABBAR_ITEM_SELECTED_COLOR_LLC,NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
        
        viewController.tabBarItem = item;
        viewController.tabBarItem.tag = i;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [tabbarViewControllers addObject:navController];
    }
    self.viewControllers = tabbarViewControllers;
}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    NSLog(@"did seletct item:%ti",item.tag);
    switch (item.tag) {
        case 0:
            self.title = @"CRM";
            break;
        case 1:
            self.title = @"话单";
            break;
        case 2:
            self.title = @"坐席";
            break;
        case 3:
            self.title = @"更多";
            break;
            
        default:
            break;
    }
}


@end