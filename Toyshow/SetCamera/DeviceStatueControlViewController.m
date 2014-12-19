//
//  DeviceStatueControlViewController.m
//  Joyshow
//
//  Created by zhxf on 14-7-16.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "DeviceStatueControlViewController.h"
#import "NSString+encodeChinese.h"

@interface DeviceStatueControlViewController ()<UIAlertViewDelegate,MBProgressHUDDelegate>
{
    UISwitch *statueSw;
    MBProgressHUD *_progressView;
}
@end

@implementation DeviceStatueControlViewController

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
    [backBtn setTitle:@"设备状态控制" forState:UIControlStateNormal];
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
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    UILabel *staueL = [[UILabel alloc] initWithFrame:CGRectMake(15, 11, 110, 31)];
    staueL.text = @"设备状态设置";
    [scrollView addSubview:staueL];
    
    statueSw = [[UISwitch alloc] initWithFrame:CGRectMake(240, 11, 51, 31)];
    statueSw.on = NO;
//    [statueSw addTarget:self action:@selector(openOrClose:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:statueSw];
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(15, 54, kWidth-30, 0.5)];
    lineV.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineV];
    
    UILabel *tipL = [[UILabel alloc] initWithFrame:CGRectMake(15, 56, kWidth-30, 24*3)];
    tipL.numberOfLines = 3;
    tipL.textColor = [UIColor grayColor];
    tipL.text = @"设备状态控制默认为关闭，若开启的话，摄像头将断电，再次开启需手动给摄像头上电，请慎用！";
    [scrollView addSubview:tipL];
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backAction:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];

}

- (void)backAction:(id)sender
{
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

- (void)openOrClose:(id)sender
{
//    UISwitch *swit = (UISwitch *)sender;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        //向服务器发起关闭摄像头
        [self finshAction];
    }else
    {
        statueSw.on = NO;
    }
}

- (void)finishBtn:(id)sender
{
    if (statueSw.on) {
        UIAlertView *tipView = [[UIAlertView alloc] initWithTitle:@"设备状态开启" message:@"设备状态控制若开启的话，摄像头将断电，再次开启需手动给摄像头上电，请慎用！" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [tipView show];
    }
}

- (void)finshAction
{
    
    [self isLoadingView];
    NSDictionary *setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInteger:statueSw.on ],@"iDeviceControl",nil];
    NSString *setCameraDataString = [setCameraDataDict JSONString];
    NSString *strWithUTF8 = [setCameraDataString encodeChinese];

//    NSString *strWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)setCameraDataString, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *setURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
//    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:@"control",@"method",self.access_token,@"access_token",self.deviceid,@"deviceid",setCameraDataDict,@"command", nil];
    ////NSLog(@"paramDict:%@",paramDict);
    [[AFHTTPRequestOperationManager manager] POST:setURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dict = (NSDictionary*)responseObject;
        ////NSLog(@"dict:%@",dict);
        statueSw.on = YES;
        _progressView.hidden = YES;
        [self alertViewShowWithTitle:@"设置成功" andMessage:nil];
        [self backToRootViewController];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        statueSw.on = NO;
        _progressView.hidden = YES;
        [self alertViewShowWithTitle:@"设置失败" andMessage:nil];
    }];
//    [[AFHTTPSessionManager manager] POST:setURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSDictionary *dict = (NSDictionary*)responseObject;
//        ////NSLog(@"dict:%@",dict);
//        statueSw.on = YES;
//        _progressView.hidden = YES;
//        [self alertViewShowWithTitle:@"设置成功" andMessage:nil];
//        [self backToRootViewController];
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        statueSw.on = NO;
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
