//
//  LLCSettingViewController.h
//  lianluozhongxin
//
//  Created by Vescky on 14-7-2.
//  Copyright (c) 2014年 Vescky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LLCSettingViewController : AppsBaseViewController {
    IBOutlet UISwitch *swh;
}

- (IBAction)btnAction:(id)sender;
- (IBAction)swichValueChanged:(id)sender;

@end
