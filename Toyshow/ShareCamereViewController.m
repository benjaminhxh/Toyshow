//
//  ShareCamereViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-24.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//
//摄像头直播
#define kpickViewHeight 202

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
    UIButton *startBtn,*collectionBtn,*clipVODBtn;
    UISlider *lightSlider,*slider;
    NSTimer *timer,*localTimer,*_timer3;
//    UIProgressView *progressV;
    UIImageView *topView,*bottomView;
    BOOL topViewHidden,lightBool,_isExitFlag;
    UILabel *titleL,*currentProgress,*remainsProgress,*errorLab;
    MBProgressHUD *_loadingView,*shareHub,*percentHub;
    UILabel *timeL;
    MPVolumeView *volumView;
    UIView *tapView;
    UIAlertView *publicView,*cancelShareView,*resultView, *cutimageView;
    NSArray *activity;
    UIActivityIndicatorView *indicatorView;
    UIView *foreGrounp;
    UIView *timeView;
    UIDatePicker *datePick;
    UIButton *startF,*endT;
    BOOL isStart;
    NSDate *startDate,*endDate;
    UITextField *fileName;
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
//    self.view.bounds = CGRectMake(0, 0, kWidth,kHeight);
    NSLog(@"kwidth:%f===========,kheight:%f",kWidth,kHeight);
    self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    [UIView commitAnimations];
    self.view.backgroundColor = [UIColor whiteColor];

    self.scrollv = [[UIScrollView alloc] init];
    self.scrollv.backgroundColor = [UIColor blackColor];
    self.scrollv.frame = CGRectMake( 0, 0, kHeight, kWidth );
    self.scrollv.contentSize = CGSizeMake(kHeight+20, kWidth+20);
    self.scrollv.delegate = self;
    self.scrollv.showsVerticalScrollIndicator = NO;
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
    //清除残留影像
    cbPlayerController.shouldAutoClearRender = YES;
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
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(startCaching:)
//                                                 name:CyberPlayerStartCachingNotification
//                                               object:nil];
    //播放状态发生改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stateDidChange:)
                                                 name:CyberPlayerPlaybackStateDidChangeNotification
                                               object:nil];

    //注册监听，当播放器缓冲视频过程中不断发送该通知。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(GotCachePercent:)
                                                 name:CyberPlayerGotCachePercentNotification
                                               object:nil];

    
    
    //顶部条
    topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kHeight, 44)];
    //    topView.image = [UIImage imageNamed:@"keyboard_number_bg@2x"];
    topView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(10, 12, 41, 20);
//    backBtn.frame = CGRectMake(10, [UIApplication sharedApplication].statusBarFrame.size.height+5, 12, 22);
    [backBtn setImage:[UIImage imageNamed:@"fanhui_jiantou@2x"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    //标题
    titleL = [[UILabel alloc] initWithFrame:CGRectMake(51, 12, kWidth-51-20, 20)];
    titleL.textColor = [UIColor whiteColor];
    titleL.backgroundColor = [UIColor clearColor];
    titleL.font = [UIFont systemFontOfSize:12];
    titleL.text = self.playerTitle;
    [topView addSubview:titleL];
    
    //显示实时时间
    timeL = [[UILabel alloc] initWithFrame:CGRectMake(kHeight/2-20, 5, 40, 15)];
    timeL.text = @"12:12:12";
    timeL.font = [UIFont systemFontOfSize:9];
    timeL.textColor = [UIColor whiteColor];
    timeL.backgroundColor = [UIColor clearColor];
    [topView addSubview:timeL];

    //直播
    //剪辑视频
    clipVODBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [clipVODBtn setImage:[UIImage imageNamed:@"clip"] forState:UIControlStateNormal];
    [clipVODBtn setImage:[UIImage imageNamed:@"clip_no"] forState:UIControlStateHighlighted];
    [clipVODBtn addTarget:self action:@selector(clipVODAction) forControlEvents:UIControlEventTouchUpInside];
//    clipVODBtn.backgroundColor = [UIColor blueColor];
    [topView addSubview:clipVODBtn];
    
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
//    if (iphone5) {
        collectionBtn.frame = CGRectMake(kHeight-56, 11, 46, 24);
        clipVODBtn.frame = CGRectMake(kHeight-56, 11, 46, 24);
//    }
//    else
//    {
//        collectionBtn.frame = CGRectMake(kHeight/2+30+150, 11, 46, 24);
//        collectionBtn.frame = CGRectMake(kHeight/2+30+150, 11, 46, 24);
//    }

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

    //快进快退滑动条
    slider = [[UISlider alloc] initWithFrame:CGRectMake(60, 35, kHeight - 105, 25)];
//        slider.continuous = NO;
    [slider setThumbImage:[UIImage imageNamed:@"anniu_huagan16x16@2x"] forState:UIControlStateNormal];
    [slider addTarget:self action:@selector(onDragSlideValueChanged:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(onDragSlideStart:) forControlEvents:UIControlEventTouchDown];
    [slider addTarget:self action:@selector(onDragSlideDone:) forControlEvents:UIControlEventTouchUpInside];
//        slider.backgroundColor = [UIColor blueColor];
    [bottomView addSubview:slider];

    errorLab = [[UILabel alloc] initWithFrame:CGRectMake(kHeight/2-50, kWidth/2-12, 100, 24)];
    errorLab.text = @"服务器错误";
    errorLab.backgroundColor = [UIColor clearColor];
    errorLab.textColor = [UIColor whiteColor];
    [cbPlayerController.view addSubview:errorLab];

    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenOrNo:)];
    [cbPlayerController.view addGestureRecognizer:tapGest];
    
    [self addclipView];

//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
//    doubleTap.numberOfTapsRequired = 2;
//    [cbPlayerController.view addGestureRecognizer:doubleTap];
//    [tapGest requireGestureRecognizerToFail:doubleTap];
    //进入home后台的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willBackToHomeNotification:) name:kAPPWillResignActivenotif object:nil];
}

#pragma mark - addclipView
- (void)addclipView
{
    foreGrounp = [[UIView alloc] initWithFrame:CGRectMake(kHeight-kWidth, 0, kWidth, kWidth)];
    foreGrounp.alpha = 0.9;
    foreGrounp.backgroundColor = [UIColor grayColor];
//    foreGrounp.contentSize = CGSizeMake(kWidth, kWidth+40);
    [cbPlayerController.view addSubview:foreGrounp];
    foreGrounp.hidden = YES;
    
    UIButton *clipCancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    clipCancelBtn.frame = CGRectMake(10, 0, 65, 30);
    [clipCancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [clipCancelBtn setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];

//    clipCancelBtn.backgroundColor = [UIColor grayColor];
    [clipCancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clipCancelBtn addTarget:self action:@selector(clipCancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [foreGrounp addSubview:clipCancelBtn];
    
    UIButton *clipFinishBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    clipFinishBtn.frame = CGRectMake(kWidth-75, 0, 65, 30);
    [clipFinishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [clipFinishBtn setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];

//    clipFinishBtn.backgroundColor = [UIColor grayColor];
    [clipFinishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clipFinishBtn addTarget:self action:@selector(clipFinishBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [foreGrounp addSubview:clipFinishBtn];
    
    
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 32, kWidth-20, 50)];
    tipLabel.numberOfLines = 3;
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.font = [UIFont systemFontOfSize:13];
    tipLabel.textColor = [UIColor whiteColor];
    [foreGrounp addSubview:tipLabel];
    tipLabel.text = @"请输入剪辑的起始时间，最多只能剪辑半小时视频，结束时间最晚为当前时刻，并且确保剪辑的时间段内有录像，录像保存在该账号的百度云盘中。";
    
    startF = [[UIButton alloc] initWithFrame:CGRectMake(10, 85, 125, 30)];
    [startF setTitle:@"起始时间" forState:UIControlStateNormal] ;
    [startF setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];
    [startF addTarget:self action:@selector(startTimeSelect) forControlEvents:UIControlEventTouchUpInside];
    [foreGrounp addSubview:startF];
    
    endT = [[UIButton alloc] initWithFrame:CGRectMake(kWidth-140, 85, 125, 30)];
    [endT setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];
    [endT setTitle:@"结束时间" forState:UIControlStateNormal] ;
    [endT addTarget:self action:@selector(endTimeSelect) forControlEvents:UIControlEventTouchUpInside];
    [foreGrounp addSubview:endT];
    
    fileName = [[UITextField alloc] initWithFrame:CGRectMake(10, 116, kWidth-20, 34)];
    fileName.placeholder = @"请输入文件名";
    fileName.borderStyle = UITextBorderStyleBezel;
    [foreGrounp addSubview:fileName];
    
    timeView = [[UIView alloc] initWithFrame:CGRectMake(0, kHeight, kWidth, kpickViewHeight)];
    [foreGrounp addSubview:timeView];
    timeView.backgroundColor = [UIColor grayColor];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(10, 0, 60, 30);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
//    cancelBtn.backgroundColor = [UIColor blueColor];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelDatePickSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    [timeView addSubview:cancelBtn];
    
    UIButton *OKBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    OKBtn.frame = CGRectMake(kWidth-70, 0, 60, 30);
    [OKBtn setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];
    [OKBtn setTitle:@"确定" forState:UIControlStateNormal];
    [OKBtn addTarget:self action:@selector(OKBtnDatePickSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    [timeView addSubview:OKBtn];
    
    datePick = [[UIDatePicker alloc] initWithFrame:CGRectMake(10, 30, kWidth-20, 162)];
    datePick.datePickerMode = UIDatePickerModeDateAndTime;
//    datePick.backgroundColor = [UIColor redColor];
    [timeView addSubview:datePick];
}
#pragma mark - adjustIsShare
- (void)adjustIsShareOrVod
{
    titleL.text = self.playerTitle;
    localTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
//    self.scrollv.frame = CGRectMake( 0, 0, kHeight, kWidth );

//    [cbPlayerController.view setFrame:self.view.frame];
    self.request_id = @"";
    [self isLoadingView];
    volumView.hidden = YES;
    clipVODBtn.hidden = YES;
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
                if (self.isWeixinShare) {
                    collectionBtn.hidden = YES;
                }else
                {
                    collectionBtn.hidden = NO;
                }
            }else{
                collectionBtn.hidden = YES;
            }
            bottomView.hidden = YES;
        }else{
            //我的摄像头直播
            collectionBtn.hidden = YES;
            bottomView.hidden = YES;
            clipVODBtn.hidden = NO;
        }
    }else{
        //点播
        collectionBtn.hidden = YES;
        bottomView.hidden = NO;
        currentProgress.text = @"00:00:00";
        remainsProgress.text = @"00:00:00";
        slider.value = 0.0;
    }
    
}
- (void)willBackToHomeNotification:(NSNotificationCenter *)notif
{
    ////NSLog(@"这是退出的通知：postNotificationName");
    [self stopPlayback];
    if ([localTimer isValid]) {
        [localTimer invalidate];
    }
    localTimer = nil;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)onDragSlideValueChanged:(id)sender {
    ////NSLog(@"slide changing, %f", slider.value);
    [self refreshProgress:slider.value totalDuration:cbPlayerController.duration];
    //    ////NSLog(@"slider changing :%f",slider.progress);11/13
    //    [self refreshProgress:slider.progress totalDuration:cbPlayerController.duration];
}

- (void)onDragSlideDone:(id)sender {
    float currentTIme = slider.value;
    ////NSLog(@"seek to %f", currentTIme);
    //实现视频播放位置切换，
    [cbPlayerController seekTo:currentTIme];
    //两种方式都可以实现seek操作
    [cbPlayerController setCurrentPlaybackTime:currentTIme];
}
- (void)onDragSlideStart:(id)sender {
//    [self isLoadingView];

    [self stopTimer];//12
}

//视频文件完成初始化，开始播放视频并启动刷新timer。1
- (void)onpreparedListener: (NSNotification*)aNotification
{
    [self performSelectorOnMainThread:@selector(hiddenLoadingView) withObject:nil waitUntilDone:NO];
    [self startTimer];
}

- (void)hiddenLoadingView
{
    _loadingView.hidden = YES;
}

//完成视频播放位置调整
- (void)seekComplete:(NSNotification*)notification
{
    ////NSLog(@"完成视频播放位置调整seekComplete--%@",[NSThread isMainThread]?@"isMainThread":@"Not mainThread");
//    [self performSelectorOnMainThread:@selector(hiddenLoadingView) withObject:nil waitUntilDone:NO];
    [self startTimer];
}

//播放完成
- (void)playerBackDidFinish:(NSNotification *)notif
{
    if (self.isLive) {
        _loadingView.hidden = YES;
        errorLab.hidden = NO;
    }
}

//播放失败
- (void)playerBackError:(NSNotification *)notifa
{
//    NSLog(@"播放失败playerBackError:%@-------%@---------%@",[notifa userInfo],[notifa object],[notifa name]);
    errorLab.hidden = NO;
    [self performSelectorOnMainThread:@selector(hiddenLoadingView) withObject:nil waitUntilDone:NO];
}
//状态改变
- (void)stateDidChange:(NSNotification*)notif
{
    ////NSLog(@"播放状态发送改变stateDidChange--%@",[NSThread isMainThread]?@"isMainThread":@"Not mainThread");
    if (self.isLive) {
       if(cbPlayerController.playbackState == CBPMoviePlaybackStatePaused){
           [cbPlayerController play];
        }
    }
}
//缓冲过程
- (void)GotCachePercent:(NSNotification *)notific
{
    [self performSelectorOnMainThread:@selector(loadPercentOnMain:) withObject:[notific object] waitUntilDone:NO];
}

- (void)loadPercentOnMain:(id)sender
{
    if(100 == [sender intValue])
    {
        [percentHub hide:YES];
    }else
    {
        [self loadPercent:[sender intValue]];
    }
}
- (void)onClickPlay:(id)sender {
    //当按下播放按钮时，调用startPlayback方法
    [self startPlayback];
}

- (void)onClickStop:(id)sender {
    [self stopPlayback];
}
- (void)startPlayback{
//    NSURL *url = [NSURL URLWithString:@"http://119.188.2.50/data2/video04/2013/04/27/00ab3b24-74de-432b-b703-a46820c9cd6f.mp4"];
    errorLab.hidden = YES;
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
//    ////NSLog(@"timeHanler");
}

- (void)refreshProgress:(int) currentTime totalDuration:(int)allSecond{
//    ////NSLog(@"refreshProgress");//4/7
    NSInteger startT = self.startTimeInt + currentTime;//得到起始时间戳
//    ////NSLog(@"currentTime:%d---allSecond:%d",currentTime,allSecond);
    NSDictionary* dict = [[self class] convertSecond2HourMinuteSecond:startT];
    NSString* strPlayedTime = [self getTimeString:dict prefix:@""];
    currentProgress.text = strPlayedTime;
//    ////NSLog(@"strPlayedTime:%@",strPlayedTime);
//    ////NSLog(@"公共摄像头当前下载速度：%f",cbPlayerController.downloadSpeed);
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
    if (_isLive) {
        return;
    }else
    {
        [self performSelectorOnMainThread:@selector(startTimeroOnMainThread) withObject:nil waitUntilDone:NO];
    }
}

//缓冲完也会进这个函数
//只有这里主线程可以停掉loading
- (void)startTimeroOnMainThread{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];
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
    [percentHub hide:YES];
    _isExitFlag = YES;
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
    }else{
        [UIView animateWithDuration:0.15 animations:^{
            topView.frame = CGRectMake(0, 0, kHeight, 44);
            bottomView.frame = CGRectMake(0, kWidth-60, kHeight, 60);
        }];
        topViewHidden = !topViewHidden;
        _timer3=[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(didTimer) userInfo:nil repeats:NO];
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
    volumView.hidden = YES;
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
    ////NSLog(@"收藏的URL：%@",url);
    [[AFHTTPRequestOperationManager manager]POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dict = (NSDictionary*)responseObject;
        ////NSLog(@"收藏的dict:%@",dict);
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
        ////NSLog(@"收藏的error：%@",[error userInfo]);
//        [self MBprogressViewHubLoading:@"操作失败" withMode:4];
        [self showResultAlertView:@"操作失败"];
        [shareHub hide:YES afterDelay:0.5];
    }];
}

- (void)clipVODAction
{
    [UIView animateWithDuration:0.3 animations:^{
        //        timeView.frame = CGRectMake(0, kHeight-202, kWidth, 202);
        foreGrounp.hidden = NO;
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
//    ////NSLog(@"localTime:%@",localTime);
    timeL.text = localTime;
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

//- (void)doubleTapAction:(UITapGestureRecognizer *)tapGest
//{
//    [UIView animateWithDuration:0.3 animations:^{
//        self.imagev.frame = CGRectMake(0,0,kHeight,kWidth);
//    }];
//}
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

- (void)loadPercent:(int)per
{
    if (percentHub) {
        percentHub.detailsLabelText = [[NSString stringWithFormat:@"%d",per]stringByAppendingString:@"%"];
        [percentHub show:YES];
        return;
    }
    percentHub = [[MBProgressHUD alloc] initWithView:cbPlayerController.view];
    percentHub.detailsLabelText = [[NSString stringWithFormat:@"%d",per]stringByAppendingString:@"%"];
    percentHub.square = YES;
    [cbPlayerController.view addSubview:percentHub];
    [percentHub show:YES];
}

- (void)clipCancelBtnAction:(id)sender
{
    foreGrounp.hidden = YES;
}

- (void)clipFinishBtnAction:(id)sender
{
    //    NSLog(@"---------%@", startF.titleLabel.text);
    
    NSTimeInterval t = [endDate timeIntervalSinceDate:startDate];
    NSLog(@"========:%f",t);
    if (t>1800) {
        NSLog(@"超出30分钟了");
        UIAlertView *tipview = [[UIAlertView alloc] initWithTitle:@"视频区间不能超过30分钟" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [tipview show];
        return;
    }
    else if (t<=0)
    {
        UIAlertView *tipview = [[UIAlertView alloc] initWithTitle:@"结束时间不能小于开始时间" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [tipview show];
        return;
    }else if (!fileName.text.length)
    {
        UIAlertView *tipview = [[UIAlertView alloc] initWithTitle:@"录像名不能为空" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [tipview show];
        return;
    }
    NSTimeInterval st = [startDate timeIntervalSince1970];
    NSTimeInterval et = [endDate timeIntervalSince1970];
    NSLog(@"st:%f-----------et:%f",st,et);
    
    NSLog(@"st:%d-----------et:%d",(int)st,(int)et);
    
    NSString *url = [NSString stringWithFormat:@"￼https://pcs.baidu.com/rest/2.0/pcs/device?method=clip&access_token=&deviceid=&st=%d&et=%d&name=%@",(int)st,(int)et,fileName.text];
    [self.view endEditing:YES];
    foreGrounp.hidden = YES;
}

- (void)startTimeSelect
{
    [UIView animateWithDuration:0.3 animations:^{
        timeView.frame = CGRectMake(0, kWidth-202, kWidth, 202);
    }];
    isStart = YES;
}

- (void)endTimeSelect
{
    [UIView animateWithDuration:0.3 animations:^{
        timeView.frame = CGRectMake(0, kWidth-202, kWidth, 202);
    }];
    isStart = NO;
}

- (void)OKBtnDatePickSelectAction:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        timeView.frame = CGRectMake(0, kHeight, kWidth, kpickViewHeight);
    }];
    datePick.maximumDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *startT = [[self dateFormatterMMddHHmm] stringFromDate:datePick.date];
    NSLog(@"startT:%@",startT);
    if (isStart) {
        [startF setTitle:startT forState:UIControlStateNormal];
        startDate = [self adjustLocalDateWith:datePick.date];
        NSTimeInterval tt = [startDate timeIntervalSince1970];
        NSLog(@"tt:%f",tt);
    }else
    {
        [endT setTitle:startT forState:UIControlStateNormal];
        endDate  = [self adjustLocalDateWith:datePick.date];
        NSTimeInterval eett = [endDate timeIntervalSince1970];
        NSLog(@"eett:%f",eett);
        NSDate *et = [NSDate dateWithTimeIntervalSince1970:eett];
        NSLog(@"et:%@",et);
    }
}

- (void)cancelDatePickSelectAction:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        timeView.frame = CGRectMake(0, kHeight, kWidth, kpickViewHeight);
    }];
}

- (NSDate *)adjustLocalDateWith:(NSDate *)datenow
{
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:datenow];
    NSDate *localeDate = [datenow  dateByAddingTimeInterval: interval];
    return localeDate;
}

- (NSDateFormatter *)dateFormatterMMddHHmm {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd HH:mm:ss"];
    return dateFormat;
}

#pragma mark - textFiledDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        timeView.frame = CGRectMake(0, kHeight, kWidth, kpickViewHeight);
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.3 animations:^{
        timeView.frame = CGRectMake(0, kHeight, kWidth, kpickViewHeight);
    }];
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
    _isExitFlag = NO;
    errorLab.hidden = YES;
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
