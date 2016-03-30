//
//  CommonConstant.h
//  shangketong
//  ///颜色值 字体大小
//  Created by sungoin-zjp on 15-5-20.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <Foundation/Foundation.h>



#pragma mark - 全局代理
///主代理对象
#define appDelegateAccessor ((AppDelegate *)[[UIApplication sharedApplication] delegate])

///是否为iOS8
#define isIOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 ? YES : NO)

///获取本地图片
#define LOADIMAGE(imgname,type) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]


#pragma mark - 知识库文件名前缀
#define PATH_KNOWLEDGE_FILENAME_PREFIX @"Knowledge"

#pragma mark -  颜色值
#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#pragma mark - Group Head title 颜色值
#define GROUP_HEAD_TITLE_COLOR [UIColor colorWithRed:83.0f/255 green:98.0f/255 blue:128.0f/255 alpha:1.0f]


#define VIEW_BG_COLOR [UIColor colorWithRed:248.0f/255 green:248.0f/255 blue:248.0f/255 alpha:1.0f]



#pragma mark - 左滑菜单按钮背景色
#define COLOR_CELL_RIGHT_BTN_BG [UIColor colorWithRed:239.0f/255 green:239.0f/255 blue:244.0f/255 alpha:1.0f]

#pragma mark - 动态中竖线颜色
#define COLOR_CELL_SPLIT_LINE [UIColor colorWithRed:136.0f/255 green:153.0f/255 blue:166.0f/255 alpha:1.0f]

#pragma mark - 工作圈  颜色值

///#292f33
#define COLOR_WORKGROUP_NAME [UIColor colorWithRed:41.0f/255 green:47.0f/255 blue:51.0f/255 alpha:1.0f]
#define COLOR_WORKGROUP_DATE [UIColor colorWithRed:178.0f/255 green:189.0f/255 blue:197.0f/255 alpha:1.0f]
#define COLOR_WORKGROUP_CONTENT [UIColor colorWithRed:46.0f/255 green:51.0f/255 blue:55.0f/255 alpha:1.0f]
#define COLOR_WORKGROUP_OPTION [UIColor colorWithRed:136.0f/255 green:153.0f/255 blue:166.0f/255 alpha:1.0f]


#pragma mark - 知识库 日期-大小 颜色
#define COLOR_KNOWLEDGE_DATE_SIZE [UIColor colorWithRed:147.0f/255 green:147.0f/255 blue:153.0f/255 alpha:1.0f]

#define COLOR_KNOWLEDGE_COUNT [UIColor colorWithRed:191.0f/255 green:191.0f/255 blue:191.0f/255 alpha:1.0f]

#pragma MARK - searchbar背景色
#define COLOR_SEARCHBAR_BG [UIColor colorWithRed:240.0f/255 green:240.0f/255 blue:240.0f/255 alpha:1.0f]


#pragma mark - 工作圈  字体大小

#define FONT_WORKGROUP_NAME ([UIFont systemFontOfSize:12.0])
#define FONT_WORKGROUP_DATE ([UIFont systemFontOfSize:10.0])
#define FONT_WORKGROUP_CONTENT ([UIFont systemFontOfSize:15.0])
#define FONT_WORKGROUP_CONTENT_SIZE 15.0
#define FONT_WORKGROUP_OPTION ([UIFont systemFontOfSize:12.0])
#define FONT_WORKGROUP_ADDRESS ([UIFont systemFontOfSize:12.0])

#define FONT_WORKGROUP_BLOG_TITLE ([UIFont systemFontOfSize:15.0])
#define FONT_WORKGROUP_BLOG_CONTENT ([UIFont systemFontOfSize:15.0])

#pragma mark - 工作圈  label宽度与高度max
#define MAX_WIDTH_OR_HEIGHT 19999



#pragma mark - 客户、联系人、销售机会等详情页面字体大小
#define FONT_DETAILS_BELONGNAME_NAME ([UIFont systemFontOfSize:10.0])
#define FONT_DETAILS_USER_NAME ([UIFont systemFontOfSize:14.0])
#define FONT_DETAILS_CONTENT ([UIFont systemFontOfSize:14.0])


#pragma mark - 日期格式

#define DAY_OF_SECONDS (24*60*60)
#define HOUR_OF_SECONDS (60*60)

#define DATE_FORMAT_NOSPLIT_yyyyMMddHHmm @"yyyyMMddHHmm"
#define DATE_FORMAT_yyyyMMddHHmm @"yyyy-MM-dd HH:mm"
#define DATE_FORMAT_yyyyMMdd @"yyyy-MM-dd"
#define DATE_FORMAT_yyyy @"yyyy"
#define DATE_FORMAT_MMddHHmm @"MM-dd HH:mm"
#define DATE_FORMAT_MMdd @"MM月dd日"
#define DATE_FORMAT_MM @"MM月"
#define DATE_FORMAT_MM_dd @"MM-dd"
#define DATE_FORMAT_HHmm @"HH:mm"
#define DATE_FORMAT_MdEEEE @"M月d日 EEEE"

#pragma mark - float格式  保留小数点后一位  两位
#define FORMAT_FLOAT_POINT_1 @"####0.0;"
#define FORMAT_FLOAT_POINT_2 @"#####0.00;"


#define CHECK_CHAR_PHONE_NUM @"0123456789-"

#pragma mark - 搜索关键词
#define SEARCH_KEY_WORDS @"大厦|公司|餐饮|酒店|医院|学校|电影院|超市|商场|银行|景点|地铁"

#pragma mark - pcikerview标识
#define DATE_PICKERVIEW @"datepicker"
#define PICKERVIEW @"pickerview"


#pragma mark - 搜索历史相关flag
//////知识库：_knowledge
#define search_history_flag_key @"knowledge"



#pragma mark - 头像默认图片
#define PLACEHOLDER_CONTACT_ICON @"user_icon_default_90.png"

#pragma mark - 图片默认图片
#define PLACEHOLDER_REVIEW_IMG @"Expense_Detail_PhotoNoImageView.png"

#pragma mark -产品默认图片
#define PLACEHOLDER_PRODUCT_IMG @"product_icon_default.png"


#pragma mark - tabbar 文字颜色
#define TABBAR_ITEM_NORMAL_COLOR [UIColor colorWithRed:146.0f/255 green:146.0f/255 blue:146.0f/255 alpha:1.0f]
#define TABBAR_ITEM_SELECTED_COLOR [UIColor colorWithRed:0.0f/255 green:188.0f/255 blue:45.0f/255 alpha:7.0f]
#define TABBAR_ITEM_SELECTED_COLOR_LLC [UIColor colorWithRed:0.0f/255 green:121.0f/255 blue:255.0f/255 alpha:1.0f]

#pragma mark - 本地消息通知标识
///本地消息通知标识
#define SKT_LOCAL_NOTIFICATION_OBSERVER_NAME1 @"gotoLocalNotificationView"

///本地消息通知标识  IM消息
#define SKT_LOCAL_NOTIFICATION_OBSERVER_NAME2 @"gotoIMNotificationView"
///本地消息通知标识  IM消息
#define SKT_LOCAL_NOTIFICATION_OBSERVER_NAME3 @"showNotificationView"

///刷新最新动态至UI
#define SKT_OA_HOME_TREND_OBSERVER_NAME @"notifyOAOrHomeNewTrends"

#pragma mark - 日程、任务左滑按钮背景色
///完成
#define SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_OVER  [UIColor colorWithRGBHex:0x10aeff]
///重启
#define SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_RESET  [UIColor colorWithRGBHex:0x4cd127]
///接受
#define SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_ACCEPT  [UIColor colorWithRGBHex:0x55acee]
///拒绝
#define SKT_TASK_OR_SCHEDULE_MENU_BTN_COLOR_REFUSE  [UIColor colorWithRGBHex:0xccd6dd]


#pragma mark - 审批状态颜色值
///绿色代表已通过，黄色代表已撤回，红色代表拒绝，默认颜色代表等待审批、提交申请
#define SKT_OA_APPROVAL_STATUS_DEFAULT [UIColor colorWithRGBHex:0x10aeff]
#define SKT_OA_APPROVAL_STATUS_GREEN  [UIColor colorWithRGBHex:0x00A600]
#define SKT_OA_APPROVAL_STATUS_RED  [UIColor colorWithRGBHex:0xec5050]
#define SKT_OA_APPROVAL_STATUS_YELLOW  [UIColor colorWithRGBHex:0xEAC100]


@interface CommonConstant : NSObject



@end
