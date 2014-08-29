//
//  ShareCamereViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-24.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//
//摄像头直播

#import "ShareCamereViewController.h"
#import "CyberPlayerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "UIProgressView+AFNetworking.h"
#import "WXApi.h"
#import "WeixinSessionActivity.h"
#import "WeixinTimelineActivity.h"

//6227 0000 1616 0056 890
@interface ShareCamereViewController ()<MBProgressHUDDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
//    UIView *cbdPlayerView;
    CyberPlayerController *cbPlayerController;
    UIButton *startBtn, *shareBtn,*secretShareBtn,*collectionBtn,*cutBtn,*volumeBtn;
    UISlider *lightSlider,*slider;
    NSTimer *timer,*localTimer,*_timer3;
//    UIProgressView *progressV;
    UIImageView *topView,*bottomView;
    BOOL topViewHidden,lightBool;
    UILabel *titleL,*currentProgress,*remainsProgress;
    MBProgressHUD *_loadingView,*shareHub;
    UILabel *timeL;
    MPVolumeView *volumView;
    UIView *tapView;
    UIAlertView *publicView,*cancelShareView,*resultView, *cutimageView;
    NSArray *activity;
    UIActivityIndicatorView *indicatorView;
}
@end

@implementation ShareCamereViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //隐藏状态条
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];  
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade]; 
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    //设置旋转动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    //设置视图旋转
    self.view.bounds = CGRectMake(0, 0, kWidth,kHeight);
    NSLog(@"kwidth:%f===========,kheight:%f",kWidth,kHeight);
    self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    [UIView commitAnimations];
    self.view.backgroundColor = [UIColor whiteColor];

    self.scrollv = [[UIScrollView alloc] init];
    self.scrollv.backgroundColor = [UIColor blackColor];
    if (iOS7) {
        self.scrollv.frame = CGRectMake( 0, 0, kHeight, kWidth );
    }else
    {
        self.scrollv.frame = CGRectMake( 0, 0, kHeight, kWidth );
    }
    self.scrollv.delegate = self;
    [self.view addSubview: self.scrollv ];
    self.imagev = [[UIImageView alloc] initWithFrame:self.view.frame];
//    self.imagev.backgroundColor = [UIColor redColor];
    self.imagev.userInteractionEnabled = YES;
    [self.scrollv addSubview: self.imagev];
    [self loadScaleImage];
//    cbdPlayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kHeight, kWidth)];
    //添加百度开发者中心应用对应的APIKey和SecretKey。
    //添加开发者信息
    [[CyberPlayerController class ]setBAEAPIKey:msAK SecretKey:msSK ];
    //当前只支持CyberPlayerController的单实例
    cbPlayerController = [[CyberPlayerController alloc] init];
    
//    NSString *SDKVerion = [cbPlayerController getSDKVersion];
//    NSLog(@"SDKVersion:%@",SDKVerion);
    //设置视频显示的位置
    [cbPlayerController.view setFrame: self.imagev.frame];
//    cbPlayerController.scalingMode = CBPMovieScalingModeFill;
    //将视频显示view添加到当前view中
    [self.imagev addSubview:cbPlayerController.view];
    
    //注册监听，当播放器完成视频的初始化后会发送CyberPlayerLoadDidPreparedNotification通知，
    //此时naturalSize/videoHeight/videoWidth/duration等属性有效。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onpreparedListener:)
                                                 name: CyberPlayerLoadDidPreparedNotification
                                               object:nil];
    //注册监听，当播放器完成视频播放位置调整后会发送CyberPlayerSeekingDidFinishNotification通知，
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(seekComplete:)
                                                 name:CyberPlayerSeekingDidFinishNotification
                                               object:nil];
    //注册监听，当播放器播放完视频后发送CyberPlayerPlaybackDidFinishNotification通知，
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerBackDidFinish:)
                                                 name:CyberPlayerPlaybackDidFinishNotification
                                               object:nil];
    //注册监听，当播放器播放失败后发送CyberPlayerPlaybackErrorNotification通知，
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerBackError:)
                                                 name:CyberPlayerPlaybackErrorNotification
                                               object:nil];

    
    //注册监听，当播放器开始缓冲时发送通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startCaching:)
                                                 name:CyberPlayerStartCachingNotification
                                               object:nil];
    //播放状态发生改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stateDidChange:)
                                                 name:CyberPlayerPlaybackStateDidChangeNotification
                                               object:nil];

    //注册监听，当播放器缓冲视频过程中不断发送该通知。
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(GotCachePercent:)
//                                                 name:CyberPlayerGotCachePercentNotification
//                                               object:nil];

    
    //系统音量
    volumView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-55, 140, 200, 34)];
//    volumView.showsRouteButton=NO;
//    UISlider *volumeSlider=nil;
    
//    for (id aView in volumView.subviews) {
//        
//        if ([[[aView class] description] isEqualToString:@"MPVolumeSlider"]) {
//            
//            volumeSlider=(UISlider *)aView;
//            break;
//        }
//    }
    [volumView setVolumeThumbImage:[UIImage imageNamed:@"anniu_huagan16x16@2x"] forState:UIControlStateNormal];
    volumView.transform = CGAffineTransformMakeRotation(3*M_PI_2);
//    volumView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:volumView];
    volumView.hidden = YES;
    
    //顶部条
    topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kHeight, 44)];
    //    topView.image = [UIImage imageNamed:@"keyboard_number_bg@2x"];
    topView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(12, 12, 36, 20);
//    backBtn.frame = CGRectMake(10, [UIApplication sharedApplication].statusBarFrame.size.height+5, 12, 22);
    [backBtn setImage:[UIImage imageNamed:@"fanhui_jiantou@2x"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    //标题
    titleL = [[UILabel alloc] initWithFrame:CGRectMake(45, 12, kWidth-45-20, 20)];
    titleL.textColor = [UIColor whiteColor];
    titleL.backgroundColor = [UIColor clearColor];
    titleL.font = [UIFont systemFontOfSize:12];
    titleL.text = self.playerTitle;
    [topView addSubview:titleL];
    
    //显示实时时间
    timeL = [[UILabel alloc] initWithFrame:CGRectMake(kHeight/2-20, 10, 40, 15)];
    timeL.text = @"12:12:12";
    timeL.font = [UIFont systemFontOfSize:9];
    timeL.textColor = [UIColor whiteColor];
    timeL.backgroundColor = [UIColor clearColor];
    [topView addSubview:timeL];

    //直播
//    if (self.isLive) {
//        if (self.isShare) {
            //分享和收藏的摄像头
            //收藏、转发
//            if ([self checkAccessTokenIsExist]) {
                //转发
//                forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [forwardBtn setImage:[UIImage imageNamed:@"zhuanfa_wei@2x"] forState:UIControlStateNormal ];
//                [forwardBtn setImage:[UIImage imageNamed:@"zhuanfa_zhong@2x"] forState:UIControlStateHighlighted];
//                [forwardBtn addTarget:self action:@selector(forwardClick) forControlEvents:UIControlEventTouchUpInside];
//                [topView addSubview:forwardBtn];
                //收藏
                collectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                if (self.isCollect) {
                    [collectionBtn setImage:[UIImage imageNamed:@"collect_cancelwei"] forState:UIControlStateNormal];
                    [collectionBtn setImage:[UIImage imageNamed:@"collect_cancelzhong"] forState:UIControlStateHighlighted];
                }else{
                    [collectionBtn setImage:[UIImage imageNamed:@"collect_wei"] forState:UIControlStateNormal];
                    [collectionBtn setImage:[UIImage imageNamed:@"collect_zhong"] forState:UIControlStateHighlighted];
                }
                [collectionBtn addTarget:self action:@selector(collectClick) forControlEvents:UIControlEventTouchUpInside];
                [topView addSubview:collectionBtn];
                if (iphone5) {
//                    forwardBtn.frame = CGRectMake(kHeight*23/32, 11, 46, 24);
                    collectionBtn.frame = CGRectMake(kHeight*26/32, 11, 46, 24);
                }else
                {
//                    forwardBtn.frame = CGRectMake(kHeight/2+30+50, 11, 46, 24);
                    collectionBtn.frame = CGRectMake(kHeight/2+30+100, 11, 46, 24);
                }
//            }
//        }else{
            //我的摄像头直播
            //公共分享、私密分享、截图、对讲
            //公共
            shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [topView addSubview:shareBtn];
            //私密
            secretShareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [secretShareBtn setImage:[UIImage imageNamed:@"secretShare_wei@2x"] forState:UIControlStateNormal ];
            [secretShareBtn setImage:[UIImage imageNamed:@"secretShare_zhong@2x"] forState:UIControlStateHighlighted];
            [secretShareBtn addTarget:self action:@selector(forwardClick) forControlEvents:UIControlEventTouchUpInside];
            [topView addSubview:secretShareBtn];
            //截图
            cutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [cutBtn setImage:[UIImage imageNamed:@"jietu_wei@2x"] forState:UIControlStateNormal];
            [cutBtn setImage:[UIImage imageNamed:@"jietu_zhong@2x"] forState:UIControlStateHighlighted];
            [cutBtn addTarget:self action:@selector(cutPrint) forControlEvents:UIControlEventTouchUpInside];
            [topView addSubview:cutBtn];
            //音量
            volumeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [volumeBtn setImage:[UIImage imageNamed:@"yinliang_wei"] forState:UIControlStateNormal];
            [volumeBtn setImage:[UIImage imageNamed:@"yinliang_zhong"] forState:UIControlStateHighlighted];
            [volumeBtn addTarget:self action:@selector(volumeBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [topView addSubview:volumeBtn];
            if (iphone5) {
                shareBtn.frame = CGRectMake(kHeight*5/8, 11, 46, 24);
                secretShareBtn.frame = CGRectMake(kHeight*23/32, 11, 46, 24);
                cutBtn.frame = CGRectMake(kHeight*26/32, 11, 46, 24);
                volumeBtn.frame = CGRectMake(kHeight*29/32, 11, 46, 24);
            }else
            {
                shareBtn.frame = CGRectMake(kHeight/2+30, 11, 46, 24);
                secretShareBtn.frame = CGRectMake(kHeight/2+30+50, 11, 46, 24);
                cutBtn.frame = CGRectMake(kHeight/2+30+100, 11, 46, 24);
                volumeBtn.frame = CGRectMake(kHeight/2+30+150, 11, 46, 24);
            }
            if (self.shareStaue) {
                [shareBtn setImage:[UIImage imageNamed:@"fenxiang_cancelwei@2x"] forState:UIControlStateNormal];
                [shareBtn setImage:[UIImage imageNamed:@"fenxiang_cancelzhong@2x"] forState:UIControlStateHighlighted];
                
            }else{
                [shareBtn setImage:[UIImage imageNamed:@"publicShare_wei@2x"] forState:UIControlStateNormal];
                [shareBtn setImage:[UIImage imageNamed:@"publicShare_zhong@2x"] forState:UIControlStateHighlighted];
            }
            [shareBtn addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
//        }
//    }
//    else{
        //点播(看录像)
        //底部条
        bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kWidth-60, kHeight, 60)];
        bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        bottomView.userInteractionEnabled = YES;
        [self.view addSubview:bottomView];
        //开始暂停按钮
        startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        startBtn.frame = CGRectMake(kHeight/2-14, 5, 27, 27);
        [startBtn setImage:[UIImage imageNamed:@"bofang_anniu@2x"] forState:UIControlStateNormal];
        [startBtn addTarget:self action:@selector(onClickPlay:) forControlEvents:UIControlEventTouchUpInside];
        //        [startBtn setImage:[UIImage imageNamed:@"bofang_zhong@2x"] forState:UIControlStateHighlighted];
        [bottomView addSubview:startBtn];
        //当前播放的时刻
        currentProgress = [[UILabel alloc] initWithFrame:CGRectMake(20, 43, 40, 10)];
//        currentProgress.backgroundColor = [UIColor redColor];
        currentProgress.textColor = [UIColor whiteColor];
        currentProgress.text = @"00:00:00";
    currentProgress.backgroundColor = [UIColor clearColor];
        currentProgress.font = [UIFont systemFontOfSize:8];
        [bottomView addSubview:currentProgress];
        //剩余时长
        remainsProgress = [[UILabel alloc] initWithFrame:CGRectMake(kHeight-45, 43, 40, 10)];
        remainsProgress.textColor = [UIColor whiteColor];
//        remainsProgress.backgroundColor = [UIColor grayColor];
//        remainsProgress.text = @"01:52:10";
        remainsProgress.font = [UIFont systemFontOfSize:8];
    remainsProgress.backgroundColor = [UIColor clearColor];
        [bottomView addSubview:remainsProgress];
        
        //下载进度条
//        progressV = [[UIProgressView alloc] initWithFrame:CGRectMake(60, 47, kHeight - 105, 2)];
//        progressV.progressViewStyle = UIProgressViewStyleBar;
////        progressV.progress = 0.5;
//        //        progressV.trackTintColor = [UIColor redColor];//未缓冲的
//        progressV.progressTintColor = [UIColor grayColor];
//        [bottomView addSubview:progressV];

        //快进快退滑动条
        slider = [[UISlider alloc] initWithFrame:CGRectMake(60, 35, kHeight - 105, 25)];
//        slider.continuous = NO;
        [slider setThumbImage:[UIImage imageNamed:@"anniu_huagan16x16@2x"] forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(onDragSlideValueChanged:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(onDragSlideStart:) forControlEvents:UIControlEventTouchDown];
        [slider addTarget:self action:@selector(onDragSlideDone:) forControlEvents:UIControlEventTouchUpInside];
//        slider.backgroundColor = [UIColor blueColor];
        [bottomView addSubview:slider];
//        [self startPlayback];
//    }

//    indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(140, 120, 137, 137)];
//    [self.view addSubview:indicatorView];
//    indicatorView.backgroundColor = [UIColor lightGrayColor];
//    [indicatorView startAnimating];
//    [self isLoadingView];

//    tapView = [[UIView alloc] initWithFrame:CGRectMake(70, 50, kHeight-80, kWidth-60-60)];
//    tapView.backgroundColor = [UIColor redColor];
//    [cbPlayerController.view addSubview:tapView];
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenOrNo:)];
    [cbPlayerController.view addGestureRecognizer:tapGest];
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
//    doubleTap.numberOfTapsRequired = 2;
//    [cbPlayerController.view addGestureRecognizer:doubleTap];
//    [tapGest requireGestureRecognizerToFail:doubleTap];
    //进入home后台的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willBackToHomeNotification:) name:kAPPWillResignActivenotif object:nil];
}

- (void)adjustIsShareOrVod
{
    titleL.text = self.playerTitle;
    localTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    self.request_id = @"";
    [self isLoadingView];
    volumView.hidden = YES;
    //直播
    if (self.isLive) {
        if (self.isShare) {
            //分享和收藏的摄像头
            //收藏、转发
            if ([self checkAccessTokenIsExist]) {
                self.isCancelCollect = NO;
                //已经登录
                if (self.isCollect) {
                    [collectionBtn setImage:[UIImage imageNamed:@"collect_cancelwei@2x"] forState:UIControlStateNormal];
                    [collectionBtn setImage:[UIImage imageNamed:@"collect_cancelzhong@2x"] forState:UIControlStateHighlighted];
                }else{
                    [collectionBtn setImage:[UIImage imageNamed:@"collect_wei@2x"] forState:UIControlStateNormal];
                    [collectionBtn setImage:[UIImage imageNamed:@"collect_zhong@2x"] forState:UIControlStateHighlighted];
                }
//                forwardBtn.hidden = NO;
                collectionBtn.hidden = NO;
                
            }else{
//                forwardBtn.hidden = YES;
                collectionBtn.hidden = YES;
            }

            shareBtn.hidden = YES;
            secretShareBtn.hidden = YES;
            cutBtn.hidden = YES;
            bottomView.hidden = YES;
        }else{
            //我的摄像头直播
            if (self.shareStaue) {
                [shareBtn setImage:[UIImage imageNamed:@"fenxiang_cancelwei@2x"] forState:UIControlStateNormal];
                [shareBtn setImage:[UIImage imageNamed:@"fenxiang_cancelzhong@2x"] forState:UIControlStateHighlighted];
                
            }else{
                [shareBtn setImage:[UIImage imageNamed:@"publicShare_wei@2x"] forState:UIControlStateNormal];
                [shareBtn setImage:[UIImage imageNamed:@"publicShare_zhong@2x"] forState:UIControlStateHighlighted];
            }
//            forwardBtn.hidden = YES;
            collectionBtn.hidden = YES;
            shareBtn.hidden = NO;
            secretShareBtn.hidden = NO;
            cutBtn.hidden = NO;
            bottomView.hidden = YES;
        }
    }else{
        //点播
//        forwardBtn.hidden = YES;
        collectionBtn.hidden = YES;
        shareBtn.hidden = YES;
        secretShareBtn.hidden = YES;
        cutBtn.hidden = YES;
        bottomView.hidden = NO;
        currentProgress.text = @"00:00:00";
        remainsProgress.text = @"00:00:00";
        slider.value = 0.0;
    }
    
}
- (void)willBackToHomeNotification:(NSNotificationCenter *)notif
{
    NSLog(@"这是退出的通知：postNotificationName");
    [self stopPlayback];
    if ([localTimer isValid]) {
        [localTimer invalidate];
    }
    localTimer = nil;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)onDragSlideValueChanged:(id)sender {
    NSLog(@"slide changing, %f", slider.value);
    [self refreshProgress:slider.value totalDuration:cbPlayerController.duration];
    //    NSLog(@"slider changing :%f",slider.progress);11/13
    //    [self refreshProgress:slider.progress totalDuration:cbPlayerController.duration];
}

- (void)onDragSlideDone:(id)sender {
    float currentTIme = slider.value;
    NSLog(@"seek to %f", currentTIme);
    //实现视频播放位置切换，
    [cbPlayerController seekTo:currentTIme];
    //两种方式都可以实现seek操作
    [cbPlayerController setCurrentPlaybackTime:currentTIme];
}
- (void)onDragSlideStart:(id)sender {
    [self isLoadingView];

    [self stopTimer];//12
}

//视频文件完成初始化，开始播放视频并启动刷新timer。1
- (void)onpreparedListener: (NSNotification*)aNotification
{
    [self performSelectorOnMainThread:@selector(hiddenLoadingView) withObject:nil waitUntilDone:NO];
    [self startTimer];
}

//开始缓冲
- (void)startCaching:(NSNotification*)botif
{
//    [self startTimer];
    NSLog(@"开始缓冲startCachhhhhhhhhhhhhh");
//    [self isLoadingView];
}

- (void)hiddenLoadingView
{
    _loadingView.hidden = YES;
}

//完成视频播放位置调整
- (void)seekComplete:(NSNotification*)notification
{
    NSLog(@"完成视频播放位置调整seekComplete--%@",[NSThread isMainThread]?@"isMainThread":@"Not mainThread");
    [self performSelectorOnMainThread:@selector(hiddenLoadingView) withObject:nil waitUntilDone:NO];
    [self startTimer];
}

//播放完成
- (void)playerBackDidFinish:(NSNotification *)notif
{
//    UIAlertView *finishView = [[UIAlertView alloc] initWithTitle:@"播放完成" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
//    [finishView show];
    NSLog(@"播放完成");
}

//播放失败
- (void)playerBackError:(NSNotification *)notifa
{
    [self performSelectorOnMainThread:@selector(hiddenLoadingView) withObject:nil waitUntilDone:NO];
    UIAlertView *playError = [[UIAlertView alloc] initWithTitle:@"播放失败" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
    [playError show];
    NSLog(@"播放失败");
}
//状态改变
- (void)stateDidChange:(NSNotification*)notif
{
    NSLog(@"播放状态发送改变stateDidChange--%@",[NSThread isMainThread]?@"isMainThread":@"Not mainThread");
    if (self.isLive) {
       if(cbPlayerController.playbackState == CBPMoviePlaybackStatePaused){
           [cbPlayerController play];
        }
    }
}
//缓冲过程
//- (void)GotCachePercent:(NSNotification *)notific
//{
//    NSLog(@"GotCachePercent--%@",[NSThread isMainThread]?@"isMainThread":@"Not mainThread");
//    dispatch_async(dispatch_get_main_queue(), ^{
//    _loadingView.hidden = NO;
//    });
////    [self startTimer];
//}
- (void)onClickPlay:(id)sender {
    //当按下播放按钮时，调用startPlayback方法
    [self startPlayback];
}

- (void)onClickStop:(id)sender {
    [self stopPlayback];
}
- (void)startPlayback{
//    NSURL *url = [NSURL URLWithString:@"rtmp://livertmppc.wasu.cn/live/dfws"];
//    NSURL *url = [NSURL URLWithString:@"http://119.188.2.50/data2/video04/2013/04/27/00ab3b24-74de-432b-b703-a46820c9cd6f.mp4"];
    NSURL *url = [NSURL URLWithString:self.url];
    switch (cbPlayerController.playbackState) {
        case CBPMoviePlaybackStateStopped:
        case CBPMoviePlaybackStateInterrupted:
            [cbPlayerController setContentURL:url];
            //初始化完成后直接播放视频，不需要调用play方法
            cbPlayerController.shouldAutoplay = YES;
            //初始化视频文件
            [cbPlayerController prepareToPlay];
            [startBtn setImage:[UIImage imageNamed:@"bofang_anniu@2x"] forState:UIControlStateNormal];
            break;
        case CBPMoviePlaybackStatePlaying:
            //如果当前正在播放视频时，暂停播放。
            [cbPlayerController pause];
            [startBtn setImage:[UIImage imageNamed:@"zanting_anniu@2x"] forState:UIControlStateNormal];
            break;
        case CBPMoviePlaybackStatePaused:
            //如果当前播放视频已经暂停，重新开始播放。
            [cbPlayerController start];
            [startBtn setImage:[UIImage imageNamed:@"bofang_anniu@2x"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (void)timerHandler:(NSTimer*)timer
{
    [self refreshProgress:cbPlayerController.currentPlaybackTime totalDuration:cbPlayerController.duration];
//    [self refreshCurrentProgress:cbPlayerController.playableDuration totalDuration:cbPlayerController.duration];//当前可播放视频的长度4/6
//    NSLog(@"timeHanler");
}

- (void)refreshProgress:(int) currentTime totalDuration:(int)allSecond{
//    NSLog(@"refreshProgress");//4/7
    NSInteger startT = self.startTimeInt + currentTime;//得到起始时间戳
//    NSLog(@"currentTime:%d---allSecond:%d",currentTime,allSecond);
    NSDictionary* dict = [[self class] convertSecond2HourMinuteSecond:startT];
    NSString* strPlayedTime = [self getTimeString:dict prefix:@""];
    currentProgress.text = strPlayedTime;
//    NSLog(@"strPlayedTime:%@",strPlayedTime);
//    NSLog(@"公共摄像头当前下载速度：%f",cbPlayerController.downloadSpeed);
    NSDictionary* dictLeft = [[self class] convertSecond2HourMinuteSecond:allSecond - currentTime];
    NSString* strLeft = [self getTimeString:dictLeft prefix:@"-"];
    remainsProgress.text = strLeft;
    slider.value = currentTime;
    slider.maximumValue = allSecond;
}

+ (NSDictionary*)convertSecond2HourMinuteSecond:(int)second
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    int hour = 0, minute = 0;
    hour = second / 3600;
    minute = (second - hour * 3600) / 60;
    second = second - hour * 3600 - minute *  60;
    
    [dict setObject:[NSNumber numberWithInt:hour] forKey:@"hour"];
    [dict setObject:[NSNumber numberWithInt:minute] forKey:@"minute"];
    [dict setObject:[NSNumber numberWithInt:second] forKey:@"second"];
    return dict;
}

- (NSString*)getTimeString:(NSDictionary*)dict prefix:(NSString*)prefix
{
    int hour = [[dict objectForKey:@"hour"] intValue];
    int minute = [[dict objectForKey:@"minute"] intValue];
    int second = [[dict objectForKey:@"second"] intValue];
    
    NSString* formatter = hour < 10 ? @"0%d" : @"%d";
    NSString* strHour = [NSString stringWithFormat:formatter, hour];
    
    formatter = minute < 10 ? @"0%d" : @"%d";
    NSString* strMinute = [NSString stringWithFormat:formatter, minute];
    
    formatter = second < 10 ? @"0%d" : @"%d";
    NSString* strSecond = [NSString stringWithFormat:formatter, second];
    
    return [NSString stringWithFormat:@"%@%@:%@:%@", prefix, strHour, strMinute, strSecond];
}

- (void)startTimer{
    //为了保证UI播放进度刷新在主线程中完成
    NSLog(@"startTimer：isLive：%d",self.isLive);
    if (_isLive) {
        return;
    }else
    {
        [self performSelectorOnMainThread:@selector(startTimeroOnMainThread) withObject:nil waitUntilDone:NO];
    }
//    NSLog(@"公共摄像头当前下载速度：%f",cbPlayerController.downloadSpeed);
}

//缓冲完也会进这个函数
//只有这里主线程可以停掉loading
- (void)startTimeroOnMainThread{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];
//    NSLog(@"公共摄像头当前下载速度：%f",cbPlayerController.downloadSpeed);3
}

- (void)stopTimer{
    if ([timer isValid])
    {
        [timer invalidate];
    }
    if (_timer3 && [_timer3 isValid]) {
        [_timer3 invalidate];
    }
    timer = nil;
    _timer3 = nil;
}

- (void)stopPlayback{
    //停止视频播放
    [cbPlayerController stop];
    [startBtn setImage:[UIImage imageNamed:@"zanting_anniu@2x"] forState:UIControlStateNormal];
    [self stopTimer];
}

//返回
- (void)backBtn:(id)sender
{
    [self stopPlayback];
    if ([localTimer isValid]) {
        [localTimer invalidate];
    }
    localTimer = nil;
    if (![self.request_id isEqualToString:@""]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerViewBack:)]) {
            [self.delegate playerViewBack:@"hello"];
        }
    }else if (self.isCancelCollect){
        if (self.delegate && [self.delegate respondsToSelector:@selector(cancelCameraCollection)]) {
            [self.delegate cancelCameraCollection];
        }
    }else
    {
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//弹出或隐藏设置按钮
- (void)hiddenOrNo:(id)sender
{
    if (topViewHidden) {
        if (_timer3 && [_timer3 isValid]) {
            [_timer3 invalidate];
        }
        _timer3 = nil;
        [UIView animateWithDuration:0.15 animations:^{
            topView.frame = CGRectMake(0, -44, kHeight, 44);
            bottomView.frame = CGRectMake(0, kWidth+60, kHeight, 60);
            volumView.hidden = YES;
        }];
        topViewHidden = !topViewHidden;
        return;
    }else{
        [UIView animateWithDuration:0.15 animations:^{
            topView.frame = CGRectMake(0, 0, kHeight, 44);
            bottomView.frame = CGRectMake(0, kWidth-60, kHeight, 60);
        }];
        topViewHidden = !topViewHidden;
        _timer3=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(didTimer) userInfo:nil repeats:NO];
        return;
    }
}

//自动隐藏菜单栏和播放控制条
- (void)didTimer
{
    [UIView transitionWithView:bottomView duration:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        bottomView.frame = CGRectMake(0, kWidth+44, kHeight, 44);
    } completion:^(BOOL finished) {

    }];
    
    [UIView transitionWithView:topView duration:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        topView.frame = CGRectMake(0, -44, kHeight, 44);
    } completion:^(BOOL finished) {
        
    }];
    topViewHidden = !topViewHidden;
}

#define mark - SetMethod
- (void)collectClick    //收藏
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kUserAccessToken];
    NSString *method;
    if (self.isCollect) {
        method = @"unsubscribe";
        [self MBprogressViewHubLoading:@"取消收藏" withMode:4];

    }else
    {
        method = @"subscribe";
        [self MBprogressViewHubLoading:@"正在收藏" withMode:4];

    }
    NSString *url = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=%@&access_token=%@&shareid=%@&uk=%@",method,accessToken,self.shareId,self.uk];
    NSLog(@"收藏的URL：%@",url);
    [[AFHTTPRequestOperationManager manager]POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary*)responseObject;
        NSLog(@"收藏的dict:%@",dict);
        if (self.isCollect) {
//            [self MBprogressViewHubLoading:@"已取消收藏" withMode:4];
            [self showResultAlertView:@"已取消收藏"];
            self.isCancelCollect = YES;
        }else
        {
//            [self MBprogressViewHubLoading:@"收藏成功" withMode:4];
            [self showResultAlertView:@"收藏成功"];
        }
        [shareHub hide:YES afterDelay:0.5];

//        self.isCollect = !self.isCollect;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"收藏的error：%@",[error userInfo]);
//        [self MBprogressViewHubLoading:@"操作失败" withMode:4];
        [self showResultAlertView:@"操作失败"];
        [shareHub hide:YES afterDelay:0.5];
    }];
}

- (void)shareClick  //分享
{
    if (self.shareStaue) {
        //取消分享
        cancelShareView = [[UIAlertView alloc] initWithTitle:@"取消该摄像头分享" message:@"取消分享之后，摄像头将不在公共摄像头列表中，转发给好友的也不可再播放，收藏的该摄像头也将消失，当前直播也会中段一会，请回到上一级页面重新加载" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [cancelShareView show];
    }else
    {
        publicView = [[UIAlertView alloc] initWithTitle:@"分享摄像头" message:@"分享之后所有人都可见,直到您取消分享或者私密分享" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [publicView show];
    }
}

#pragma mark - 转发（私密分享）
- (void)forwardClick    //转发
{
//    _loadingView.hidden = NO;
    NSString *userAccessToken = [[NSUserDefaults standardUserDefaults]stringForKey:kUserAccessToken];
    NSString *url = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=createshare&access_token=%@&deviceid=%@&share=2",userAccessToken,self.deviceId];//share=2为加密分享
    [[AFHTTPRequestOperationManager manager] POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [shareBtn setImage:[UIImage imageNamed:@"publicShare_wei@2x"] forState:UIControlStateNormal];
        [shareBtn setImage:[UIImage imageNamed:@"publicShare_zhong@2x"] forState:UIControlStateHighlighted];

        NSDictionary *dict = (NSDictionary *)responseObject;
        NSString *shareID = [dict objectForKey:@"shareid"];
        NSString *uk = [dict objectForKey:@"uk"];
        NSString *playURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=liveplay&shareid=%@&uk=%@",shareID,uk];
        NSURL *shareURL = [NSURL URLWithString:playURL];
        activity = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init]];
        NSString *title = [NSString stringWithFormat:@"精彩乐现-%@",self.playerTitle];
        NSArray *shareArr = [NSArray arrayWithObjects:title,@"hxh乐现是由北京中和讯飞开发的一款家居类APP，它可以让你身在千里之外都能随时观看家中情况，店铺情况，看你所看。", [UIImage imageNamed:@"icon_session"], shareURL,nil];
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:shareArr applicationActivities:activity];
        activityView.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint,UIActivityTypeSaveToCameraRoll,UIActivityTypeMail];
        [self presentViewController:activityView animated:YES completion:nil];
        self.shareStaue = 2;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error++++++++");
    }];
}

- (void)cutPrint    //截图
{
    if (cutimageView) {
        [cutimageView show];
        return;
    }
    cutimageView = [[UIAlertView alloc] initWithTitle:@"截图" message:@"请同时按住电源键和home键来截屏" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [cutimageView show];
//    UIGraphicsBeginImageContext(cbPlayerController.view.bounds.size);
//    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//    //自动保存到图片库
//    UIImage *image2 = [self screenshot:UIDeviceOrientationPortrait
//            isOpaque:YES
//usePresentationLayer:YES];
//    UIGraphicsBeginImageContext(cbPlayerController.view.bounds.size);
//    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
////    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    UIImageWriteToSavedPhotosAlbum(image2, nil, nil, nil);
}

////新增截屏代码（未测试）
- (UIImage *)screenshot:(UIDeviceOrientation)orientation isOpaque:(BOOL)isOpaque usePresentationLayer:(BOOL)usePresentationLayer
{
    CGSize size;
    
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
        size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    } else {
        size = CGSizeMake(self.view.frame.size.height, self.view.frame.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(size, isOpaque, 0.0);
    if (usePresentationLayer) {
        [self.view.layer.presentationLayer renderInContext:UIGraphicsGetCurrentContext()];
    } else {
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
- (void)volumeBtnClick  //音量
{
    if (volumView.hidden) {
        volumView.hidden = NO;
    }else
    {
        volumView.hidden = YES;
    }
}

- (void)hiddenView
{
    [UIView animateWithDuration:0.3 animations:^{
        topView.frame = CGRectMake(0, -44, kHeight, 44);
        bottomView.frame = CGRectMake(0, kWidth+44, kHeight, 44);
    }];
}

- (void)isLoadingView
{
    if (_loadingView) {
        _loadingView.hidden = NO;
        return;
    }
    _loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    _loadingView.delegate = self;
    _loadingView.labelText = @"loading";
    _loadingView.detailsLabelText = @"视频加载中，请稍后……";
    _loadingView.square = YES;
    [_loadingView show:YES];
    [cbPlayerController.view addSubview:_loadingView];
}

//定时器实时更新时间
- (void)updateTime:(id)sender
{
    NSDate *timeDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"HH:mm:ss"];
    NSString *localTime = [formate stringFromDate:timeDate];
//    NSLog(@"localTime:%@",localTime);
    timeL.text = localTime;
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (publicView == alertView) {
        if (buttonIndex) {
            NSLog(@"公共分享alertView");
            //https://pcs.baidu.com/rest/2.0/pcs/device?method=register&deviceid=123456&access_token=52.68c5177d0382475c0162e3aa5b3d5a22.2592000.1403763927.1812238483-2271149&device_type=1&desc=hello
            [self publicShareCamera];
        }
    }else{
        //取消分享
        if (buttonIndex) {
            [self cancelShareCamera];
        }
    }
}

#pragma mark - 公共分享
- (void)publicShareCamera
{
    NSString *url = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=createshare&access_token=%@&deviceid=%@&share=1",self.accecc_token,self.deviceId];//share=1为公共分享
    [self MBprogressViewHubLoading:@"分享……" withMode:0];

    [[AFHTTPRequestOperationManager manager] POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSLog(@"公共分享的dict:%@",dict);
//        NSString *shareid = [dict objectForKey:@"shareid"];
//        NSLog(@"shareid:%@",shareid);
        self.request_id =[NSString stringWithFormat:@"%@",[dict objectForKey:@"request_id"]];
        self.shareStaue = 1;
        [shareBtn setImage:[UIImage imageNamed:@"fenxiang_cancelwei@2x"] forState:UIControlStateNormal];
        [shareBtn setImage:[UIImage imageNamed:@"fenxiang_cancelzhong@2x"] forState:UIControlStateHighlighted];
        [self MBprogressViewHubLoading:@"分享成功" withMode:4];
        [shareHub hide:YES afterDelay:1];
        //{“shareid”:SHARE_ID, “uk”:UK, “request_id”:12345678}
        /*
         {
         "request_id" = 2869117991;
         share = 1;
         shareid = 39337debf90f3edfc3374ccfca12fbcb;
         2 = 474433575;
         }
         */
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error:%@",[error userInfo]);
        [self MBprogressViewHubLoading:@"分享失败" withMode:4];
        [shareHub hide:YES afterDelay:1];
//        self.shareStaue = 0;
    }];
}

#pragma mark - 取消分享
- (void)cancelShareCamera
{
    NSString *url = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=cancelshare&access_token=%@&deviceid=%@",self.accecc_token,self.deviceId];
    [self MBprogressViewHubLoading:@"取消分享……" withMode:0];
    [[AFHTTPRequestOperationManager manager] POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"取消分享之后:%@",responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        self.request_id =[NSString stringWithFormat:@"%@",[dict objectForKey:@"request_id"]];
        [self MBprogressViewHubLoading:@"成功取消分享" withMode:4];
        [shareHub hide:YES afterDelay:1];

        self.shareStaue = 0;
        [shareBtn setImage:[UIImage imageNamed:@"publicShare_wei@2x"] forState:UIControlStateNormal];
        [shareBtn setImage:[UIImage imageNamed:@"publicShare_zhong@2x"] forState:UIControlStateHighlighted];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view setNeedsDisplay];
        });

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error:%@",[error userInfo]);
        [self MBprogressViewHubLoading:@"取消分享失败" withMode:4];
        [shareHub hide:YES afterDelay:1];

    }];
}

#pragma mark - scaleView
// 加载图片
- (void)loadScaleImage
{
    CGFloat origin_x = abs(self.scrollv.frame.size.width - self.imagev.frame.size.width)/2.0;
    CGFloat origin_y = abs(self.scrollv.frame.size.height - self.imagev.frame.size.height)/2.0;
    self.imagev.frame = CGRectMake(origin_x, origin_y, self.imagev.frame.size.width,self.imagev.frame.size.height);
    
    CGSize maxSize = self.scrollv.frame.size;
    CGFloat widthRatio = maxSize.width/self.imagev.frame.size.width;
    CGFloat heightRatio = maxSize.height/self.imagev.frame.size.height;
    CGFloat initialZoom = (widthRatio > heightRatio) ? heightRatio : widthRatio;

    [self.scrollv setMinimumZoomScale:initialZoom];
    [self.scrollv setMaximumZoomScale:5];
    // 设置UIScrollView初始化缩放级别
    [self.scrollv setZoomScale:initialZoom];
}

- (void)doubleTapAction:(UITapGestureRecognizer *)tapGest
{
    [UIView animateWithDuration:0.3 animations:^{
        self.imagev.frame = CGRectMake(0,0,kHeight,kWidth);
    }];
}
// 设置UIScrollView中要缩放的视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imagev;
}

// 让UIImageView在UIScrollView缩放后居中显示
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.imagev.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                     scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)MBprogressViewHubLoading:(NSString *)labtext withMode:(int)mode
{
    if (shareHub) {
        shareHub.mode = mode;
        shareHub.detailsLabelText = labtext;
        [shareHub show:YES];
        return;
    }
    shareHub = [[MBProgressHUD alloc] initWithView:cbPlayerController.view];
    shareHub.detailsLabelText = labtext;
    [cbPlayerController.view addSubview:shareHub];
    [shareHub show:YES];
}

- (void)showResultAlertView:(NSString *)message
{
    if (resultView) {
        resultView.message = message;
        [resultView show];
        return;
    }
    resultView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [resultView show];
}

- (BOOL)checkAccessTokenIsExist
{
    NSString *userAccessToken = [[NSUserDefaults standardUserDefaults]stringForKey:kUserAccessToken];
    if (userAccessToken == nil) {
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self adjustIsShareOrVod];
    [self startPlayback];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self stopPlayback];
    [super viewWillDisappear:YES];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [super dealloc];
}
@end
