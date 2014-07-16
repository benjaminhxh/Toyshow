//
//  NightViewController.h
//  Joyshow
//
//  Created by zhxf on 14-7-16.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NightViewController : UIViewController

@property (copy ,nonatomic) NSString *access_token;
@property (copy ,nonatomic) NSString *deviceid;

@property (assign ,nonatomic) NSInteger filterIndex;
@property (assign ,nonatomic) NSInteger isenceIndex;
@end
