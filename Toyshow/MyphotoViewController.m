//
//  MyphotoViewController.m
//  Toyshow
//
//  Created by zhxf on 14-2-27.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//
//直播
#import "MyphotoViewController.h"
#import "JSONKit.h"
#import "CyberPlayerController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

#define kHeight [UIScreen mainScreen].bounds.size.height
#define kWidth [UIScreen mainScreen].bounds.size.width
@interface MyphotoViewController ()
{
    UIView *cbdPlayerView;
    CyberPlayerController *cbPlayerController;
    UIButton *startBtn;
    UISlider *lightSlider;
    NSTimer *timer;
    UIProgressView *progressV;
    UIImageView *topView,*bottomView;
    BOOL topViewHidden,lightBool;
//    UILabel *currentProgress,*remainsProgress;
    MPVolumeView *volume;
}
@end

@implementation MyphotoViewController

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
    
	// Do any additional setup after loading the view.
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    backBtn.frame = CGRectMake(5, 20, 40, 20);
//    [backBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:backBtn];
//    NSDictionary *headDict = [NSDictionary dictionaryWithObjectsAndKeys:@"62",@"length",@"23130",@"verify", nil];
//    NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:@"IOS",@"OS",@"joyshow",@"SSID",@"89898989",@"PWD",@"sinvideo",@"USERID",headDict,@"HEAD", nil];
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:dataDict,@"DATA", nil];
//    NSString *jsonStr = [dict JSONString];
//    NSString *appURL = @"192.168.1.21";
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:appURL]];
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    //异步下载，接收返回的data
//    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        if (data.length > 0 && connectionError == nil) {
//            NSDictionary *downloadDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
////            [icarousView reloadData];
//        });
//    }];

    //右滑回到上一个页面
//    UISwipeGestureRecognizer *recognizer;
//    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn:)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    [self.view addGestureRecognizer:recognizer];
    //    url = [NSURL URLWithString:@"http://119.188.2.50/data2/video04/2013/04/27/00ab3b24-74de-432b-b703-a46820c9cd6f.mp4"];
//    url = [NSURL URLWithString:@"rtmp://livertmppc.wasu.cn/live/dfws"];
    cbdPlayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kHeight, kWidth)];
    
	// Do any additional setup after loading the view, typically from a nib.
    //请添加您百度开发者中心应用对应的APIKey和SecretKey。
//    NSString* msAK=@"ZIAgdlC7Vw7syTjeKG9zS4QP";
//    NSString* msSK=@"pavlqfU4mzYQ1dH0NG3b7LyXNBy5SYk6";
    //添加开发者信息
    [[CyberPlayerController class ]setBAEAPIKey:msAK SecretKey:msSK ];
    //当前只支持CyberPlayerController的单实例
    cbPlayerController = [[CyberPlayerController alloc] init];
    cbPlayerController.shouldAutoClearRender = YES;
    //设置视频显示的位置
    [cbPlayerController.view setFrame: cbdPlayerView.frame];
    //将视频显示view添加到当前view中
    [self.view addSubview:cbPlayerController.view];
    
    topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kHeight, 44)];
    //    topView.image = [UIImage imageNamed:@"keyboard_number_bg@2x"];
    topView.backgroundColor = [UIColor grayColor];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 20, 60, 24);
    //    backBtn.backgroundColor = [UIColor blueColor];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    //分享
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(kHeight*4/8, 20, 60, 24);
    [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
    //    shareBtn.backgroundColor = [UIColor redColor];
    [shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //    [shareBtn setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareSet:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:shareBtn];
    //清晰度设置
    UIButton *lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lightBtn.frame = CGRectMake(kHeight*5/8, 20, 60, 24);
    [lightBtn setTitle:@"清晰度" forState:UIControlStateNormal];
    [lightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //    [lightBtn setImage:[UIImage imageNamed:@"control"] forState:UIControlStateNormal ];
    [lightBtn addTarget:self action:@selector(lightSet:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:lightBtn];
    //剪辑
    UIButton *cutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cutBtn.frame = CGRectMake(kHeight*6/8, 20, 60, 24);
    [cutBtn setTitle:@"剪辑" forState:UIControlStateNormal];
    [cutBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [cutBtn setImage:[UIImage imageNamed:@"cut"] forState:UIControlStateNormal];
    //    cutBtn.backgroundColor = [UIColor redColor];
    [cutBtn addTarget:self action:@selector(cutPrint:) forControlEvents:UIControlEventTouchUpInside];
    
    [topView addSubview:cutBtn];
    //点、直播
    UIButton *vodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    vodBtn.frame = CGRectMake(kHeight*7/8, 20, 60, 24);
    [vodBtn setTitle:@"看点播" forState:UIControlStateNormal];
    [vodBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //    vodBtn.backgroundColor = [UIColor blueColor];
    //    [vodBtn setImage:[UIImage imageNamed:@"vodlive"] forState:UIControlStateNormal];
    [vodBtn addTarget:self action:@selector(vodOrLiveChange:) forControlEvents:UIControlEventTouchUpInside];
    
    [topView addSubview:vodBtn];
    
    bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kWidth-44, kHeight, 44)];
    //    bottomView.image = [UIImage imageNamed:@"keyboard_number_bg@2x"];
    bottomView.backgroundColor = [UIColor grayColor];
    bottomView.userInteractionEnabled = YES;
    [self.view addSubview:bottomView];
    
    startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(kHeight/2-22, 0, 45, 44);
    [startBtn setImage:[UIImage imageNamed:@"tu1a"] forState:UIControlStateNormal];
    //    startBtn.backgroundColor = [UIColor blueColor];
    [startBtn addTarget:self action:@selector(onClickPlay:) forControlEvents:UIControlEventTouchUpInside];
    //    [startBtn setTitle:@"播放" forState:UIControlStateNormal];
    [bottomView addSubview:startBtn];
    
    //    lightSlider = [[UISlider alloc] initWithFrame:CGRectMake(kHeight/2, 50, kHeight/3, 2)];
    //    [lightSlider addTarget:self action:@selector(lightSliderValue:) forControlEvents:UIControlEventValueChanged];
    //    lightSlider.hidden = YES;
    //    [self.view addSubview:lightSlider];
    
    //注册监听，当播放器完成视频的初始化后会发送CyberPlayerLoadDidPreparedNotification通知，
    //此时naturalSize/videoHeight/videoWidth/duration等属性有效。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onpreparedListener1:)
                                                 name: CyberPlayerLoadDidPreparedNotification
                                               object:self];
    //注册监听，当播放器完成视频播放位置调整后会发送CyberPlayerSeekingDidFinishNotification通知，
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(seekComplete1:)
                                                 name:CyberPlayerSeekingDidFinishNotification
                                               object:self];
}

//返回
- (void)backBtn:(id)sender
{
    [self stopPlayback];
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:NO completion:nil];
}
#pragma mark - SetMethod
- (void)shareSet:(id)sender
{
    volume.showsVolumeSlider = YES;
}
- (void)lightSet:(id)sender
{
    if (!lightBool) {
        lightSlider.hidden = NO;
        lightBool = !lightBool;
        return;
    }else
    {
        lightSlider.hidden = YES;
        lightBool = !lightBool;
        return;
    }
}
- (void)cutPrint:(id)sender
{
    UIGraphicsBeginImageContext(cbPlayerController.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    //自动保存到图片库
}
//切换到点播
- (void)vodOrLiveChange:(id)sender
{
    [self stopPlayback];
    NSLog(@"点播转换============");
//    VODViewController *vodVC = [[VODViewController alloc] init];
//    [self presentViewController:vodVC animated:NO completion:nil];
//    [self.navigationController pushViewController:vodVC animated:NO];
}
- (void)lightSliderValue:(UISlider *)sender
{
    NSLog(@"亮度调节value:%f",sender.value);
}
- (void) onpreparedListener1: (NSNotification*)aNotification
{
    //视频文件完成初始化，开始播放视频并启动刷新timer。
    //    playButtonText.titleLabel.text = @"pause";
    [self startTimer1];
    NSLog(@"prepareeeeeeeeeeeeeeee");
}

- (void)startCatching1:(NSNotification*)botif
{
    [self startTimer1];
    NSLog(@"startCatchhhhhhhhhhhhhh");
}
- (void)seekComplete1:(NSNotification*)notification
{
    //开始启动UI刷新
    [self startTimer1];
    NSLog(@"seekCompleteeeeeeeeeeee");
}

//- (void) onpreparedListener1
//{
//    //视频文件完成初始化，开始播放视频并启动刷新timer。
//    //    playButtonText.titleLabel.text = @"pause";
//    [self startTimer1];
//    NSLog(@"prepareeeeeeeeeeeeeeee");
//}
//
//- (void)startCatching1
//{
//    [self startTimer1];
//    NSLog(@"startCatchhhhhhhhhhhhhh");
//}
//- (void)seekComplete1
//{
//    //开始启动UI刷新
//    [self startTimer1];
//    NSLog(@"seekCompleteeeeeeeeeeee");
//}

- (void)onClickPlay:(id)sender {
    //当按下播放按钮时，调用startPlayback方法
    [self startPlayback];
}

- (void)onClickStop:(id)sender {
    [self stopPlayback];
}
- (void)startPlayback{
    NSURL *url = [NSURL URLWithString:@"rtmp://livertmppc.wasu.cn/live/dfws"];
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"wwmxd" ofType:@"mp4"];
    //    NSURL *url = [NSURL fileURLWithPath:path];
    switch (cbPlayerController.playbackState) {
        case CBPMoviePlaybackStateStopped:
        case CBPMoviePlaybackStateInterrupted:
            [cbPlayerController setContentURL:url];
            //初始化完成后直接播放视频，不需要调用play方法
            cbPlayerController.shouldAutoplay = YES;
            //初始化视频文件
            [cbPlayerController prepareToPlay];
            //            [startBtn setTitle:@"pause" forState:UIControlStateNormal];
            [startBtn setImage:[UIImage imageNamed:@"tu1a"] forState:UIControlStateNormal];
//            [self onpreparedListener1];
            break;
        case CBPMoviePlaybackStatePlaying:
            //如果当前正在播放视频时，暂停播放。
            [cbPlayerController pause];
            //            [startBtn setTitle:@"play" forState:UIControlStateNormal];
            [startBtn setImage:[UIImage imageNamed:@"tu3a"] forState:UIControlStateNormal];
            break;
        case CBPMoviePlaybackStatePaused:
            //如果当前播放视频已经暂停，重新开始播放。
            [cbPlayerController start];
            //            [startBtn setTitle:@"pause" forState:UIControlStateNormal];
            [startBtn setImage:[UIImage imageNamed:@"tu1a"] forState:UIControlStateNormal];
//            [self onpreparedListener1];
            break;
        default:
            break;
    }
}
- (void)stopPlayback{
    //停止视频播放
    [cbPlayerController stop];
    //    [startBtn setTitle:@"play" forState:UIControlStateNormal];
    [startBtn setImage:[UIImage imageNamed:@"tu3a"] forState:UIControlStateNormal];
    [self stopTimer];
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

- (void)startTimer1{
    //为了保证UI刷新在主线程中完成。
    [self performSelectorOnMainThread:@selector(startTimeroOnMainThread1) withObject:nil waitUntilDone:NO];
}
- (void)startTimeroOnMainThread1{
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerHandler1:) userInfo:nil repeats:YES];
}

- (void)timerHandler1:(NSTimer*)timer
{
    [self refreshProgress:cbPlayerController.currentPlaybackTime totalDuration:cbPlayerController.duration];
}

- (void)refreshProgress:(int) currentTime totalDuration:(int)allSecond{
    NSDictionary* dict = [[self class] convertSecond2HourMinuteSecond:currentTime];
    NSString* strPlayedTime = [self getTimeString:dict prefix:@""];
    NSLog(@"strPlayedTime:%@",strPlayedTime);
    NSDictionary* dictLeft = [[self class] convertSecond2HourMinuteSecond:allSecond - currentTime];
    NSString* strLeft = [self getTimeString:dictLeft prefix:@"-"];
    NSLog(@"strLeft:%@",strLeft);
    NSLog(@"直播下载速度：%f",cbPlayerController.downloadSpeed);
    progressV.progress = currentTime;
}
- (void)stopTimer{
    if ([timer isValid])
    {
        [timer invalidate];
        NSLog(@"定时器关");
    }
   timer = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    lightSlider.hidden = YES;
    if (topViewHidden) {
        [UIView animateWithDuration:0.15 animations:^{
            topView.frame = CGRectMake(0, -60, kHeight, 60);
            bottomView.frame = CGRectMake(0, kWidth+60, kHeight, 60);
            //            startBtn.frame = CGRectMake(0, -40, 50, 20);
            //            slider.frame = CGRectMake(50, -40, kHeight - 50, 3);
            //            startBtn.hidden = YES;
            //            slider.hidden = YES;
        }];
        topViewHidden = !topViewHidden;
        return;
    }else{
        //        startBtn.hidden = NO;
        //        slider.hidden = NO;
        [UIView animateWithDuration:0.15 animations:^{
            //            startBtn.frame = CGRectMake(0, 20, 50, 20);
            //            slider.frame = CGRectMake(50, 20, kHeight - 50, 3);
            topView.frame = CGRectMake(0, 0, kHeight, 44);
            bottomView.frame = CGRectMake(0, kWidth-44, kHeight, 44);
        }];
        
        topViewHidden = !topViewHidden;
        return;
    }
}

#pragma mark - 转屏
//强制右转屏
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    cbPlayerController = nil;
}
@end
