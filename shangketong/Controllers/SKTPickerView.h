//
//  SKTPickerView.h
//  DemoMapViewPOI
//
//  Created by sungoin-zjp on 15-5-11.
//  Copyright (c) 2015年 sungoin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum ButtonType
{
    Button_OK,
    Button_PRE,
    Button_NEXT
    
}ButtonType;
@class SKTPickerViewItem;
typedef void(^SKTPickerViewHandler)(SKTPickerViewItem *item);


@protocol PickerDataChangeDelegate;

@interface SKTPickerView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIView *_coverView;
    UIView *_contentView;
    UIButton *_okBtn;
    UIButton *_preBtn;
    UIButton *_nextBtn;
    NSString *_contentType;
    
    NSMutableArray *_items;
    
    UIDatePicker *_datePickView;
    UIPickerView *_pickerView;
    
    NSArray *_arrayPcikerview;
    NSString *_showData;
}

@property (assign, nonatomic) id <PickerDataChangeDelegate>delegate;

///pickerview  数据源
///data 当前选中项
///type  类型  datepicker/pickerview
- (instancetype)initWithContent:(NSArray *)content
                           data:(NSString *)data byType:(NSString *)type;

- (void)show:(UIView *)spview;
- (void)dismiss;
- (void)addButton:(ButtonType)type handler:(SKTPickerViewHandler)handler;

@end


@interface SKTPickerViewItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic) ButtonType type;
@property (nonatomic) NSUInteger tag;
@property (nonatomic, copy) SKTPickerViewHandler action;

@property (nonatomic, copy) NSString *selectDate;

@end



// 选择最近浏览
@protocol PickerDataChangeDelegate<NSObject>
@optional
///日期
- (void)selectedDate:(NSString *)selected;
///picker
- (void)selectedData:(NSString *)selected;
@end
