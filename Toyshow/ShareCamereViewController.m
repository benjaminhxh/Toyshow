//
//  ShareCamereViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-24.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//
//分享的摄像头直播

#import "ShareCamereViewController.h"
#import "JSONKit.h"
#import "CyberPlayerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "UIProgressView+AFNetworking.h"
//6227 0000 1616 0056 890
@interface ShareCamereViewController ()<MBProgressHUDDelegate,UIAlertViewDelegate,UIActionSheetDelegate>
{
    UIView *cbdPlayerView;
    CyberPlayerController *cbPlayerController;
    UIButton *startBtn;
    UISlider *lightSlider;
    NSTimer *timer,*localTimer;
    UIProgressView *progressV;
    UIImageView *topView,*bottomView;
    BOOL topViewHidden,lightBool;
    UILabel *currentProgress,*remainsProgress;
    MBProgressHUD *_loadingView;
    UISlider *slider;
    UILabel *timeL;
    MPVolumeView *volumView;
    UIView *tapView;
    UIAlertView *publicView,*securityView;

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
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    //设置旋转动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    //设置视图旋转
    self.view.bounds = CGRectMake(0, 0, kWidth,kHeight);
    self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    [UIView commitAnimations];
    
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    cbdPlayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kHeight, kWidth)];
    //请添加您百度开发者中心应用对应的APIKey和SecretKey。
//    NSString* msAK=@"ZIAgdlC7Vw7syTjeKG9zS4QP";
//    NSString* msSK=@"pavlqfU4mzYQ1dH0NG3b7LyXNBy5SYk6";
    //添加开发者信息
    [[CyberPlayerController class ]setBAEAPIKey:msAK SecretKey:msSK ];
    //当前只支持CyberPlayerController的单实例
    cbPlayerController = [[CyberPlayerController alloc] init];
    //设置视频显示的位置
    [cbPlayerController.view setFrame: cbdPlayerView.frame];
    //将视频显示view添加到当前view中
    [self.view addSubview:cbPlayerController.view];
    self.view.userInteractionEnabled = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    
    //系统音量
    volumView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-55, 140, 200, 34)];
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
    backBtn.frame = CGRectMake(22, 12, 30, 20);
//    backBtn.frame = CGRectMake(10, [UIApplication sharedApplication].statusBarFrame.size.height+5, 12, 22);
    [backBtn setImage:[UIImage imageNamed:@"fanhui_jiantou@2x"] forState:UIControlStateNormal];

//    [backBtn setImage:[UIImage imageNamed:@"cehuajiantou@2x"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    //标题
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(55, 12, kWidth-55-20, 20)];
    titleL.textColor = [UIColor whiteColor];
    titleL.font = [UIFont systemFontOfSize:12];
    titleL.text = self.playerTitle;
    [topView addSubview:titleL];
    
    //显示实时时间
    timeL = [[UILabel alloc] initWithFrame:CGRectMake(kHeight/2-20, 10, 40, 15)];
    timeL.text = @"12:12:12";
    timeL.font = [UIFont systemFontOfSize:9];
    timeL.textColor = [UIColor whiteColor];
    [topView addSubview:timeL];
    localTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];

    //直播
    if (self.islLve) {
        if (self.isShare) {
            //分享的摄像头
            //收藏、转发
            UIButton *collectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            collectionBtn.frame = CGRectMake(kHeight*3/4, 11, 37, 22);
            [collectionBtn setImage:[UIImage imageNamed:@"duijiang_wei@2x"] forState:UIControlStateNormal];
            [collectionBtn setImage:[UIImage imageNamed:@"duijiang_zhong@2x"] forState:UIControlStateHighlighted];
            [collectionBtn addTarget:self action:@selector(collectClick) forControlEvents:UIControlEventTouchUpInside];
            [topView addSubview:collectionBtn];
            
            UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            shareBtn.frame = CGRectMake(kHeight*7/8, 11, 37, 22);
            [shareBtn setImage:[UIImage imageNamed:@"fenxiang_wei@2x"] forState:UIControlStateNormal];
            [shareBtn setBackgroundImage:[UIImage imageNamed:@"fenxiang_zhong@2x"] forState:UIControlStateHighlighted];
            [shareBtn addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
            [topView addSubview:shareBtn];
            //开始播放
            [self startPlayback];
            
        }else{
            //我的摄像头直播
            //分享、设置、截图、对讲
            //分享
            UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [shareBtn setImage:[UIImage imageNamed:@"fenxiang_wei@2x"] forState:UIControlStateNormal];
            [shareBtn setImage:[UIImage imageNamed:@"fenxiang_zhong@2x"] forState:UIControlStateHighlighted];
            [shareBtn addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
            [topView addSubview:shareBtn];
            //设置
            UIButton *setBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [setBtn setImage:[UIImage imageNamed:@"shezhi_wei@2x"] forState:UIControlStateNormal ];
            [setBtn setImage:[UIImage imageNamed:@"shezhi_zhong@2x"] forState:UIControlStateHighlighted];
            [setBtn addTarget:self action:@selector(SetClick) forControlEvents:UIControlEventTouchUpInside];
            [topView addSubview:setBtn];
            //截图
            UIButton *cutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [cutBtn setImage:[UIImage imageNamed:@"jietu_wei@2x"] forState:UIControlStateNormal];
            [cutBtn setImage:[UIImage imageNamed:@"jietu_zhong@2x"] forState:UIControlStateHighlighted];
            [cutBtn addTarget:self action:@selector(cutPrint) forControlEvents:UIControlEventTouchUpInside];
            [topView addSubview:cutBtn];
            //对讲
            UIButton *speakBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [speakBtn setImage:[UIImage imageNamed:@"duijiang_wei@2x"] forState:UIControlStateNormal];
            [speakBtn setImage:[UIImage imageNamed:@"duijiang_zhong@2x"] forState:UIControlStateHighlighted];
            [speakBtn addTarget:self action:@selector(speakClick) forControlEvents:UIControlEventTouchUpInside];
            [topView addSubview:speakBtn];
            if (iphone5) {
                shareBtn.frame = CGRectMake(kHeight*5/8, 11, 37, 22);
                setBtn.frame = CGRectMake(kHeight*23/32, 11, 37, 22);
                cutBtn.frame = CGRectMake(kHeight*26/32, 11, 37, 22);
                speakBtn.frame = CGRectMake(kHeight*29/32, 11, 37, 22);

            }else
            {
                shareBtn.frame = CGRectMake(kHeight/2+30, 11, 37, 22);
                setBtn.frame = CGRectMake(kHeight/2+30+50, 11, 37, 22);
                cutBtn.frame = CGRectMake(kHeight/2+30+100, 11, 37, 22);
                speakBtn.frame = CGRectMake(kHeight/2+30+150, 11, 37, 22);
            }
            //开始播放
            [self startPlayback];
        }
    }
    else{
        //点播(看录像)
        //底部条
        bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kWidth-60, kHeight, 60)];
        bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//        bottomView.backgroundColor = [UIColor blueColor];
        bottomView.userInteractionEnabled = YES;
        [self.view addSubview:bottomView];
        
        //开始暂停按钮
        startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        startBtn.frame = CGRectMake(kHeight/2-10, 5, 20, 27);
//        startBtn.backgroundColor = [UIColor blueColor];
        [startBtn setImage:[UIImage imageNamed:@"zanting_anniu@2x"] forState:UIControlStateNormal];
        [startBtn addTarget:self action:@selector(onClickPlay:) forControlEvents:UIControlEventTouchUpInside];
//        [startBtn setImage:[UIImage imageNamed:@"bofang_zhong@2x"] forState:UIControlStateHighlighted];
        [bottomView addSubview:startBtn];
        
        //当前播放的时刻
        currentProgress = [[UILabel alloc] initWithFrame:CGRectMake(20, 43, 40, 10)];
//        currentProgress.backgroundColor = [UIColor redColor];
        currentProgress.textColor = [UIColor whiteColor];
        currentProgress.text = @"00:00:00";
        currentProgress.font = [UIFont systemFontOfSize:8];
        [bottomView addSubview:currentProgress];
        //剩余时长
        remainsProgress = [[UILabel alloc] initWithFrame:CGRectMake(kHeight-45, 43, 40, 10)];
        remainsProgress.textColor = [UIColor whiteColor];
//        remainsProgress.backgroundColor = [UIColor grayColor];
//        remainsProgress.text = @"01:52:10";
        remainsProgress.font = [UIFont systemFontOfSize:8];
        [bottomView addSubview:remainsProgress];
        
        //下载进度条
        progressV = [[UIProgressView alloc] initWithFrame:CGRectMake(60, 47, kHeight - 105, 2)];
        progressV.progressViewStyle = UIProgressViewStyleBar;
//        progressV.progress = 0.5;
        //        progressV.trackTintColor = [UIColor redColor];//未缓冲的
        progressV.progressTintColor = [UIColor grayColor];
        [bottomView addSubview:progressV];

        //快进快退滑动条
        slider = [[UISlider alloc] initWithFrame:CGRectMake(60, 35, kHeight - 105, 25)];
//        slider.continuous = NO;
        [slider setThumbImage:[UIImage imageNamed:@"anniu_huagan16x16@2x"] forState:UIControlStateNormal];
        [slider addTarget:self action:@selector(onDragSlideValueChanged:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(onDragSlideStart:) forControlEvents:UIControlEventTouchDown];
        [slider addTarget:self action:@selector(onDragSlideDone:) forControlEvents:UIControlEventTouchUpInside];
//        slider.backgroundColor = [UIColor blueColor];
        [bottomView addSubview:slider];

    }
    tapView = [[UIView alloc] initWithFrame:CGRectMake(70, 50, kHeight-80, kWidth-60-60)];
    tapView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tapView];
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenOrNo:)];
    [tapView addGestureRecognizer:tapGest];
    [self isLoadingView];
}

//弹出或隐藏设置按钮
- (void)hiddenOrNo:(id)sender
{
    if (topViewHidden) {
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
            volumView.hidden = NO;
        }];
        topViewHidden = !topViewHidden;
        //        NSTimer *timer1 = [NSTimer timerWithTimeInterval:0.8 target:self selector:@selector(hiddenView) userInfo:nil repeats:NO];
        //        [[NSRunLoop currentRunLoop]addTimer:timer1 forMode:NSDefaultRunLoopMode];
        //        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hiddenView) userInfo:NO repeats:NO];
        return;
    }
}
//返回
- (void)backBtn:(id)sender
{
    [self stopPlayback];
    [localTimer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}

#define mark - SetMethod
- (void)collectClick    //收藏
{
    
}

- (void)shareClick  //分享
{
    UIActionSheet *shareTypeSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"公共分享" otherButtonTitles:@"私密分享", nil];
    [shareTypeSheet showInView:self.view];
}

- (void)SetClick    //设置
{
    
}

- (void)cutPrint    //截图
{
    UIGraphicsBeginImageContext(cbPlayerController.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    //自动保存到图片库
}

- (void)speakClick  //对讲
{
    NSLog(@"speaking");
}

- (void)lightSliderValue:(UISlider *)sender
{
    NSLog(@"亮度调节value:%f",sender.value);
}

- (void)onDragSlideValueChanged:(id)sender {
    NSLog(@"slide changing, %f", slider.value);
    [self refreshProgress:slider.value totalDuration:cbPlayerController.duration];
    //    NSLog(@"slider changing :%f",slider.progress);
    //    [self refreshProgress:slider.progress totalDuration:cbPlayerController.duration];
}

- (void)onDragSlideDone:(id)sender {
    float currentTIme = slider.value;
//    float currentTIme2 = progressV.progress;
    NSLog(@"seek to %f", currentTIme);
//    NSLog(@"seek2 to %f", currentTIme2);
    
    //实现视频播放位置切换，
    [cbPlayerController seekTo:currentTIme];
    //两种方式都可以实现seek操作
    [cbPlayerController setCurrentPlaybackTime:currentTIme];
}
- (void)onDragSlideStart:(id)sender {
    [self stopTimer];
}

- (void)onpreparedListener: (NSNotification*)aNotification
{
    //视频文件完成初始化，开始播放视频并启动刷新timer。
    [self startTimer];
    NSLog(@"prepareeeeeeeeeeeeeeee");
}

- (void)startCatching:(NSNotification*)botif
{
    [self startTimer];
    NSLog(@"startCatchhhhhhhhhhhhhh");
}
- (void)seekComplete:(NSNotification*)notification
{
    //开始启动UI刷新
    [self startTimer];
    NSLog(@"seekCompleteeeeeeeeeeee");
}

- (void)onClickPlay:(id)sender {
    //当按下播放按钮时，调用startPlayback方法
    [self startPlayback];
}

//- (void)onClickStop:(id)sender {
//    [self stopPlayback];
//}
- (void)startPlayback{
//    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"wwmxd" ofType:@"mp4"];
//    NSURL *url = [NSURL fileURLWithPath:urlStr];
//    NSURL *url = [NSURL URLWithString:@"rtmp://livertmppc.wasu.cn/live/dfws"];
//    NSURL *url = [NSURL URLWithString:@"http://119.188.2.50/data2/video04/2013/04/27/00ab3b24-74de-432b-b703-a46820c9cd6f.mp4"];
    NSURL *url = [NSURL URLWithString:self.url];
//    AFURLConnectionOperation *urlConnect = [AFURLConnectionOperation];
//    [progressV setProgressWithDownloadProgressOfOperation:(AFURLConnectionOperation *) animated:<#(BOOL)#>;
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
- (void)stopPlayback{
    //停止视频播放
    [cbPlayerController stop];
    [startBtn setImage:[UIImage imageNamed:@"zanting_anniu@2x"] forState:UIControlStateNormal];
    [self stopTimer];
}

- (void)timerHandler:(NSTimer*)timer
{
    [self refreshProgress:cbPlayerController.currentPlaybackTime totalDuration:cbPlayerController.duration];
//    [self refreshCurrentProgress:cbPlayerController.playableDuration totalDuration:cbPlayerController.duration];//当前可播放视频的长度
}

- (void)refreshCurrentProgress:(int)playableDuration totalDuration:(int)allSecond{
    
    NSDictionary* dict = [[self class] convertSecond2HourMinuteSecond:playableDuration];
    NSString* strPlayedTime = [self getTimeString:dict prefix:@""];
    currentProgress.text = strPlayedTime;
    NSLog(@"可播放的strPlayedTime:%@",strPlayedTime);
    NSLog(@"公共摄像头当前下载速度：%f",cbPlayerController.downloadSpeed);
    NSDictionary* dictLeft = [[self class] convertSecond2HourMinuteSecond:allSecond - playableDuration];
    NSString* strLeft = [self getTimeString:dictLeft prefix:@"-"];
    remainsProgress.text = strLeft;
//    NSLog(@"可播放的strLeft:%@",strLeft);
}

- (void)refreshProgress:(int) currentTime totalDuration:(int)allSecond{
    
    NSDictionary* dict = [[self class] convertSecond2HourMinuteSecond:currentTime];
    NSString* strPlayedTime = [self getTimeString:dict prefix:@""];
    currentProgress.text = strPlayedTime;
    NSLog(@"strPlayedTime:%@",strPlayedTime);
    NSLog(@"公共摄像头当前下载速度：%f",cbPlayerController.downloadSpeed);
    NSDictionary* dictLeft = [[self class] convertSecond2HourMinuteSecond:allSecond - currentTime];
    NSString* strLeft = [self getTimeString:dictLeft prefix:@"-"];
    remainsProgress.text = strLeft;
    NSLog(@"strLeft:%@",strLeft);
    slider.value = currentTime;
    slider.maximumValue = allSecond;
//    progressV.progress = currentTime;
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
    //为了保证UI刷新在主线程中完成。
    [self performSelectorOnMainThread:@selector(startTimeroOnMainThread) withObject:nil waitUntilDone:NO];
}

- (void)startTimeroOnMainThread{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];
}

- (void)stopTimer{
    if ([timer isValid])
    {
        [timer invalidate];
    }
    timer = nil;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    lightSlider.hidden = YES;
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:cbdPlayerView];
//    if (CGRectContainsPoint(self.view.frame, point)) {
//        NSLog(@"----------");
//    }
//    if (point.y > 80 && point.y < kHeight-80) {
//
//    }
//}

- (void)hiddenView
{
    [UIView animateWithDuration:0.3 animations:^{
        topView.frame = CGRectMake(0, -44, kHeight, 44);
        bottomView.frame = CGRectMake(0, kWidth+44, kHeight, 44);
    }];
}

- (void)isLoadingView
{
    _loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_loadingView];
    
    _loadingView.delegate = self;
    _loadingView.labelText = @"loading";
    _loadingView.detailsLabelText = @"正在加载，请稍后……";
    _loadingView.square = YES;
    [_loadingView showWhileExecuting:@selector(isLoadingAnimation) onTarget:self withObject:nil animated:YES];
}

- (void)isLoadingAnimation
{
    sleep(3);
}

//定时器实时更新时间
- (void)updateTime:(id)sender
{
    NSDate *timeDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"HH:mm:ss"];
    NSString *localTIme = [formate stringFromDate:timeDate];
//    NSLog(@"localTime:%@",localTIme);
    timeL.text = localTIme;
}

#pragma mark - ActionsheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"公共分享");//
            publicView = [[UIAlertView alloc] initWithTitle:@"确定要将该摄像头公共分享吗？" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [publicView show];
        }
            break;
        case 1:
        {
            NSLog(@"私密分享");
            securityView = [[UIAlertView alloc] initWithTitle:@"私密分享" message:@"私密分享的摄像头需要密码才能观看" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [securityView show];

        }
            break;
        case 2:
            
            break;
        default:
            break;
    }
    
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (publicView == alertView) {
        if (buttonIndex) {
            NSLog(@"公共分享alertView");
            NSString *publicShareUrl = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=createshare&access_token=%@&deviceid=%@&share=1",self.accecc_token,self.deviceId];//1为公共分享
            
        }
    }else
    {
        if (buttonIndex) {
            NSLog(@"私密分享alertView");
            NSString *securityShareUrl = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=createshare&access_token=%@&deviceid=%@&share=2",self.accecc_token,self.deviceId];//2为私密分享
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
