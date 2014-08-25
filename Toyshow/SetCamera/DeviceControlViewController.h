//
//  DeviceControlViewController.h
//  DelegateTest
//
//  Created by zhxf on 14-6-16.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DeviceControlViewController;
@protocol DeviceControlViewControlDelegate <NSObject>

- (void) deviceControlMode:(NSString *)deviceMode withIndex:(NSInteger) index;

@end

@interface DeviceControlViewController : UIViewController

@property (nonatomic, copy) NSString *deviceMode;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) id<DeviceControlViewControlDelegate> delegate;
@end
