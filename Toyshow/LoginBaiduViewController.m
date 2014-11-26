//
//  LoginBaiduViewController.m
//  Joyshow
//
//  Created by xiaohuihu on 14/11/24.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "LoginBaiduViewController.h"

@interface LoginBaiduViewController ()<UIWebViewDelegate>

@end

@implementation LoginBaiduViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 64)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 25, 100, 22);
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn setTitle:@"百度登陆" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];

    // Do any additional setup after loading the view.
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64)];
    webView.delegate = self;
    NSString *stringURL = @"http://openapi.baidu.com/oauth/2.0/authorize?client_id=ZIAgdlC7Vw7syTjeKG9zS4QP&force_login=1&scope=netdisk&confirm_login=1&redirect_uri=bdconnect%3A%2F%2Fsuccess&display=mobile&response_type=code";
    NSURL *url = [NSURL URLWithString:stringURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
}

- (void)backBtn{
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"error：%@",error);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webView:%@",webView);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
