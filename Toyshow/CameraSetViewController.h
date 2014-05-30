//
//  CameraSetViewController.h
//  Toyshow
//
//  Created by zhxf on 14-3-10.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraSetViewController;
@protocol CameraSetViewControllerDelegate <NSObject>
- (void)logoutCameraAtindex:(int)index;
@end

@interface CameraSetViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *cellImage;
@property (weak, nonatomic) IBOutlet UILabel *cellLabelT;
@property (copy, nonatomic) NSString *deviceDesc;
@property (copy, nonatomic) NSString *deviceid;
@property (copy, nonatomic) NSString *access_token;
@property (assign, nonatomic) int index;
@property (nonatomic, assign) id<CameraSetViewControllerDelegate>delegate;

@end
