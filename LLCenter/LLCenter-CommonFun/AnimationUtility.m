//
//  AnimationUtility.m
//  Fineland
//
//  Created by Rayco on 12-12-26.
//  Copyright (c) 2012年 Apps123. All rights reserved.
//

#define TransitionDuration 0.35f

#import "AnimationUtility.h"

@implementation AnimationUtility

#pragma mark - Public Static

+ (void)bubbleAnimation:(UIView *)animationView show:(BOOL)show {
    if(!show){
        [UIView animateWithDuration:TransitionDuration / 3 animations:^(void){
            animationView.hidden = YES;
            
        } completion:^(BOOL finished){
            
        }];
        return;
    }
    animationView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    [UIView animateWithDuration:TransitionDuration / 3 animations:^(void){
        animationView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        animationView.hidden = NO;
        
    } completion:^(BOOL finished){
        [UIView animateWithDuration:TransitionDuration / 6 animations:^(void){
            animationView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
            
        } completion:^(BOOL finished){
            [UIView animateWithDuration:TransitionDuration / 6 animations:^(void){
                animationView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
                
            } completion:^(BOOL finished){
                [UIView animateWithDuration:TransitionDuration / 6 animations:^(void){
                    animationView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95);
                } completion:^(BOOL finished){
                    [UIView animateWithDuration:TransitionDuration / 6 animations:^(void){
                        animationView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                        
                    } completion:^(BOOL finished){
                        
                    }];
                }];
            }];
        }];
    }];
}

@end
