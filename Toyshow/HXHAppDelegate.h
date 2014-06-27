//
//  HXHAppDelegate.h
//  Toyshow
//
//  Created by zhxf on 14-2-27.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "WXApi.h"
#import <Frontia/Frontia.h>
#import <Frontia/FrontiaShare.h>
#import <Frontia/FrontiaShareContent.h>
#import <Frontia/FrontiaShareDelegate.h>
@interface HXHAppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

+(HXHAppDelegate*)instance;
@end
