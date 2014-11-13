//
//  EventNotificationViewController.m
//  Joyshow
//
//  Created by zhxf on 14-7-16.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "EventNotificationViewController.h"
#import "NSString+encodeChinese.h"

@interface EventNotificationViewController ()<MBProgressHUDDelegate>
{
    UISwitch *EventNotifSw;
    UISegmentedControl *sensitySeg;
    NSArray *sensityArr;
    MBProgressHUD *_progressView;
}
@end

@implementation EventNotificationViewController

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
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 64)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 25, 128, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"事件通知设置" forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    saveBtn.frame = CGRectMake(kWidth-65, 25-5, 55, 35);
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"lishijilu@2x"] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(finishBtn:) forControlEvents:UIControlEventTouchUpInside];
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
    staueL.text = @"事件通知设置";
    [scrollView addSubview:staueL];
    
    EventNotifSw = [[UISwitch alloc] initWithFrame:CGRectMake(240, 11, 51, 31)];
    EventNotifSw.on = self.eventNotifIndex;
    [EventNotifSw addTarget:self action:@selector(EventNotifOpenOrClose:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:EventNotifSw];
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(5, 54, kWidth-10, 0.5)];
    lineV.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineV];
    
    UILabel *sensityL = [[UILabel alloc] initWithFrame:CGRectMake(5, 61, 110, 31)];
    sensityL.text = @"检测灵敏度:";
    [scrollView addSubview:sensityL];
    
    sensityArr = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",nil];
    sensitySeg = [[UISegmentedControl alloc] initWithItems:sensityArr];
    sensitySeg.frame = CGRectMake(0, 101, kWidth, 30);
    sensitySeg.selectedSegmentIndex = self.sensityIndex;
    [sensitySeg addTarget:self action:@selector(sensitivityAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:sensitySeg];
    
//    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    finishBtn.frame = CGRectMake(90, 156, 140, 40);
//    [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [finishBtn setTitle:@"保存" forState:UIControlStateNormal];
//    [finishBtn setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];
//    [finishBtn addTarget:self action:@selector(finishBtn:) forControlEvents:UIControlEventTouchUpInside];
//    [scrollView addSubview:finishBtn];

}

- (void)backAction:(id)sender
{
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

- (void)EventNotifOpenOrClose:(id)sender
{
   ////NSLog(@"EventNotifSw:%d",EventNotifSw.on);
}

//灵敏度检测
- (void)sensitivityAction:(id)sender
{
//    self.sensityIndex = sensitySeg.selectedSegmentIndex;
    ////NSLog(@"sensitySeg:%d",sensitySeg.selectedSegmentIndex);
}

- (void)finishBtn:(id)sender
{
    [self isLoadingView];
    NSDictionary *setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:EventNotifSw.on ],@"iEnableEvent",
                          [NSNumber numberWithInteger:sensitySeg.selectedSegmentIndex ],@"iObjDetectLevel", nil];
    NSString *setCameraDataString = [setCameraDataDict JSONString];
    NSString *strWithUTF8 = [setCameraDataString encodeChinese];

//    NSString *strWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)setCameraDataString, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    //
    NSString *setURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
//    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:@"control",@"method",self.access_token,@"access_token",self.deviceid,@"deviceid",setCameraDataDict,@"command", nil];
    ////NSLog(@"paramDict:%@",paramDict);
    [[AFHTTPRequestOperationManager manager] POST:setURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dict = (NSDictionary*)responseObject;
        ////NSLog(@"dict:%@",dict);
        _progressView.hidden = YES;
        [self alertViewShowWithTitle:@"设置成功" andMessage:nil];
        [self backToRootViewController];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _progressView.hidden = YES;
        [self alertViewShowWithTitle:@"设置失败" andMessage:nil];
    }];
//    [[AFHTTPSessionManager manager] POST:setURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSDictionary *dict = (NSDictionary*)responseObject;
//        ////NSLog(@"dict:%@",dict);
//        _progressView.hidden = YES;
//        [self alertViewShowWithTitle:@"设置成功" andMessage:nil];
//        [self backToRootViewController];
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        _progressView.hidden = YES;
//        [self alertViewShowWithTitle:@"设置失败" andMessage:nil];
//    }];
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
                                             cancelButtonTitle:@"好"
                                             otherButtonTitles:nil, nil];
    [setError show];
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
