//
//  AboutViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-11.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "AboutViewController.h"
#import "ShowImageViewController.h"

@interface AboutViewController ()<UIWebViewDelegate>
{
//    UIActivityIndicatorView *indicatorView;
}
@end

@implementation AboutViewController

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
//    UIImageView *background = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    background.image = [UIImage imageNamed:backGroundImage];
//    [self.view addSubview:background];
//    background.userInteractionEnabled = YES;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    float backHeight;
    if (iOS7) {
        backHeight = kStatusbarHeight + 5;
    }else
    {
        backHeight = kStatusbarHeight + 25;
    }
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, backHeight, 102, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn setTitle:@"关于乐现" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
//    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
//    nextBtn.frame = CGRectMake(260, 25, 50, 24);
//    [nextBtn addTarget:self action:@selector(showScrollImage) forControlEvents:UIControlEventTouchUpInside];
//    [topView addSubview:nextBtn];
    
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(30, 25, 120, 24)];
//    title.textColor = [UIColor whiteColor];
//    title.text = @"关于乐现";
//    title.textAlignment = NSTextAlignmentLeft;
//    [self.view addSubview:title];
    

//    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64)];
//    NSURL *url = [NSURL URLWithString:@"http://www.51joyshow.com"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [webView loadRequest:request];
//    webView.delegate = self;
//    [self.view addSubview:webView];
    
//    indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(kWidth/2-40, kHeight/2-84, 80, 80)];
//    [self.view addSubview:indicatorView];
//    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//    indicatorView.backgroundColor = [UIColor lightGrayColor];
//    [indicatorView startAnimating];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(kWidth/2-27,94,54,54)];
    imageview.image = [UIImage imageNamed:@"Icon"];
    [self.view addSubview:imageview];
    
    UILabel *versionL = [[UILabel alloc] initWithFrame:CGRectMake(kWidth/2-60, 160, 120, 24)];
    versionL.textAlignment = NSTextAlignmentCenter;
    versionL.text = @"Joyshow 1.0";
    versionL.textColor = [UIColor grayColor];
    versionL.backgroundColor = [UIColor clearColor];
    [self.view addSubview:versionL];
    
    UILabel *policyL = [[UILabel alloc] initWithFrame:CGRectMake(10, kHeight-38, kWidth-20, 34)];
    policyL.text = @"精彩乐现 版权所有\nCopyright © 2013 - 2014 Joyshow.All Rights Reserved.";
    policyL.numberOfLines = 2;
    policyL.textAlignment = NSTextAlignmentCenter;
    policyL.font = [UIFont systemFontOfSize:11];
    policyL.backgroundColor = [UIColor clearColor];
    policyL.textColor = [UIColor grayColor];
    [self.view addSubview:policyL];
    
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];

}

- (void)backBtn{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.baidu.com"]];
//    [self dismissViewControllerAnimated:YES completion:^{
//    }];
    [[SliderViewController sharedSliderController]leftItemClick];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:1001011"]];
}

- (void)showScrollImage
{
    ShowImageViewController *imageVC = [[ShowImageViewController alloc] init];
    [[SliderViewController sharedSliderController].navigationController pushViewController:imageVC animated:YES];
//    [self presentViewController:imageVC animated:YES completion:nil];
}

#define mark - webViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    [indicatorView stopAnimating];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];//自己添加的。
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];//自己添加的。
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
//    [indicatorView stopAnimating];
    ////NSLog(@"加载失败error:%@",[error userInfo]);
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
