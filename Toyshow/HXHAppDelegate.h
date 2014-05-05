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

@interface HXHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(HXHAppDelegate*)instance;
@end
