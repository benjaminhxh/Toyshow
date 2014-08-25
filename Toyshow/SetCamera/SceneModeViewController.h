//
//  SceneModeViewController.h
//  Delegate
//
//  Created by zhxf on 14-6-13.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SceneModeViewController;
@protocol  SceneModeViewControllerDelegate <NSObject>

- (void)scenceMode:(NSString *)mode withIndex:(NSInteger)index;

@end

@interface SceneModeViewController : UIViewController

@property(nonatomic, copy) NSString *scenceMode;
@property(nonatomic, assign) NSInteger lightFilterIndex;//拍摄模式（自动、白天、夜间）
@property(nonatomic ,assign) id<SceneModeViewControllerDelegate> delegate;
@end
