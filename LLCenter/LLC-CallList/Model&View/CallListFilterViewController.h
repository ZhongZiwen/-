//
//  CallListFilterViewController.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-23.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CallListFilterViewControllerDelegate <NSObject>
@optional
- (void)filterComplete:(NSDictionary*)dict;

@end


@interface CallListFilterViewController : AppsBaseViewController {
    IBOutlet UITableView *tbView;
    IBOutlet UIView *viewMask,*viewForPannel,*viewBottom,*viewSiteSelection;
    
    IBOutlet UILabel *labelLocation,*labelPeople,*labelStartTime,*labelEndTime;
    IBOutlet UILabel *labelMaskName,*labelSitsTitle;
    
    IBOutlet UIDatePicker *datePicker;
    
    IBOutlet UIButton *btnDoneForViewMask;
    
    NSMutableArray *dataSourceForLocation,*dataSourceForPeople;
    
    
    
    // UI 适配
    // 接听区域
    
    IBOutlet UIImageView *imgAreaIcon,*imgAreaArrow;
    IBOutlet UILabel *labelAreaFlag;
    IBOutlet UIButton *btnAreaClick;
    IBOutlet UIView *viewMidLine,*viewAreaBg;
    
    // 接听席位
    IBOutlet UIImageView *imgSiteIcon,*imgSiteArrow;
    IBOutlet UIButton *btnSiteClick;
    IBOutlet UIView *viewSiteMidLine;
    
    // 开始时间
    IBOutlet UIView *viewSDateBg,*viewSDateMidLine;
    IBOutlet UIImageView *imgSDateIcon,*imgSDateArrow;
    IBOutlet UIButton *btnSDateClick;
    IBOutlet UILabel *labelSDateFlag;
    
    // 结束时间
    IBOutlet UIView *viewEDateBg,*viewEDateMidLine;
    IBOutlet UIImageView *imgEDateIcon,*imgEDateArrow;
    IBOutlet UIButton *btnEDateClick;
    IBOutlet UILabel *labelEDateFlag;
    
    IBOutlet UIButton *btnOk;
}

enum FilterItem {
    FiltingLocation = 100,
    FiltingPeople,
    FiltingStartTime,
    FiltingEndTime
};

enum FilterType {
    FiltingAnsweredCall = 0,
    FiltingNoAnswerCall,
    FiltingOutCall,
    FiltingVoiceBox
};

@property (nonatomic) int filtType;
@property (nonatomic,strong) NSDictionary *defaultCondition;
@property (nonatomic,assign) id <CallListFilterViewControllerDelegate> delegate;

- (IBAction)btnAction:(id)sender;

@end
