//
//  ModifyViewController.m
//  Toyshow
//
//  Created by zhxf on 14-4-15.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "ModifyViewController.h"
#import "AFNetworking.h"
#import "MyCameraViewController.h"
#import "SliderViewController.h"

@interface ModifyViewController ()
{
    UITextField *modifyText;
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
    
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 130, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn setTitle:@"修改设备名称" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(30, 25, 120, 24)];
//    title.textColor = [UIColor whiteColor];
//    title.text = @"修改设备名称";
//    title.textAlignment = NSTextAlignmentLeft;
//    [self.view addSubview:title];
    
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
    modifyText = [[UITextField alloc] initWithFrame:CGRectMake(40, 80, 240, 40)];
    modifyText.borderStyle = UITextBorderStyleRoundedRect;
    modifyText.text = self.deviceName;
    [self.view addSubview:modifyText];

    UIButton *modifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    modifyBtn.frame = CGRectMake(90, 160, 140, 40);
//    modifyBtn.enabled = NO;//按钮不可点击
    [modifyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [modifyBtn setTitle:@"修改设备名称" forState:UIControlStateNormal];
    [modifyBtn setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];
    [modifyBtn addTarget:self action:@selector(modifyDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:modifyBtn];
}

- (void)modifyDevice:(id)sender
{
//    UIButton *button = (UIButton *)sender;

    if ([modifyText.text isEqualToString:self.deviceName]) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备未作修改" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
        return;
    }
    else if (modifyText.text.length > 12) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备名称不能超过12个字符" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
        return;
    }
//    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备修改成功" message:@"设备修改成功" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [view show];
//    [self.navigationController popViewControllerAnimated:YES];
    

    //UTF8编码，上传服务器修改设备名
//    NSString *modifyT = [[NSString alloc] initWithUTF8String:[modifyText.text UTF8String]];
    //    NSLog(@"desc:%@",desc);
    NSString *des = [modifyText.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *desWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)des, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));

    NSString *URLstr = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=update&deviceid=%@&access_token=%@&device_type=1&desc=%@&Need_stream_id_when_exists=1",self.deviceId,self.accessToken,desWithUTF8];
    NSLog(@"URLstr:%@",URLstr);

//    NSLog(@"modify.text:%@",modifyText.text);
    [[AFHTTPRequestOperationManager manager]GET:URLstr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSString *desc = [dict objectForKey:@"description"];
        if ([desc isEqualToString:modifyText.text]) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备修改成功" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [view show];
            [self backBtn];
        }
        NSLog(@"<#string#>");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *errorDict = [error userInfo];
        NSLog(@"errorDict:%@",errorDict);
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备修改失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
        [self backBtn];
    }];
}
- (void)backBtn{
    [self.navigationController popViewControllerAnimated:YES];
//    MyCameraViewController *mycameraVC = [[MyCameraViewController alloc] init];
//    [[SliderViewController sharedSliderController].navigationController popToViewController:mycameraVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [modifyText resignFirstResponder];
}

@end
