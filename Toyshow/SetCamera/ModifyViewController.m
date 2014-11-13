//
//  ModifyViewController.m
//  Toyshow
//
//  Created by zhxf on 14-4-15.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "ModifyViewController.h"
#import "MyCameraViewController.h"
#import "NSString+encodeChinese.h"

@interface ModifyViewController ()<MBProgressHUDDelegate,UITextFieldDelegate>
{
    UITextField *modifyText;
    MBProgressHUD *modifyHub;
    UIScrollView *scrollView;
}
@end

@implementation ModifyViewController

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

    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 64)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 25, 130, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn setTitle:@"修改设备名称" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64)];
    scrollView.contentSize = CGSizeMake(kWidth, kHeight-44);
    [self.view addSubview:scrollView];
    
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
    modifyText = [[UITextField alloc] initWithFrame:CGRectMake(40, 20, 240, 40)];
    modifyText.borderStyle = UITextBorderStyleRoundedRect;
    modifyText.delegate = self;
    modifyText.text = self.deviceName;
    [scrollView addSubview:modifyText];

    UIButton *modifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    modifyBtn.frame = CGRectMake(90, 90, 140, 40);
    [modifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [modifyBtn setTitle:@"修改设备名称" forState:UIControlStateNormal];
    [modifyBtn setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];
    [modifyBtn addTarget:self action:@selector(modifyDevice:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:modifyBtn];
}

- (void)modifyDevice:(id)sender
{
    if ([modifyText.text isEqualToString:self.deviceName]) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备未作修改" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [view show];
        return;
    }
    else if (modifyText.text.length > 12) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备名称不能超过12个字符" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [view show];
        return;
    }
    [self.view endEditing:YES];
    [self MBprogressViewHubLoading:@"设备修改……" withMode:0];
    //UTF8编码，上传服务器修改设备名
//    NSString *modifyT = [[NSString alloc] initWithUTF8String:[modifyText.text UTF8String]];
    //    ////NSLog(@"desc:%@",desc);
    NSString *des = [modifyText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *desWithUTF8 = [des encodeChinese];

//    NSString *desWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)des, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));

    NSString *URLstr = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=update&deviceid=%@&access_token=%@&device_type=1&desc=%@&Need_stream_id_when_exists=1",self.deviceId,self.accessToken,desWithUTF8];
    ////NSLog(@"URLstr:%@",URLstr);

    [[AFHTTPRequestOperationManager manager]GET:URLstr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSString *desc = [dict objectForKey:@"description"];
        if ([desc isEqualToString:modifyText.text]) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备修改成功" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [view show];
//            [self backBtn];
//            if (self.delegate && [self.delegate respondsToSelector:@selector(modifySuccessWith:)]) {
//                [self.delegate modifySuccessWith:modifyText.text];
//            }
//            [_loadingView hide:YES];
            [self MBprogressViewHubLoading:@"设备修改成功" withMode:4];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"modifySuccess" object:nil];
            [[SliderViewController sharedSliderController].navigationController popToRootViewControllerAnimated:YES];

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [_loadingView hide:YES];
        [self MBprogressViewHubLoading:@"设备修改失败" withMode:4];
//        NSDictionary *errorDict = [error userInfo];
        ////NSLog(@"errorDict:%@",errorDict);
//        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备修改失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [view show];
        [self backBtn];
    }];
}
- (void)backBtn{
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

//- (void)isLoadingView
//{
//    _loadingView = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:_loadingView];
//    
//    _loadingView.delegate = self;
//    _loadingView.labelText = @"loading";
//    _loadingView.detailsLabelText = @"修改中，请稍后……";
//    _loadingView.square = YES;
//    [_loadingView show:YES];
//}

- (void)MBprogressViewHubLoading:(NSString *)labtext withMode:(int)mode
{
    if (modifyHub) {
        modifyHub.mode = mode;
        modifyHub.detailsLabelText = labtext;
//        [modifyHub show:YES];
        [modifyHub hide:YES afterDelay:1];
        return;
    }
    modifyHub = [[MBProgressHUD alloc] initWithView:self.view];
    modifyHub.detailsLabelText = labtext;
    [self.view addSubview:modifyHub];
    modifyHub.square = YES;
    [modifyHub show:YES];
//    [modifyHub hide:YES afterDelay:2];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [modifyText resignFirstResponder];
    return YES;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [modifyText resignFirstResponder];
    [scrollView endEditing:YES];
}

@end
