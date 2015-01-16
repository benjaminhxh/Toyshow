//
//  ShowImageViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-3.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "ShowImageViewController.h"
#import "iCarousel.h"
#import "HXHAppDelegate.h"
#import "MainViewController.h"
#import "RootNavViewController.h"

@interface ShowImageViewController ()<iCarouselDataSource,iCarouselDelegate,UIScrollViewDelegate>
{
    NSArray *_imageArray;
    iCarousel *icaView;
    UIView *backgroundView;
    BOOL loginFlag;
}
@end

@implementation ShowImageViewController

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
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    if (iphone5) {
        UIImage *image1 = [UIImage imageNamed:@"laorenxiaohai4.0@2x.png"];
        UIImage *image2 = [UIImage imageNamed:@"qunaer4.0@2x.png"];
        UIImage *image3 = [UIImage imageNamed:@"fenshen4.0@2x.png"];
        UIImage *image4 = [UIImage imageNamed:@"beijing1080@2x.png"];
        _imageArray = [NSArray arrayWithObjects:image1,image2,image3,image4, nil];
    }else
    {
        UIImage *image1 = [UIImage imageNamed:@"laorenxiaohai@2x.png"];
        UIImage *image2 = [UIImage imageNamed:@"qunaer@2x.png"];
        UIImage *image3 = [UIImage imageNamed:@"fenshen@2x.png"];
        UIImage *image4 = [UIImage imageNamed:@"beijing720@2x.png"];
        _imageArray = [NSArray arrayWithObjects:image1,image2,image3,image4, nil];
    }
    icaView = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    icaView.delegate = self;
    icaView.dataSource = self;
//        icaView.bounces = YES;
//设置类型
    icaView.type = iCarouselTypeRotary;
    icaView.pagingEnabled = YES;
    [self.view addSubview:icaView];
}

//- (void)backBtn:(id)sender
//{
//    [self.navigationController popViewControllerAnimated:YES];
//    [[SliderViewController sharedSliderController] leftItemClick];
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    if (_imageArray.count) {
        return _imageArray.count;
    }else
    {
        return 0;
    }
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    
    if (view == nil) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        ((UIImageView *)view).image = [_imageArray objectAtIndex:index];
        view.contentMode = UIViewContentModeScaleAspectFill;
    }
    if (index == 3) {
        view.userInteractionEnabled = YES;
        UIButton *lookAroundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        lookAroundBtn.frame = CGRectMake(15, 200, 95, 40);
        [lookAroundBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [lookAroundBtn setTitle:@"进去看看" forState:UIControlStateNormal];
        [lookAroundBtn setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];
        [lookAroundBtn addTarget:self action:@selector(lookAroundClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:lookAroundBtn];
        
//        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        loginBtn.frame = CGRectMake(15, 260, 95, 40);
//        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
//        [loginBtn setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];
//        [loginBtn addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
//        [view addSubview:loginBtn];
        
        UIButton *buyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        buyBtn.frame = CGRectMake(20, 340, 80, 40);
        [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [buyBtn setTitle:@"购买链接" forState:UIControlStateNormal];
        [buyBtn setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];
        [buyBtn addTarget:self action:@selector(buyClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:buyBtn];
    }
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    ////NSLog(@"index:%d",index);
}

- (void)lookAroundClick
{
    ////NSLog(@"随便看看");
    [self showTabBarController];
    
//    icaView.hidden = YES;
}

//- (void)loginClick
//{
//    ////NSLog(@"登录按钮");
////    icaView.hidden = YES;
////    backgroundView.hidden = YES;
//    loginFlag = YES;
//    [self showTabBarController];
//}

- (void)buyClick
{
    ////NSLog(@"购买链接");
    NSURL *url = [NSURL URLWithString:@"http://www.51joyshow.com.cn"];
//    [[UIApplication sharedApplication] canOpenURL:url];

//    NSURL *url = [NSURL URLWithString:@"openApp.jdMobile://"];
//    if ([[UIApplication sharedApplication]canOpenURL:url]) {
        [[UIApplication sharedApplication]openURL:url];
//    }else
//    {
//        ////NSLog(@"没安装客户端");
//        NSURL *url1 = [NSURL URLWithString:@"http://www.51joyshow.com.cn"];
//        [[UIApplication sharedApplication]canOpenURL:url1];
//    }
}

//显示TabBarController
- (void)showTabBarController
{
    
    //已经不是第一次启动了
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"first"];
    [userDefaults synchronize];
    
    HXHAppDelegate *delegate = [HXHAppDelegate instance];
    
    [SliderViewController sharedSliderController].LeftVC=[[LeftViewController alloc] init];
    [SliderViewController sharedSliderController].RightVC=[[RightViewController alloc] init];
    [SliderViewController sharedSliderController].RightSContentOffset=260;
    [SliderViewController sharedSliderController].RightSContentScale=0.6;
    [SliderViewController sharedSliderController].RightSOpenDuration=0.8;
    [SliderViewController sharedSliderController].RightSCloseDuration=0.8;
    [SliderViewController sharedSliderController].RightSJudgeOffset=160;
//    if (loginFlag) {
//        LeftViewController *left = (LeftViewController *)[SliderViewController sharedSliderController].LeftVC;
////        [left signonButtonClicked];
//        [left loginBaidu];
//    }
   
    delegate.window.rootViewController = [[RootNavViewController alloc] initWithRootViewController:[SliderViewController sharedSliderController]];
    delegate.window.backgroundColor = [UIColor whiteColor];
    //显示状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
