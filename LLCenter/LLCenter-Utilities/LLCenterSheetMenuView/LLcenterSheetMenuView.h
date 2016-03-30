//
//  LLcenterSheetMenuView.h
//  shangketong
//   底部弹出actionsheet   标题  列表  取消按钮
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//


///cell类型
typedef NS_ENUM(NSInteger, SheetMenuType) {
    ///单选
    SheetMenuTypeA = 0,
    ///多选
    SheetMenuTypeB
};


#import <UIKit/UIKit.h>


@protocol LLCenterSheetMenuDelegate <NSObject>
@optional
-(void)didSelectSheetMenuIndex:(NSInteger)index menuType:(SheetMenuType)menuT menuFlag:(NSInteger)flag;
@end

@interface LLcenterSheetMenuView : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>{
    UIView *menuView;
    UITableView *tableviewMenu;
    NSMutableArray *listData;
    SheetMenuType menuType;
    ///用来标记弹框是谁传过来的
    NSInteger menuFlag;
}

@property(nonatomic,assign) id <LLCenterSheetMenuDelegate> delegate;

-(id)initWithlist:(NSArray *)list headTitle:(NSString *)headTitle footBtnTitle:(NSString *)footTitle  cellType:(SheetMenuType)type menuFlag:(NSInteger)flag;
- (void)showInView:(UIViewController *)Sview;


@property (nonatomic, copy) void (^selectedMenuItemBlock)(NSArray *array,NSInteger flag);

@end
