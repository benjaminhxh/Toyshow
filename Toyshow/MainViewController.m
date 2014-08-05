
//
//  MainViewController.m
//  LeftRightSlider
//
//  Created by Zhao Yiqi on 13-11-27.
//  Copyright (c) 2013年 Zhxf. All rights reserved.
//分享的摄像头页面
#define APP_KEY @"ZIAgdlC7Vw7syTjeKG9zS4QP"
#define APP_ID @"2271149"
#define APP_SecrectKey @"pavlqfU4mzYQ1dH0NG3b7LyXNBy5SYk6"
#define expire @"1802889632"
#define start 100

#import "MainViewController.h"
#import "ShareCamereViewController.h"
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"
//#import "NetworkRequest.h"
#import "UIImageView+AFNetworking.h"
#import "Reachability1.h"
#import <CommonCrypto/CommonDigest.h> //md5加密需要的头文件

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
{
    NSArray *_shareCameraListArr;
    BOOL _reloading;
//    EGORefreshTableHeaderView *_refreshView;
    UITableView *_tableView;
    MJRefreshFooterView *_footerView;
    NSMutableArray *_fakeData;
    NSArray *downloadArr;
    UIActivityIndicatorView *activiView;
    UILabel *noInternetL,*noDataLoadL;
    NSString *realSign, __block *sign;
    MBProgressHUD *_loadingView;
    MBProgressHUD *badInternetHub;
}
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (NSDateFormatter *)dateFormate
//{
//    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
//    [dateFormate setDateFormat:@"MM-dd HH:mm"];
//    return dateFormate;
//}

//32位MD5加密方式
- (NSString *)getMd5_32Bit_String:(NSString *)srcString{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH *2];
    NSLog(@"CC_MD5_DIGEST_LENGTH:%d",CC_MD5_DIGEST_LENGTH);
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    //先拼接再MD5加密
    NSString *string = [NSString stringWithFormat:@"%@%@%@%@",APP_ID,expire,APP_KEY,APP_SecrectKey];
    realSign = [self getMd5_32Bit_String:string];
    NSLog(@"md5String:%@",realSign);
    //再拼接
    sign = [NSString stringWithFormat:@"%@-%@-%@",APP_ID,APP_KEY,realSign];
//    NSLog(@"sign:%@",sign);
    [self shouldAutorotate];
    UIImageView *imgV=[[UIImageView alloc] initWithFrame:self.view.bounds];
    [imgV setImage:[UIImage imageNamed:@"dabeijing@2x"]];
    [self.view addSubview:imgV];
    
    UIImageView *navBar=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    navBar.image=[UIImage imageNamed:navigationBarImageiOS7];
//    navBar.alpha=0.8;
    navBar.userInteractionEnabled = YES;
    [self.view addSubview:navBar];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 126, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn setTitle:@"分享的摄像头" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(leftItemClick) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:backBtn];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, 320, [UIScreen mainScreen].bounds.size.height-65) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    //2、初始化数据
    _fakeData = [NSMutableArray array];
    [self addheader];
    [self addFooter];

    noInternetL = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, 320, 44)];
    noInternetL.text = @"当前网络不可用，请检查你的网络设置";
    noInternetL.backgroundColor = [UIColor grayColor];
    noInternetL.font = [UIFont systemFontOfSize:14];
    noInternetL.textAlignment = NSTextAlignmentCenter;
    noInternetL.hidden = YES;
    [self.view addSubview:noInternetL];
    
    noDataLoadL = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, 320, 44)];
    noDataLoadL.text = @"无更多数据加载";
    noDataLoadL.backgroundColor = [UIColor grayColor];
    noDataLoadL.font = [UIFont systemFontOfSize:14];
    noDataLoadL.textAlignment = NSTextAlignmentCenter;
    noDataLoadL.hidden = YES;
    [self.view addSubview:noDataLoadL];
    //判断是否有网络
    Reachability1 *reachab = [Reachability1 reachabilityWithHostname:@"www.baidu.com"];
    reachab.reachableBlock = ^(Reachability1 *reachabil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            noInternetL.hidden = YES;
        });
    };
    //无网络
    reachab.unreachableBlock = ^(Reachability1 *unreachabil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            noInternetL.hidden = NO;
        });
    };
    [reachab startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivesComeFromWeixin:) name:@"shareToWeixinNotif" object:nil];
}

- (void)addheader{
    __unsafe_unretained MainViewController *vc = self;
    __block MJRefreshHeaderView *header;

    header = [MJRefreshHeaderView header];
    header.scrollView = _tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        //向服务器发起请求
        NSString *sharelistURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=listshare&sign=%@&expire=%@&start=%d&num=100",sign,expire,0];
        NSLog(@"shareListUrl:%@",sharelistURL);
        [[AFHTTPSessionManager manager] GET:sharelistURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            //2、初始化数据
            _fakeData = [NSMutableArray array];
            downloadArr = [NSArray array];
            downloadArr = [dict objectForKey:@"device_list"];
//            NSLog(@"downloadArr:%@",downloadArr);
            if (downloadArr.count == 0) {
                [self MBprogressViewHubLoading:@"无分享的摄像头"];
                [badInternetHub hide:YES afterDelay:1];
            }else
            {
                if (downloadArr.count>20) {
                    for (int i = 0; i < 20; i++) {
                        [vc->_fakeData addObject:[downloadArr objectAtIndex:i]];
                    }
                }else
                {
                    vc->_fakeData = (NSMutableArray *)downloadArr;
                }
            }
            [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:KdurationSuccess];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
//            NSLog(@"下载数据失败");
//            NSLog(@"tabsk%@",task);
//            NSLog(@"eror:%@",error);
//            UIAlertView *noDataView = [[UIAlertView alloc] initWithTitle:@"网络延时" message:nil delegate:nil
            [self MBprogressViewHubLoading:@"网络延时"];
            [badInternetHub hide:YES afterDelay:1];
            [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:KdurationSuccess];

        }];
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是header
//        [vc performSelector:@selector(doneWithViewWithNoInterNet:) withObject:refreshView afterDelay:KdurationFail];
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:KdurationSuccess];
//        NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
//        NSLog(@"%@----刷新完毕", refreshView.class);
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:KdurationSuccess];
    };
//    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
//        // 控件的刷新状态切换了就会调用这个block
//        switch (state) {
//            case MJRefreshStateNormal:
//                NSLog(@"%@----切换到：普通状态", refreshView.class);
//                break;
//                
//            case MJRefreshStatePulling:
//                NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
//                break;
//                
//            case MJRefreshStateRefreshing:
//                NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
//                break;
//            default:
//                break;
//        }
//    };
    [header beginRefreshing];
}

- (void)addFooter
{
    __unsafe_unretained MainViewController *vc = self;
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = _tableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
    if(_fakeData.count < downloadArr.count)
    {
        if (_fakeData.count+20 > downloadArr.count) {
            _fakeData = (NSMutableArray *)downloadArr;
        }else{
            for (int i = 0; i < 20; i++) {
                [_fakeData addObject:[downloadArr objectAtIndex:_fakeData.count]];
            }
        }
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是footer
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:KdurationSuccess];
        NSLog(@"%@----开始进入刷新状态", refreshView.class);
        }
    else
    {
        noDataLoadL.hidden = NO;
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(didDismissNoDataload) userInfo:nil repeats:NO];
        [vc performSelector:@selector(doneWithViewWithNoInterNet:) withObject:refreshView afterDelay:KdurationSuccess];
    }
    };
    _footerView = footer;
}

- (void)didDismissNoDataload
{
    noDataLoadL.hidden = YES;
}
- (void)doneWithView:(MJRefreshBaseView*)sender
{
    //刷新表格
    [_tableView reloadData];
    [sender endRefreshing];
}

- (void)doneWithViewWithNoInterNet:(MJRefreshBaseView*)sender
{
    //刷新表格
//    [_tableView reloadData];
    [sender endRefreshing];
}

- (void)leftItemClick
{
    [[SliderViewController sharedSliderController] leftItemClick];
}

//- (void)rightItemClick
//{
//    [[SliderViewController sharedSliderController]rightItemClick];
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (_fakeData.count) {
        return _fakeData.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    {
        if (nil == cell) {
            //            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ShareCameraCell" owner:self options:nil] lastObject];
            NSDictionary *dict = [_fakeData objectAtIndex:indexPath.row];
            NSLog(@"公共摄像头列表的dict:%@",dict);
            self.cameraName.text = [dict objectForKey:@"description"];
//            self.cameraId.text = [dict objectForKey:@"deviceid"];
            NSString *imageURL = [dict objectForKey:@"thumbnail"];
            [self.cameraHead setImageWithURL:[NSURL URLWithString:imageURL]];
            int status = [[dict objectForKey:@"status"] intValue];
            if (status) {
                self.cameraStatus.text = @"在线";
                self.cameraStatus.textColor = [UIColor blueColor];
            }else
            {
                self.cameraStatus.text = @"离线";
                self.cameraStatus.textColor = [UIColor grayColor];

            }
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_fakeData objectAtIndex:indexPath.row];
    int status = [[dict objectForKey:@"status"] intValue];
    if (status) {
        [self isLoadingView];
        NSString *shareID = [dict objectForKey:@"shareid"];
        NSString *uk = [dict objectForKey:@"uk"];
        ShareCamereViewController *shareVC = [[ShareCamereViewController alloc] init];
        shareVC.islLve = YES;
        shareVC.isShare = YES;
        shareVC.shareId = shareID;
        shareVC.uk = uk;
        shareVC.deviceId = [dict objectForKey:@"deviceid"];
        shareVC.playerTitle = [[dict objectForKey:@"description"] stringByAppendingString:@"(分享)"];
        NSString *liveURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=liveplay&shareid=%@&uk=%@",shareID,uk];
        [[AFHTTPSessionManager manager] GET:liveURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSLog(@"公共摄像头:%@",dict);
            shareVC.url = [dict objectForKey:@"url"];
//            shareVC.url = @"http://zb.v.qq.com:1863/?progid=3900155972";
            [_loadingView removeFromSuperview];
            [[SliderViewController sharedSliderController].navigationController pushViewController:shareVC animated:YES];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"error++++++++");
            [_loadingView removeFromSuperview];
            [self MBprogressViewHubLoading:@"网络延时"];
            [badInternetHub hide:YES afterDelay:1];
        }];
    }else
    {
        [self MBprogressViewHubLoading:@"设备不在线"];
        [badInternetHub hide:YES afterDelay:1];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    shareVC.url = @"http://zb.v.qq.com:1863/?progid=1975434150";
//    shareVC.url = @"http://a.puteasy.com:8800/authorize?chn_id=89&mac=ffffffffffff&mac_code=67a2e0b15d7b1b6ab6ab4e1f6cc516d1";
}

- (void)isLoadingView
{
    _loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    _loadingView.delegate = self;
    _loadingView.labelText = @"loading";
    _loadingView.detailsLabelText = @"正在加载，请稍后……";
    _loadingView.square = YES;
    [_loadingView show:YES];
    [self.view addSubview:_loadingView];
}

#define mark - 禁止转屏
//强制不允许转屏
//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
//}
//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [activiView stopAnimating];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}
//微信分享后回调返回的数据
- (void)receivesComeFromWeixin:(NSNotification *)notif
{
//    NSLog(@"notif:%@",[notif userInfo]);
    NSDictionary *dictFromWeixin = (NSDictionary *)[notif userInfo];
    NSString *shareURL = [dictFromWeixin objectForKey:@"weixinInfo"];
    NSLog(@"url come from weixin:%@",shareURL);
//    [[AFHTTPSessionManager manager] GET:shareURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSDictionary *dict = (NSDictionary *)responseObject;
//        NSString *shareID = [dict objectForKey:@"shareid"];
//        NSString *uk = [dict objectForKey:@"uk"];
//        NSString *playURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=liveplay&shareid=%@&uk=%@",shareID,uk];
//        NSLog(@"playURL:%@",playURL);
    
    [[AFHTTPRequestOperationManager manager] POST:shareURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSLog(@"公共摄像头url:%@",[dict objectForKey:@"url"]);
            ShareCamereViewController *shareVideoVC = [[ShareCamereViewController alloc] init];
            shareVideoVC.islLve = YES;
            shareVideoVC.isShare = YES;
            shareVideoVC.url = [dict objectForKey:@"url"];
            shareVideoVC.playerTitle = [[dictFromWeixin objectForKey:@"weixinTitle"] stringByAppendingString:@"(分享)"];
            [[SliderViewController sharedSliderController].navigationController pushViewController:shareVideoVC animated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error++++++++%@",[error userInfo]);
        }];
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"error++++++++");
//    }];
    NSLog(@"info title come from weixin:%@",[dictFromWeixin objectForKey:@"weixinTitle"]);
}

//- (void)MBprogressViewHubLoading:(NSString *)labtext
//{
//    if (badInternetHub) {
//        badInternetHub.labelText = labtext;
//        [badInternetHub show:YES];
//        [badInternetHub hide:YES afterDelay:1];
//        return;
//    }
//    badInternetHub = [[MBProgressHUD alloc] initWithView:_tableView];
//    badInternetHub.mode = MBProgressHUDModeCustomView;
//    badInternetHub.labelText = labtext;
//    [_tableView addSubview:badInternetHub];
//    [badInternetHub show:YES];
//}
- (void)MBprogressViewHubLoading:(NSString *)labtext
{
    if (badInternetHub) {
        badInternetHub.labelText = labtext;
        [badInternetHub show:YES];
        return;
    }
    badInternetHub = [[MBProgressHUD alloc] initWithView:_tableView];
    badInternetHub.labelText = labtext;
    badInternetHub.mode = 4;
    badInternetHub.square = YES;
    [_tableView addSubview:badInternetHub];
    [badInternetHub show:YES];
}
//- (void)viewWillAppear:(BOOL)animated
//{
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
