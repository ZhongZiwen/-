//
//  PhotoBrowserController.h
//  
//
//  Created by sungoin-zbs on 15/12/27.
//
//

#import <UIKit/UIKit.h>

@class PhotoBrowserController, RecordImage;

@protocol PhotoBrowserControllerDelegate <NSObject>

- (NSInteger)numberOfRowsInPhotoBrowser:(PhotoBrowserController*)photoBrowser;
- (RecordImage*)photoBrowser:(PhotoBrowserController*)photoBrowser itemAtRow:(NSInteger)row;
- (void)photoBrowser:(PhotoBrowserController*)photoBrowser deleteItemAtRow:(NSInteger)row;
@end

@interface PhotoBrowserController : UIViewController

@property (weak, nonatomic) id<PhotoBrowserControllerDelegate>delegate;
@property (assign, nonatomic) NSInteger curIndex;
@end
