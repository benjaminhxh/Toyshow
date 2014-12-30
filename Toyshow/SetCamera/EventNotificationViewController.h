//
//  EventNotificationViewController.h
//  Joyshow
//
//  Created by zhxf on 14-7-16.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventNotificationViewController : UIViewController

@property (assign ,nonatomic) NSInteger sensityIndex;
//@property (assign ,nonatomic) NSInteger eventNotifIndex;
@property (copy ,nonatomic) NSString *access_token;
@property (copy ,nonatomic) NSString *deviceid;

@end
