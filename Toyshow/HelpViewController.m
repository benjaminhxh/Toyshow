//
//  HelpViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-12.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "HelpViewController.h"
#import "HowToUseViewController.h"

@interface HelpViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD *progressView;
    UITableView *_tabView;
    NSDictionary *versionDict;
    MBProgressHUD *progrView;
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
    backBtn.frame = CGRectMake(5, backHeight, 56, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"帮助" forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    
    _tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kWidth, 180) style:UITableViewStylePlain];
    _tabView.delegate = self;
    _tabView.dataSource = self;
    [self.view addSubview:_tabView];
}

- (void)backBtn{
//    [self dismissViewControllerAnimated:YES completion:^{
//    }];
    [[SliderViewController sharedSliderController]leftItemClick];

}

#pragma mark - tableViewDelegate
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
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"如何使用乐现";

                break;
            case 1:
                cell.textLabel.text = @"前往官网";

                break;
            case 2:
                cell.textLabel.text = @"检测新版本";

                break;
            default:
                break;
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
    switch (indexPath.row) {
        case 0:
            [self alertViewShowWithTitle:@"请详细阅读说明书或者前往官网" andMessage:nil withDelegate:self andCancelButton:@"好" andOtherButton:nil];
            break;
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.51joyshow.com.cn"]];
            break;
        case 2:
            [self checkVersion];
            break;
   
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
    
- (void)showOrDismissProgressView{
    sleep(3);
    __block UIImageView *imageView;
	dispatch_sync(dispatch_get_main_queue(), ^{
		UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
		imageView = [[UIImageView alloc] initWithImage:image];
	});
    progrView.mode = MBProgressHUDModeCustomView;
    progrView.labelText = @"收藏成功";
    progrView.customView = imageView;
//    progrView.detailsLabelText = @"收藏成功";
}
- (void)checkVersion
{
    [self progressViewLoading];
    //检测新版本地址
//    NSString *url = @"http://www.51joyshow.com.cn/index.php?m=content&c=banben&type=2";
    NSString *url = @"http://joy.weichuangkeji.net/sysupdate.php?type=2";
   AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/plain",@"text/json",@"application/x-javascript",nil];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        versionDict = [NSDictionary dictionary];
        versionDict = (NSDictionary *)responseObject;
//        NSLog(@"升级收到的dict:%@",versionDict);
        NSString *version = [versionDict objectForKey:@"version"];
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *Sysversion = [infoDict objectForKey:@"CFBundleShortVersionString"];
        if ([Sysversion floatValue]<[version floatValue])
        {
            [progressView hide:YES];
            [self alertViewShowWithTitle:@"检测到新版本,是否升级?" andMessage:[versionDict objectForKey:@"description"] withDelegate:self andCancelButton:@"取消" andOtherButton:@"升级"];
        }else
        {
            [progressView hide:YES];
            [self alertViewShowWithTitle:@"当前版本已是最新版本" andMessage:nil withDelegate:nil andCancelButton:@"好" andOtherButton:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [progressView hide:YES];
        ////NSLog(@"错误%@",[error userInfo]);
        [self alertViewShowWithTitle:@"检测失败" andMessage:nil withDelegate:nil andCancelButton:@"好" andOtherButton:nil];
    }];
  //responseSerializer有吗..有的话是什么类型?
    //因为该URL的响应头是Content-Type:text/html;charset=utf-8
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
//        ////NSLog(@"前往下载");
        NSString *url = [versionDict objectForKey:@"apkurl"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (void)progressViewLoading
{
    if (progressView) {
//        ////NSLog(@"已经存在了");
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
