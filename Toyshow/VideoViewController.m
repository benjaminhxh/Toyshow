//
//  VideoViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-3.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//
//AVAudioPlayer不可以播放网络URL，但是可以播放NSData

#import "VideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MVViewController.h"

@interface VideoViewController ()<AVAudioPlayerDelegate>
{
    AVAudioPlayer *play;
}
@end

@implementation VideoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playDidChangeNotif:) name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:nil];
    }
    return self;
}

- (void)playDidChangeNotif:(NSNotification *)notif
{
    MPMoviePlayerController *player = notif.object;
    MPMoviePlaybackState playstate = player.playbackState;
    if (playstate == MPMoviePlaybackStatePaused) {
        ////NSLog(@"pause");
    }else if (playstate == MPMoviePlaybackStateStopped)
    {
        ////NSLog(@"stop");
    }else if (playstate == MPMoviePlaybackStatePlaying)
    {
        ////NSLog(@"isPlaying");
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 20, 40, 20);
    [backBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"zsxdr" ofType:@"mp3"];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"wwmxd" ofType:@"mp4"];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    NSURL *url = [NSURL URLWithString:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=vod&access_token= b778fb598c717c0ad7ea8c97c8f3a46f&deviceid=12345&st=1234454&et=1234512"];
    
//    MPMoviePlayerViewController *playC = [[MVViewController alloc] initWithContentURL:url];
//    playC.view.frame = CGRectMake(0, 20, 320, 460);
//    [self presentMoviePlayerViewControllerAnimated:playC];
    
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
}

//- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    ////NSLog(@"finish");
//}
//
//- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
//{
//    ////NSLog(@"error:%@",error);
//}

- (void)backBtn:(id)sender
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
