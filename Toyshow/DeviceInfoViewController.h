//
//  DeviceInfoViewController.h
//  Joyshow
//
//  Created by zhxf on 14-7-16.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceInfoViewController : UIViewController

@property (copy ,nonatomic) NSDictionary *deviceInfoDict;
@property (copy ,nonatomic) NSString *access_token;
@property (copy ,nonatomic) NSString *deviceid;

@end
