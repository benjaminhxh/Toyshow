//
//  HelpViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-12.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "HelpViewController.h"
#import "SliderViewController.h"
#import "TransformViewController.h"
#import "NetworkRequest.h"
#import "AFNetworking.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *background = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];

//    background.image = [UIImage imageNamed:backGroundImage];
//    [self.view addSubview:background];
    background.userInteractionEnabled = YES;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 62, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"帮助" forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(30, 25, 120, 24)];
//    title.textColor = [UIColor whiteColor];
//    title.text = @"帮助";
////    title.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:title];
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    nextBtn.frame = CGRectMake(260, 25, 50, 24);
    [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:nextBtn];
    
    UIView *vieww = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    vieww.backgroundColor = [UIColor colorWithRed:48/255 green:191/255 blue:196/255 alpha:1];
//    [self.view addSubview:vieww];
    [self networkReloadData];
}

- (void)networkReloadData
{
    NSDictionary *dict = [[NetworkRequest shareInstance] requestWithURL:@"http://www.douban.com/j/app/radio/channels" setHTTPMethod:@"POST"];
    NSLog(@"dict:%@",dict);
}
- (void)backBtn{
//    [self dismissViewControllerAnimated:YES completion:^{
//    }];
    [[SliderViewController sharedSliderController]leftItemClick];

}

- (void)nextBtnClick
{
//    TransformViewController *transformVC = [[TransformViewController alloc] init];
//    [[SliderViewController sharedSliderController].navigationController pushViewController:transformVC animated:YES];
    
//    NSURL *url=[NSURL URLWithString:@"http://119.188.2.50/data2/video04/2013/04/27/00ab3b24-74de-432b-b703-a46820c9cd6f.mp4"];
    NSURL *url = [NSURL URLWithString:@"http://www.douban.com/j/app/radio/channels"];
    NSURLRequest *requesr=[NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *_operation=[[AFHTTPRequestOperation alloc] initWithRequest:requesr];
    
    [_operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *userInfo=[NSDictionary dictionaryWithObject:operation.responseData forKey:@"data"];
//        NSDictionary *dict = (NSDictionary*)responseObject;
//        NSData *data = (NSData *)responseObject;
//        NSLog(@"responseObject:%@",dict);
//        NSLog(@"operation,data:%@",operation.responseData);
//        NSLog(@"data:%@",data);
//        NSDictionary *dictor = [NSData dataWithData:data];
//        NSLog(@"dictor:%@",dictor);
        NSString *str = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSLog(@"str:%@",str);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"song  error%@",error);
    }];
    
    //设置下载进度
    [_operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
        NSNumber *progress=[NSNumber numberWithFloat:totalBytesRead *1.0/totalBytesExpectedToRead];
        NSLog(@"progress:%@",progress);
    }];
    [_operation start];

}
//强制不允许转屏
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
