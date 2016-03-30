//
//  SheetMenuView.h
//  shangketong
//   底部弹出actionsheet   标题  列表  取消按钮
//  Created by sungoin-zjp on 15-6-9.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//


///cell类型
typedef NS_ENUM(NSInteger, SheetMenuCellType) {
    SheetMenuCellTypeA = 0,
    SheetMenuCellTypeB,
    SheetMenuCellTypeC
};


#import <UIKit/UIKit.h>
@protocol SheetMenuDelegate <NSObject>
@optional
-(void)didSelectSheetMenuIndex:(NSInteger)index;
-(void)callPhoneIndex:(NSInteger)index;
-(void)sendMsgIndex:(NSInteger)index;
@end

@interface SheetMenuView : UIView<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>{
    UIView *menuView;
    UITableView *tableviewMenu;
    NSArray *listData;
    SheetMenuCellType cellType;
}

@property(nonatomic,assign) id <SheetMenuDelegate> delegate;

-(id)initWithlist:(NSArray *)list headTitle:(NSString *)headTitle footBtnTitle:(NSString *)footTitle  cellType:(SheetMenuCellType)type;
- (void)showInView:(UIViewController *)Sview;

@end
