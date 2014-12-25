//
//  UserInfoViewController.m
//  Joyshow
//
//  Created by xiaohuihu on 14/12/19.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "UserInfoViewController.h"
#import "WXApi.h"
#import "WeixinSessionActivity.h"
#import "WeixinTimelineActivity.h"
#import <Frontia/Frontia.h>

@interface UserInfoViewController ()
{
    UIScrollView *scrollView;
}
@end

@implementation UserInfoViewController

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
    backBtn.frame = CGRectMake(5, backHeight, 90, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"用户信息" forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64)];
    scrollView.contentSize = CGSizeMake(kWidth, kHeight);
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];

    UILabel *applyInfoL = [[UILabel alloc] initWithFrame:CGRectMake(10, 24, 80, 24)];
    applyInfoL.text = @"申请信息";
    applyInfoL.textColor = [UIColor grayColor];
    [scrollView addSubview:applyInfoL];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 50, kWidth, 1)];
    line1.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:line1];
    
    //账号名
    UILabel *accountL = [[UILabel alloc] initWithFrame:CGRectMake(10, 52, 60, 44)];
    accountL.text = @"账号名";
    [scrollView addSubview:accountL];
    
    UITextView *accountText = [[UITextView alloc] initWithFrame:CGRectMake(kWidth/2, 58, kWidth/2-10, 44)];
    accountText.text = [[NSUserDefaults standardUserDefaults] objectForKey:kUserName];
    accountText.textAlignment = NSTextAlignmentRight;
    accountText.textColor = [UIColor grayColor];
    accountText.font = [UIFont systemFontOfSize:17];
    accountText.editable = NO;
    [scrollView addSubview:accountText];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(10, 100, kWidth-10, 1)];
    line2.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:line2];
    
    UILabel *applycodeL = [[UILabel alloc] initWithFrame:CGRectMake(10, 102, 60, 44)];
    applycodeL.text = @"申请码";
    [scrollView addSubview:applycodeL];
    
    UITextView *applycodeLText = [[UITextView alloc] initWithFrame:CGRectMake(kWidth/2, 108, kWidth/2-10, 44)];
    applycodeLText.text = [[NSUserDefaults standardUserDefaults]objectForKey:kUserId];
    applycodeLText.textColor = [UIColor grayColor];
    applycodeLText.font = [UIFont systemFontOfSize:17];
    applycodeLText.textAlignment = NSTextAlignmentRight;
    applycodeLText.editable = NO;
    [scrollView addSubview:applycodeLText];
    
    UIView *line3 = [[UIView alloc] initWithFrame:CGRectMake(0, 150, kWidth, 1)];
    line3.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:line3];
    
    UILabel *explainL = [[UILabel alloc] initWithFrame:CGRectMake(10, 152, kWidth-20, 70)];
    explainL.numberOfLines = 3;
    explainL.text = @"将账号名和申请码发送给好友，待好友同意后可以申请访问好友的摄像头。授权的摄像头将在我的摄像头列表下。";
    explainL.textColor = [UIColor grayColor];
    [scrollView addSubview:explainL];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(kWidth/2-60, 300, 120, 40);
    [sendBtn setBackgroundImage:[UIImage imageNamed:@"kaishipeizhi_anniu@2x"] forState:UIControlStateNormal];
    [sendBtn setTitle:@"发送申请信息" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendInfoTo:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:sendBtn];
    
}

- (void)backBtn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendInfoTo:(id)sender
{
    NSString *accountName = [NSString stringWithFormat:@"账号名:%@",[[NSUserDefaults standardUserDefaults] objectForKey:kUserName]];
    NSString *applyCode = [NSString stringWithFormat:@"申请码:%@",[[NSUserDefaults standardUserDefaults] objectForKey:kUserId]];
    FrontiaShare *share = [Frontia getShare];
    
    [share registerQQAppId:@"1103178501" enableSSO:NO];
    [share registerWeixinAppId:@"wx70162e2c344d4c79"];
    
    //授权取消回调函数
    FrontiaShareCancelCallback onCancel = ^(){
        NSLog(@"OnCancel: share is cancelled");
    };
    
    //授权失败回调函数
    FrontiaShareFailureCallback onFailure = ^(int errorCode, NSString *errorMessage){
        NSLog(@"OnFailure: %d  %@", errorCode, errorMessage);
    };
    
    //授权成功回调函数
    FrontiaMultiShareResultCallback onResult = ^(NSDictionary *respones){
        NSLog(@"================OnResult: %@", [respones description]);
    };
    
    FrontiaShareContent *content=[[FrontiaShareContent alloc] init];
    content.url = @"taobao://";
    content.title = @"";
    content.description = [NSString stringWithFormat:@"%@\n%@",accountName,applyCode];
    content.imageObj = @"http://apps.bdimg.com/developer/static/04171450/developer/images/icon/terminal_adapter.png";
    
    NSArray *platforms = @[FRONTIA_SOCIAL_SHARE_PLATFORM_WEIXIN_SESSION,FRONTIA_SOCIAL_SHARE_PLATFORM_QQFRIEND,FRONTIA_SOCIAL_SHARE_PLATFORM_EMAIL,FRONTIA_SOCIAL_SHARE_PLATFORM_SMS];
    
    [share showShareMenuWithShareContent:content displayPlatforms:platforms supportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait isStatusBarHidden:NO targetViewForPad:sender cancelListener:onCancel failureListener:onFailure resultListener:onResult];
    /*
    NSString *url = @"www.51joyshow.com.cn";
    NSArray *shareArr = [NSArray arrayWithObjects:accountName,applyCode, [UIImage imageNamed:@"Icon"], url,nil];
    
    NSArray *activity = [NSArray arrayWithObjects:[[WeixinSessionActivity alloc] init],[[WeixinTimelineActivity alloc] init],nil];
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:shareArr applicationActivities:activity];
    activityView.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint,UIActivityTypeSaveToCameraRoll,UIActivityTypeMail,UIActivityTypeMessage];
    [self presentViewController:activityView animated:YES completion:nil];
*/
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
