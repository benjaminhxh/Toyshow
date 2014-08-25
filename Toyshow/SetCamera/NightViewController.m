//
//  NightViewController.m
//  Joyshow
//
//  Created by zhxf on 14-7-16.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "NightViewController.h"

@interface NightViewController ()<MBProgressHUDDelegate>
{
   MBProgressHUD *_progressView;
    UISegmentedControl *isenceSeg,*filterSeg;
}
@end

@implementation NightViewController

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
    background.userInteractionEnabled = YES;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 128, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"夜视功能设置" forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    saveBtn.frame = CGRectMake(kWidth-65, [UIApplication sharedApplication].statusBarFrame.size.height+2, 55, 35);
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"lishijilu@2x"] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(finishAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:saveBtn];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64)];
    scrollView.contentSize = CGSizeMake(kWidth, kHeight);
    [self.view addSubview:scrollView];
    
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backAction:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
    UILabel *staueL = [[UILabel alloc] initWithFrame:CGRectMake(5, 11, 110, 31)];
    staueL.text = @"事件通知设置:";
    [scrollView addSubview:staueL];
    
    NSArray *isenceArr = [NSArray arrayWithObjects:@"自动模式",@"拍摄室内",@"拍摄室外", nil];
    isenceSeg = [[UISegmentedControl alloc] initWithItems:isenceArr];
    isenceSeg.frame = CGRectMake(0, 51, kWidth, 30);
    isenceSeg.selectedSegmentIndex = self.filterIndex;
    [isenceSeg addTarget:self action:@selector(isenceAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:isenceSeg];
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(5, 94, kWidth-10, 0.5)];
    lineV.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineV];
    
    UILabel *sensityL = [[UILabel alloc] initWithFrame:CGRectMake(5, 101, 110, 31)];
    sensityL.text = @"检测灵敏度:";
    [scrollView addSubview:sensityL];
    
    NSArray *filterArr  = [NSArray arrayWithObjects:@"自动模式",@"白天模式",@"夜间模式",nil];
    filterSeg = [[UISegmentedControl alloc] initWithItems:filterArr];
    filterSeg.frame = CGRectMake(0, 141, kWidth, 30);
    filterSeg.selectedSegmentIndex = self.filterIndex;
    [filterSeg addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:filterSeg];


}

- (void)isenceAction:(id)sender
{
    
}

- (void)filterAction:(id)sender
{
    
}
- (void)finishAction:(id)sender
{
    [self isLoadingView];
    NSDictionary *setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInteger:isenceSeg.selectedSegmentIndex ],@"iScene",
                                       [NSNumber numberWithInteger:filterSeg.selectedSegmentIndex ],@"iLightFilterMode", nil];
    NSString *setCameraDataString = [setCameraDataDict JSONString];
    NSString *strWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)setCameraDataString, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    //
    NSString *setURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:@"control",@"method",self.access_token,@"access_token",self.deviceid,@"deviceid",setCameraDataDict,@"command", nil];
    NSLog(@"paramDict:%@",paramDict);
    [[AFHTTPSessionManager manager] POST:setURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = (NSDictionary*)responseObject;
        NSLog(@"dict:%@",dict);
        _progressView.hidden = YES;
        [self alertViewShowWithTitle:@"设置成功" andMessage:nil];
        [self backToRootViewController];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        _progressView.hidden = YES;
        [self alertViewShowWithTitle:@"设置失败" andMessage:nil];
    }];
}

- (void)backAction:(id)sender
{
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

- (void)backToRootViewController
{
    [[SliderViewController sharedSliderController].navigationController popToRootViewControllerAnimated:YES];
}

- (void)isLoadingView
{
    _progressView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_progressView];
    
    _progressView.delegate = self;
    _progressView.labelText = @"loading";
    //    _loginoutView.detailsLabelText = @"正在注销，请稍后……";
    _progressView.square = YES;
    _progressView.color = [UIColor grayColor];
    [_progressView show:YES];
}

- (void)alertViewShowWithTitle:(NSString*)string andMessage:(NSString*)message
{
    UIAlertView *setError = [[UIAlertView alloc] initWithTitle:string
                                                       message:message
                                                      delegate:nil
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:nil, nil];
    [setError show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
