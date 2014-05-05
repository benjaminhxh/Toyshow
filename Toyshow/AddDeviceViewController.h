//
//  AddDeviceViewController.h
//  NewProject
//
//  Created by zhxf on 14-3-5.
//  Copyright (c) 2014年 Steven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncUdpSocket.h"

@interface AddDeviceViewController : UIViewController
@property (nonatomic, copy) NSString *deviceID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *access_token;
@property (nonatomic, retain) AsyncUdpSocket         *udpSocket;

@end
