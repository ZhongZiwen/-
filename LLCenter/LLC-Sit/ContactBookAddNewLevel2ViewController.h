//
//  ContactBookAddNewLevel2ViewController.h
//  lianluozhongxin
//
//  Created by Vescky on 14-7-7.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactsInfo.h"

@protocol ContactBookAddNewLevel2ViewControllerDelegate <NSObject>

@optional
- (void)selectedGroupsDidChanged:(NSArray*)arr;
- (void)allGroupsStatusDisChanged:(NSArray*)arr;

@end

@interface ContactBookAddNewLevel2ViewController : AppsBaseViewController {
    IBOutlet UITableView *tbView;
    IBOutlet UIScrollView *scView;
    IBOutlet UIButton *button;
}

enum GroupDataType {
    GroupDataAll = 0,
    GroupDataChildren
};

@property (nonatomic,strong) ContactsInfo *detailContactInfo;
@property (nonatomic,strong) UIViewController *fromViewController;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *selectedGroupsIDList;
@property (nonatomic,assign) id <ContactBookAddNewLevel2ViewControllerDelegate> delegate;
@property int groupDataType;

- (IBAction)btnAction:(id)sender;

@end
