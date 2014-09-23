//
//  ShareSetViewController.h
//  Joyshow
//
//  Created by xiaohuihu on 14-9-23.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareSetViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *shareStyle;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) int index;
@property (copy ,nonatomic) NSString *accecc_token;
@property (copy ,nonatomic) NSString *deviceId;
@property (copy ,nonatomic) NSString *cameraName;

@end
