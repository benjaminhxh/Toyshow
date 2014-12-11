//
//  ShareSetViewController.m
//  Joyshow
//
//  Created by xiaohuihu on 14-9-23.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "ShareSetViewController.h"
#import "WXApi.h"
#import "WeixinSessionActivity.h"
#import "WeixinTimelineActivity.h"

@interface ShareSetViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *shareStyleArr;
    MBProgressHUD *shareHub;
    NSArray *activity;
    UITableView *_tableview;
}
@end

@implementation ShareSetViewController

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
    backBtn.frame = CGRectMake(5, 25, 95, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn setTitle:@"分享设置" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    shareStyleArr = [NSArray arrayWithObjects:@"关闭分享",@"公共分享",@"私密分享", nil];
    _tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kWidth, 132) style:UITableViewStylePlain];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [self.view addSubview:_tableview];
    
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdent = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"shareSetCell" owner:self options:nil] lastObject];
    }
    self.shareStyle.text = [shareStyleArr objectAtIndex:indexPath.row];
    if (indexPath.row == self.index) {
        self.imageView.hidden = NO;
    }else
    {
        self.imageView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            //关闭分享
        {
            [self cancelShareCamera];
        }
            break;
        case 1:
            //公共分享
        {
            [self publicShareCamera];
        }
            break;
        case 2:
            //私密分享
        {
            [self secretShare];
        }
            break;
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (void)backBtn:(id)sender
{
    if (self.index == 2) {
        [self backToRootVC];
        return;
    }
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

- (void)backToRootVC
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"modifySuccess" object:nil];
    [[SliderViewController sharedSliderController].navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 取消分享
- (void)cancelShareCamera
{
    NSString *url = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=cancelshare&access_token=%@&deviceid=%@",self.accecc_token,self.deviceId];
    [self MBprogressViewHubLoading:@"取消分享……" withMode:0];
    [[AFHTTPRequestOperationManager manager] POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        ////NSLog(@"取消分享之后:%@",responseObject);
//        NSDictionary *dict = (NSDictionary *)responseObject;
//        self.request_id =[NSString stringWithFormat:@"%@",[dict objectForKey:@"request_id"]];
        [self MBprogressViewHubLoading:@"成功取消分享" withMode:4];
        [shareHub hide:YES afterDelay:1];
        self.index = 0;
        [_tableview reloadData];
        [self backToRootVC];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.view setNeedsDisplay];
//        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self MBprogressViewHubLoading:@"取消分享失败" withMode:4];
        [shareHub hide:YES afterDelay:1];
    }];
}

#pragma mark - 公共分享
- (void)publicShareCamera
{
    NSString *url = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=createshare&access_token=%@&deviceid=%@&share=1",self.accecc_token,self.deviceId];//share=1为公共分享
    [self MBprogressViewHubLoading:@"分享……" withMode:0];
    
    [[AFHTTPRequestOperationManager manager] POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dict = (NSDictionary *)responseObject;
        ////NSLog(@"公共分享的dict:%@",dict);
        //        NSString *shareid = [dict objectForKey:@"shareid"];
        //        ////NSLog(@"shareid:%@",shareid);
//        self.request_id =[NSString stringWithFormat:@"%@",[dict objectForKey:@"request_id"]];
        [self MBprogressViewHubLoading:@"分享成功" withMode:4];
        [shareHub hide:YES afterDelay:1];
        self.index = 1;
        [_tableview reloadData];
        [self backToRootVC];
        //{“shareid”:SHARE_ID, “uk”:UK, “request_id”:12345678}
        /*
         {
         "request_id" = 2869117991;
         share = 1;
         shareid = 39337debf90f3edfc3374ccfca12fbcb;
         2 = 474433575;
         }
         */
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ////NSLog(@"error:%@",[error userInfo]);
        [self MBprogressViewHubLoading:@"分享失败" withMode:4];
        [shareHub hide:YES afterDelay:1];
        //        self.shareStaue = 0;
    }];
}

#pragma mark - 转发（私密分享）
- (void)secretShare    //转发
{
    //    _loadingView.hidden = NO;
    NSString *userAccessToken = [[NSUserDefaults standardUserDefaults]stringForKey:kUserAccessToken];
    NSString *url = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=createshare&access_token=%@&deviceid=%@&share=2",userAccessToken,self.deviceId];//share=2为加密分享
    [[AFHTTPRequestOperationManager manager] POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {        
        NSDictionary *dict = (NSDictionary *)responseObject;
//        self.request_id =[NSString stringWithFormat:@"%@",[dict objectForKey:@"request_id"]];
        
        NSString *shareID = [dict objectForKey:@"shareid"];
        NSString *uk = [dict objectForKey:@"uk"];
        NSString *playURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=liveplay&shareid=%@&uk=%@",shareID,uk];
        NSURL *shareURL = [NSURL URLWithString:playURL];
        activity = [NSArray arrayWithObjects:[[WeixinSessionActivity alloc] init],[[WeixinTimelineActivity alloc] init], nil];
//        activity = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init]];
        NSString *title = [NSString stringWithFormat:@"%@",self.cameraName];
        NSArray *shareArr = [NSArray arrayWithObjects:title,@"joyshow乐现是由北京精彩乐现开发的一款企业级APP，它可以让你身在千里之外都能随时观看家中情况，店铺情况，路面情况，看你所看。", [UIImage imageNamed:@"Icon"], shareURL,nil];
        
        UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:shareArr applicationActivities:activity];
        activityView.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint,UIActivityTypeSaveToCameraRoll,UIActivityTypeMail,UIActivityTypeMessage];
        [self presentViewController:activityView animated:YES completion:nil];
        self.index = 2;
        [_tableview reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ////NSLog(@"error++++++++");
    }];
}

- (void)MBprogressViewHubLoading:(NSString *)labtext withMode:(int)mode
{
    if (shareHub) {
        shareHub.mode = mode;
        shareHub.detailsLabelText = labtext;
        [shareHub show:YES];
        return;
    }
    shareHub = [[MBProgressHUD alloc] initWithView:self.view];
    shareHub.detailsLabelText = labtext;
    [self.view addSubview:shareHub];
    [shareHub show:YES];
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
