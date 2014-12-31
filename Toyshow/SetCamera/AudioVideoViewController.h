//
//  AudioVideoViewController.h
//  Joyshow
//
//  Created by zhxf on 14-7-16.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioVideoViewController : UIViewController

@property (nonatomic, assign) BOOL isLow;
@property (copy ,nonatomic) NSString *access_token;
@property (copy ,nonatomic) NSString *deviceid;
@property (nonatomic, assign) BOOL audioIndex;
@property (nonatomic, copy) NSString *streamIndex;
@property (nonatomic, assign) NSInteger flipImageIndex;
@property (nonatomic, assign) NSInteger ntscOrPalIndex;//视频制式
@property (nonatomic, assign) NSInteger imageResolutionIndex;//图像分辨率
@property (nonatomic, assign) NSInteger iMainStreamUserOptionIndex;//清晰度
@property (nonatomic, assign) NSInteger iStreamFpsIndex;//帧率
@property (nonatomic, copy) NSString *iAudioVolIndex;//音量

@end
