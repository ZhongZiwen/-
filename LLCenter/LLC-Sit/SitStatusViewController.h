//
//  SitStatusViewController.h
//  lianluozhongxin
//
//  Created by sungoin-zjp on 15-10-12.
//  Copyright (c) 2015年 Vescky. All rights reserved.
//

#import "AppsBaseViewController.h"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

///ImageView旋转状态枚举
typedef enum {
    RotateStateStop,
    RotateStateRunning,
}RotateState;

@interface SitStatusViewController : AppsBaseViewController

@end
