//
//  ShowImageViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-3.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "ShowImageViewController.h"
#import "iCarousel.h"
#import "SliderViewController.h"

@interface ShowImageViewController ()<iCarouselDataSource,iCarouselDelegate>
{
    NSArray *_imageArray;
    iCarousel *icaView;
    UIView *backgroundView;
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
	// Do any additional setup after loading the view.
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 20, 40, 20);
    [backBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    backgroundView = [[UIView alloc] initWithFrame:self.view.frame];
    backgroundView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:backgroundView];
    
    if (iphone5) {
        UIImage *image1 = [UIImage imageNamed:@"laorenxiaohai_da@2x"];
        UIImage *image2 = [UIImage imageNamed:@"qunaer_da@2x"];
        UIImage *image3 = [UIImage imageNamed:@"fenshen_da@2x"];
        UIImage *image4 = [UIImage imageNamed:@"beijing720_da@2x"];
        _imageArray = [NSArray arrayWithObjects:image1,image2,image3,image4, nil];
    }else
    {
        UIImage *image1 = [UIImage imageNamed:@"laorenxiaohai@2x"];
        UIImage *image2 = [UIImage imageNamed:@"qunaer@2x"];
        UIImage *image3 = [UIImage imageNamed:@"fenshen@2x"];
        UIImage *image4 = [UIImage imageNamed:@"beijing720@2x"];
        _imageArray = [NSArray arrayWithObjects:image1,image2,image3,image4, nil];
    }
    //右滑回到上一个页面
//    UISwipeGestureRecognizer *recognizer;
//    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn:)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    [self.view addGestureRecognizer:recognizer];
    
    BOOL isFirst = [[NSUserDefaults standardUserDefaults] boolForKey:@"isFirst"];
//    if (isFirst) {
        icaView = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        icaView.delegate = self;
        icaView.dataSource = self;
//        icaView.bounces = YES;
        icaView.type = iCarouselTypeRotary;
        icaView.pagingEnabled = YES;
        [backgroundView addSubview:icaView];
        //        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"firstLanuch"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isFirst"];
        //进去看看
        UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        nextBtn.frame = CGRectMake(240, 20, 60, 20);
        [nextBtn setTitle:@"进去看看" forState:UIControlStateNormal];
        [nextBtn addTarget:self action:@selector(nextMainView) forControlEvents:UIControlEventTouchUpInside];
        [icaView addSubview:nextBtn];
//    }
}

- (void)nextMainView
{
    [UIView animateWithDuration:0.3 animations:^{
        icaView.hidden = YES;
        backgroundView.hidden = YES;
    }];
}
- (void)backBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
//    [[SliderViewController sharedSliderController] leftItemClick];
//    [self dismissViewControllerAnimated:YES completion:nil];
    
}

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
        
        UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        loginBtn.frame = CGRectMake(15, 260, 95, 40);
        [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [loginBtn setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];
        [loginBtn addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:loginBtn];
        
        UIButton *buyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        buyBtn.frame = CGRectMake(20, 340, 80, 40);
        [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //        [buyBtn setTitle:@"购买链接" forState:UIControlStateNormal];
        [buyBtn setImage:[UIImage imageNamed:@"goumai_anniu@2x"] forState:UIControlStateNormal];
        [buyBtn addTarget:self action:@selector(buyClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:buyBtn];
    }
    return view;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"index:%d",index);
}

- (void)lookAroundClick
{
    NSLog(@"随便看看");
    icaView.hidden = YES;
    backgroundView.hidden = YES;
}

- (void)loginClick
{
    NSLog(@"登录按钮");
    icaView.hidden = YES;
    backgroundView.hidden = YES;

}

- (void)buyClick
{
    NSLog(@"购买链接");
    NSURL *url = [NSURL URLWithString:@"openApp.jdMobile://"];
    if ([[UIApplication sharedApplication]canOpenURL:url]) {
        [[UIApplication sharedApplication]openURL:url];
    }else
    {
        NSLog(@"没安装客户端");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
