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
@property (copy, nonatomic) NSString *uk;
@property (copy, nonatomic) NSString *access_token;
@property (assign, nonatomic) int index;
@property (nonatomic) BOOL isOnline;
@property (assign, nonatomic) BOOL isAuthorDevice;

@property (nonatomic, assign) int shareIndex;
@property(nonatomic, assign) NSInteger EnableEventIndex;//事件通知
@property(nonatomic, assign) NSInteger audioIndex;//音频
@property(nonatomic, assign) NSInteger videoRecordIndex;//视频录制
@property(nonatomic, assign) NSInteger flipImageIndex;//画面方向
@property(nonatomic, assign) NSInteger screneIndex;//场景（户内、户外）
@property(nonatomic, assign) NSInteger lightFilterModeIndex;//拍摄模式（自动、白天、夜间）
@property(nonatomic, assign) NSInteger lightStatueIndex;//状态灯
@property(nonatomic, assign) NSInteger streamBitrateIndex;//码流控制
@property(nonatomic, assign) NSInteger ntscOrpalIndex;//NTSC/PAL
@property(nonatomic, assign) NSInteger imageResolutionIndex;//分辨率
@property(nonatomic, assign) NSInteger iMainStreamUserOption;//清晰度
@property(nonatomic, assign) NSInteger controlONOrOFFIndex;//设备控制（睡眠、唤醒、关闭）
@property(nonatomic, assign) NSInteger sensitivityIndex;//检测灵敏度
@property(nonatomic, assign) NSInteger timeShowIndex;//时间是否显示

@property (nonatomic, assign) id<CameraSetViewControllerDelegate>delegate;

@end
