//
//  AddAuthorViewController.m
//  Joyshow
//
//  Created by xiaohuihu on 14/12/19.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "AddAuthorViewController.h"
#import "NSString+encodeChinese.h"

@interface AddAuthorViewController ()
{
    UIScrollView *scrollView;
    UITextField *accountF,*applyCodeF;
    MBProgressHUD *progresshud;
}
@end

@implementation AddAuthorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *background = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    background.userInteractionEnabled = YES;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 64)];
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
    backBtn.frame = CGRectMake(5, backHeight, 126, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"新增用户授权" forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    
    UIButton *addUserBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addUserBtn.frame = CGRectMake(kWidth-65, 25-3, 55, 35);
    [addUserBtn setTitle:@"授权" forState:UIControlStateNormal];
    [addUserBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addUserBtn setBackgroundImage:[UIImage imageNamed:@"lishijilu@2x"] forState:UIControlStateNormal];
    [addUserBtn addTarget:self action:@selector(AuthorizationClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:addUserBtn];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64)];
    scrollView.contentSize = CGSizeMake(kWidth, kHeight);
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    UILabel *applyInfoL = [[UILabel alloc] initWithFrame:CGRectMake(10, 24, 190, 24)];
    applyInfoL.text = @"请输入好友的申请信息";
    applyInfoL.textColor = [UIColor grayColor];
    [scrollView addSubview:applyInfoL];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 50, kWidth, 1)];
    line1.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:line1];
    
    //账号名
    UILabel *accountL = [[UILabel alloc] initWithFrame:CGRectMake(10, 52, 60, 44)];
    accountL.text = @"账号名";
    [scrollView addSubview:accountL];
    
    accountF = [[UITextField alloc] initWithFrame:CGRectMake(kWidth/2-40, 52, kWidth/2+30, 44)];
//    accountF.textAlignment = NSTextAlignmentRight;
    accountF.placeholder = @"请输入账号名";
    accountF.textColor = [UIColor grayColor];
    [scrollView addSubview:accountF];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(10, 100, kWidth-10, 1)];
    line2.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:line2];
    
    UILabel *applycodeL = [[UILabel alloc] initWithFrame:CGRectMake(10, 102, 60, 44)];
    applycodeL.text = @"申请码";
    [scrollView addSubview:applycodeL];
    
    applyCodeF = [[UITextField alloc] initWithFrame:CGRectMake(kWidth/2-40, 102, kWidth/2+30, 44)];
    applyCodeF.textColor = [UIColor grayColor];
    applyCodeF.keyboardType = UIKeyboardTypeNumberPad;
//    applyCodeF.textAlignment = NSTextAlignmentRight;
    applyCodeF.placeholder = @"请输入申请码";
    [scrollView addSubview:applyCodeF];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 150, kWidth, 1)];
    line3.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:line3];
}

- (void)backBtn
{
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

- (void)isloading
{
    if (progresshud) {
        [progresshud show:YES];
        return;
    }
    progresshud = [[MBProgressHUD alloc] initWithFrame:self.view.frame];
    progresshud.detailsLabelText = @"授权中loading";
    [self.view addSubview:progresshud];
    [progresshud show:YES];
}
- (void)AuthorizationClick
{
    if (accountF.text.length && applyCodeF.text.length) {
        [self isloading];
        NSString *name = [accountF.text encodeChinese];
        NSString *accessToken = [[NSUserDefaults standardUserDefaults]objectForKey:kUserAccessToken];
        NSString *url = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=grant&auth_code=5&access_token=%@&uk=%@&deviceid=%@&name=%@",accessToken,applyCodeF.text,self.deviceID,name];
        [[AFHTTPRequestOperationManager manager] GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            progresshud.hidden = YES;
            UIAlertView *tipview = [[UIAlertView alloc] initWithTitle:@"授权成功" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil]   ;
            [tipview show];
            [self backBtn];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            progresshud.hidden = YES;
            UIAlertView *tipview = [[UIAlertView alloc] initWithTitle:@"授权失败" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [tipview show];
        }];
    }else
    {
        UIAlertView *tipV = [[UIAlertView alloc] initWithTitle:@"账号名或申请码不能为空" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [tipV show];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
