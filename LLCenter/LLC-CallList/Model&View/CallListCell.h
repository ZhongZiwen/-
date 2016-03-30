//
//  CallListCell.h
//  lianluozhongxin
//
//  Created by Vescky on 14-6-22.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayingProcessBar.h"

@protocol CallListCellDelegate <NSObject>

- (void)expandButtonAction:(NSIndexPath*)_indexPath object:(CellDataInfo*)cInfo;
-(void)callPhone:(NSIndexPath*)_indexPath object:(CellDataInfo*)cInfo;

@end

@interface CallListCell : UITableViewCell {
    IBOutlet UIButton *btnExpand,*btnPlay,*btnCover;
    IBOutlet UILabel *labelTitle,*labelSubTitle;
    IBOutlet UIView *expandedView,*expandedViewButtom;
    IBOutlet UIImageView *triangleImageView;
    
    IBOutlet UILabel *labelSit;
    
    IBOutlet UILabel *labelDate;
    IBOutlet UILabel *labelDateTime;

    IBOutlet UIView *view_line;
    IBOutlet UIButton *btnExpAction;
    IBOutlet UIButton *btnCallByPhoneNum;
    
    //详细页的数据
    IBOutlet UILabel *labelCustomerPhoneTitle,*labelCustomerPhoneContent;
    IBOutlet UILabel *labelCallTimeTitle,*labelCallTimeContent;
    IBOutlet UILabel *labelRecieverTitle,*labelRecieverContent;
    IBOutlet UILabel *labelDurationTitle,*labelDurationContent;
    IBOutlet UILabel *labelAuditionTitle,*labelAuditionContent;
    IBOutlet UILabel *labelCurrentTime,*labelTotleTime;
    
    IBOutlet UIImageView *callIcon;
    
    PlayingProcessBar *playingProcessBar;
}

enum CallListCellType {
    CallListCellAnswered = 0,
    CallListCellNoAnswer,
    CallListCellOutCall,
    CallListCellVoiceBox
};


@property (nonatomic) int cellType;
@property (nonatomic,strong) UINavigationController *nvController;
@property (nonatomic,assign) id <CallListCellDelegate> delegate;
@property (nonatomic,strong) NSIndexPath *indexPath;

- (void)setCellDataInfo:(CellDataInfo*)cInfo;

- (void)setButtonSelected:(bool)isSelected;

- (void)stopPlay;

- (IBAction)btnAction:(id)sender;
- (IBAction)expandButtonAction:(id)sender;

-(IBAction)callIt:(id)sender;

// UI 适配
-(void)setCellViewFrame;

@end
