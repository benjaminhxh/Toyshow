//
//  MyCameraViewController.h
//  Toyshow
//
//  Created by zhxf on 14-3-19.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCameraViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *cameraPic;
@property (weak, nonatomic) IBOutlet UILabel *cameraTitle;
//@property (weak, nonatomic) IBOutlet UILabel *cameraId;
@property (weak, nonatomic) IBOutlet UILabel *cameraStatus;
@property (weak, nonatomic) NSString *userId;
@property (weak, nonatomic) NSString *accessToken;

@end
