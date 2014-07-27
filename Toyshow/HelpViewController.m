//
//  HelpViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-12.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "HelpViewController.h"
#import "TransformViewController.h"
#import "NetworkRequest.h"
#import "HowToUseViewController.h"

@interface HelpViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD *progressView;
    UITableView *_tabView;
    NSDictionary *versionDict;
}
@end

@implementation HelpViewController

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

//    background.image = [UIImage imageNamed:backGroundImage];
//    [self.view addSubview:background];
    background.userInteractionEnabled = YES;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 56, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"帮助" forState:UIControlStateNormal];
//    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 180, 22);
//    [backBtn setTitle:@"无线路由器认证方式" forState:UIControlStateNormal];
    [topView addSubview:backBtn];

    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(275, [UIApplication sharedApplication].statusBarFrame.size.height+5, 36, 22);
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [finishBtn addTarget:self action:@selector(finishBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:finishBtn];
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(30, 25, 120, 24)];
//    title.textColor = [UIColor whiteColor];
//    title.text = @"帮助";
////    title.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:title];
    
//    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
//    nextBtn.frame = CGRectMake(260, 25, 50, 24);
//    [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [topView addSubview:nextBtn];
    
    _tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64) style:UITableViewStylePlain];
    _tabView.delegate = self;
    _tabView.dataSource = self;
    [self.view addSubview:_tabView];
}

- (void)backBtn{
//    [self dismissViewControllerAnimated:YES completion:^{
//    }];
    [[SliderViewController sharedSliderController]leftItemClick];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellI = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellI];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellI];
        cell.imageView.image = [UIImage imageNamed:@"dingshi_h@2x"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.textLabel.text = @"如何使用乐现";
        if (1 == indexPath.row) {
            cell.textLabel.text = @"前往下载新版本";
        }else if (2 == indexPath.row)
        {
            cell.textLabel.text = @"检测新版本";
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (2 == indexPath.row) {
        //检测新版本
        [self checkVersion];
        return;
    }else if (1 == indexPath.row)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/qq/id444934666?mt=8"]];
        return;
    }
    HowToUseViewController *howUseVC = [[HowToUseViewController alloc] init];
    [[SliderViewController sharedSliderController].navigationController pushViewController:howUseVC animated:YES];
//    [self presentViewController:howUseVC animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)checkVersion
{
    [self progressViewLoading];
    NSString *url = @"http://www.51joyshow.com/index.php?m=content&c=banben&type=2";
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *Sysversion = [infoDict objectForKey:@"CFBundleShortVersionString"];
    [[AFHTTPRequestOperationManager manager]POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        versionDict = [NSDictionary dictionary];
        versionDict = (NSDictionary *)responseObject;
        NSLog(@"dict:%@",versionDict);
        NSString *version = [versionDict objectForKey:@"version"];
        if ([Sysversion floatValue]<[version floatValue]) {
            [progressView hide:YES];
            [self alertViewShowWithTitle:@"检测到新版本" andMessage:[versionDict objectForKey:@"description"] withDelegate:self andCancelButton:@"Cancel" andOtherButton:@"前往下载"];
        }else
        {
            [progressView hide:YES];
            [self alertViewShowWithTitle:@"无新版本" andMessage:nil withDelegate:nil andCancelButton:@"Cancel" andOtherButton:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [progressView hide:YES];
        NSLog(@"错误%@",[error userInfo]);
        [self alertViewShowWithTitle:@"检测失败" andMessage:nil withDelegate:nil andCancelButton:@"Cancel" andOtherButton:nil];
    }];
}
//强制不允许转屏
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)alertViewShowWithTitle:(NSString*)title andMessage:(NSString*)message withDelegate:(id)delegate andCancelButton:(NSString*)cancelBtn andOtherButton:(NSString*)otherBtn
{
    UIAlertView *viersionView = [[UIAlertView alloc] initWithTitle:title
                                                       message:message
                                                      delegate:delegate
                                             cancelButtonTitle:cancelBtn
                                             otherButtonTitles:otherBtn, nil];
    [viersionView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
//        NSLog(@"前往下载");
        NSString *url = [versionDict objectForKey:@"apkurl"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (void)progressViewLoading
{
    if (progressView) {
//        NSLog(@"已经存在了");
//        progressView.detailsLabelText = @"测试……";
        [progressView show:YES];
        return;
    }
    progressView = [[MBProgressHUD alloc] initWithView:_tabView];
    [_tabView addSubview:progressView];
    progressView.delegate = self;
    progressView.labelText = @"loading";
    progressView.detailsLabelText = @"正在检测，请稍后……";
    progressView.square = YES;
    progressView.alpha = 0.1;
//    progressView.backgroundColor = [UIColor grayColor];
    [progressView show:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
