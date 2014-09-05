//
//  ShareCamereViewController.h
//  Toyshow
//
//  Created by zhxf on 14-3-24.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShareCamereViewController;
@protocol  ShareCamereViewControllerDelegate<NSObject>

- (void)playerViewBack:(NSString *)str;

- (void)cancelCameraCollection;

@end

@interface ShareCamereViewController : UIViewController<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollv;
@property (strong, nonatomic) UIImageView *imagev;

@property (nonatomic,assign) BOOL isLive;
@property (nonatomic,assign) BOOL isShare;
@property (nonatomic,assign) BOOL isCollect;
@property (nonatomic,assign) BOOL isWeixinShare;

@property (nonatomic,assign) int shareStaue;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *playerTitle;
@property (nonatomic,copy) NSString *stream_id;
@property (nonatomic,copy) NSString *accecc_token;
@property (nonatomic,copy) NSString *deviceId;
@property (nonatomic,assign) int startTimeInt;
@property (nonatomic,copy) NSString *request_id;
@property (nonatomic,assign) BOOL isCancelCollect;
@property (nonatomic,copy) NSString *shareId;
@property (nonatomic,copy) NSString *uk;

@property (nonatomic,assign) id <ShareCamereViewControllerDelegate> delegate;
@end
