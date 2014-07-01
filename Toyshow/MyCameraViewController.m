//
//  MyCameraViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-19.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "MyCameraViewController.h"
#import "SliderViewController.h"
#import "MyphotoViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import "ShareCamereViewController.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "CameraSetViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Reachability1.h"

@interface MyCameraViewController ()<UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate,MBProgressHUDDelegate,CameraSetViewControllerDelegate>
{
    BOOL _reloading;
    UITableView *_tableView;
    MJRefreshHeaderView *_headerView;
    MJRefreshFooterView *_footerView;
    NSMutableArray *_fakeData;
    NSMutableArray *downloadArr;
    MBProgressHUD *_loadingView;
    UILabel *noDataLoadL,*noInternetL;
}

@end

@implementation MyCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-(void)loadView
//{
//    [super loadView];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoNotification:) name:kUserInfoNotification object:nil];
//}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accessToken = [[SliderViewController sharedSliderController].dict objectForKey:@"accessToken"];

    UIImageView *imgV=[[UIImageView alloc] initWithFrame:self.view.bounds];
    [imgV setImage:[UIImage imageNamed:@"dabeijing@2x"]];
    [self.view addSubview:imgV];
    
    UIImageView *navBar=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    navBar.image=[UIImage imageNamed:navigationBarImageiOS7];
    //    navBar.alpha=0.8;
    navBar.userInteractionEnabled = YES;
    [self.view addSubview:navBar];
//    UIImage *image1 = [UIImage imageNamed:@"wo_shejingtou"];
//    UIImage *image2 = [UIImage imageNamed:@"tianjia"];
//    UIImage *image3 = [UIImage imageNamed:@"fxsjt"];
//    UIImage *image4 = [UIImage imageNamed:@"shejingtou_shezhi"];
//    UIImage *image5 = [UIImage imageNamed:@"tuichu"];
//    UIImage *image6 = [UIImage imageNamed:@"bangzhu_tubiao"];
//    UIImage *image7 = [UIImage imageNamed:@"guanyu"];
//    _imageArr = [NSArray arrayWithObjects:image1,image2,image3,image4,image5,image6,image7,image3, nil];
//    _titleArr = @[@"北京",@"上海",@"广州",@"深圳",@"天津",@"南京",@"重庆",@"成都"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifySuccess:) name:@"modifySuccess" object:nil];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 120, 22);
    [backBtn setTitle:@"我的摄像头" forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(leftClick) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:backBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, 320, [UIScreen mainScreen].bounds.size.height-65) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    noInternetL = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, 320, 44)];
    noInternetL.text = @"当前网络不可用，请检查你的网络设置";
    noInternetL.backgroundColor = [UIColor grayColor];
    noInternetL.font = [UIFont systemFontOfSize:14];
    noInternetL.textAlignment = NSTextAlignmentCenter;
    noInternetL.hidden = YES;
    [self.view addSubview:noInternetL];
    
    //判断是否有网络
    Reachability1 *reachab = [Reachability1 reachabilityWithHostname:@"www.baidu.com"];
    reachab.reachableBlock = ^(Reachability1 *reachabil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            noInternetL.hidden = YES;
        });
    };
    
    reachab.unreachableBlock = ^(Reachability1 *unreachabil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            noInternetL.hidden = NO;
        });
    };
    [reachab startNotifier];

    noDataLoadL = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, 320, 44)];
    noDataLoadL.text = @"无更多数据加载";
    noDataLoadL.backgroundColor = [UIColor grayColor];
    noDataLoadL.font = [UIFont systemFontOfSize:14];
    noDataLoadL.textAlignment = NSTextAlignmentCenter;
    noDataLoadL.hidden = YES;
    [self.view addSubview:noDataLoadL];
    //2、初始化数据
    _fakeData = [NSMutableArray array];
    [self addheader];
    [self addFooter];
}

- (void)isLoadingView
{
    _loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_loadingView];
    
    _loadingView.delegate = self;
    _loadingView.labelText = @"loading";
    _loadingView.detailsLabelText = @"正在加载，请稍后……";
    _loadingView.square = YES;
    [_loadingView show:YES];
}

- (void)leftClick
{
    NSLog(@"------");
    [[SliderViewController sharedSliderController] leftItemClick];
//    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

- (void)rightClick
{
    NSLog(@"right=====");
    [[SliderViewController sharedSliderController]rightItemClick];
}
-(void)btnNextClick:(id)sender{
    //    [[SliderViewController sharedSliderController].navigationController pushViewController:[[ViewController1 alloc] init] animated:YES];
}

- (void)addheader{
    __unsafe_unretained MyCameraViewController *vc = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        //向服务器发起请求
        NSString *urlSTR = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=list&access_token=%@&device_type=1",self.accessToken];
        [[AFHTTPSessionManager manager] GET:urlSTR parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            //2、初始化数据
            _fakeData = [NSMutableArray array];
            downloadArr = [NSMutableArray array];
            downloadArr = [dict objectForKey:@"list"];
            NSLog(@"downloadArr:%@",downloadArr);

            if (downloadArr.count>20) {
                for (int i = 0; i < 20; i++) {
                    [vc->_fakeData addObject:[downloadArr objectAtIndex:i]];
                }
            }else
            {
                vc->_fakeData = (NSMutableArray *)downloadArr;
            }
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:KdurationSuccess];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            UIAlertView *noDataView = [[UIAlertView alloc] initWithTitle:@"网络延时" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [noDataView show];
        }];
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是header
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:KdurationFail];
        
        NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        // 刷新完毕就会回调这个Block
        NSLog(@"%@----刷新完毕", refreshView.class);
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        // 控件的刷新状态切换了就会调用这个block
        switch (state) {
            case MJRefreshStateNormal:
                NSLog(@"%@----切换到：普通状态", refreshView.class);
                break;
                
            case MJRefreshStatePulling:
                NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
                break;
                
            case MJRefreshStateRefreshing:
                NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
                break;
            default:
                break;
        }
    };
    [header beginRefreshing];
    _headerView = header;
}

- (void)addFooter
{
    __unsafe_unretained MyCameraViewController *vc = self;
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
    [sender endRefreshing];
}
- (void)leftItemClick
{
    [[SliderViewController sharedSliderController] leftItemClick];
}

- (void)rightItemClick
{
    [[SliderViewController sharedSliderController]rightItemClick];
}

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
        if (nil == cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MyCameraCell" owner:self options:nil] lastObject];
            NSDictionary *cameraUserInfoDict = [_fakeData objectAtIndex:indexPath.row];
            self.cameraId.text = [cameraUserInfoDict objectForKey:@"deviceid"];
//            self.cameraPic.image = [_imageArr objectAtIndex:indexPath.row];
            self.cameraTitle.text = [cameraUserInfoDict objectForKey:@"description"];
            NSString *status = [cameraUserInfoDict objectForKey:@"status"];
            int stat = [status intValue];
            if (stat) {
                self.cameraStatus.text = @"在线";
                self.cameraStatus.textColor = [UIColor blueColor];
            }else
            {
                self.cameraStatus.text = @"离线";
                self.cameraStatus.textColor = [UIColor grayColor];
            }
            NSString *urlImage = [cameraUserInfoDict objectForKey:@"thumbnail"];
            [self.cameraPic setImageWithURL:[NSURL URLWithString:urlImage]];
            UIImage *image= [ UIImage imageNamed:@"setanniuhei@2x"];
            UIButton *button = [ UIButton buttonWithType:UIButtonTypeCustom ];
            CGRect frame = CGRectMake( 0.0 , 0.0 , 30 , 24 );
            button.frame = frame;
            [button setImage:image forState:UIControlStateNormal ];
//            button.backgroundColor = [UIColor clearColor ];
            [button addTarget:self action:@selector(accessoryButtonTappedAction:) forControlEvents:UIControlEventTouchUpInside];
            cell. accessoryView = button;
        }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_fakeData objectAtIndex:indexPath.row];
//    NSString *stream_id = [dict objectForKey:@"stream_id"];
    NSString *deviceid = [dict objectForKey:@"deviceid"];
    NSString *status = [dict objectForKey:@"status"];
    int stat = [status intValue];
//分享
//    NSString *url = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=createshare&access_token=%@&deviceid=%@&share=1",self.accessToken,deviceid];//share=1为公共分享
//取消分享
//    NSString *url = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=cancelshare&access_token=52.458ff6f376002020f442208e094ca7b7.2592000.1405677428.906252268-2271149&deviceid=%@",deviceid];
//    [[AFHTTPRequestOperationManager manager] POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dict = (NSDictionary *)responseObject;
//        NSLog(@"dict:%@",dict);
//        NSString *shareid = [dict objectForKey:@"shareid"];
//        NSLog(@"shareid:%@",shareid);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"error:%@",[error userInfo]);
//        UIAlertView *failView = [[UIAlertView alloc] initWithTitle:@"分享失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [failView show];
//    }];


    //判断是被是否在线，在线则可以看直播
    if (stat) {
        [self isLoadingView];
        NSString *liveUrl = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=liveplay&access_token=%@&deviceid=%@",self.accessToken,deviceid];
        [[AFHTTPRequestOperationManager manager] POST:liveUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [_loadingView hide:YES];
            NSDictionary *dict = (NSDictionary *)responseObject;
            //获取直播rtmp地址
            NSString *rtmp = [dict objectForKey:@"url"];
            ShareCamereViewController *liveVC = [[ShareCamereViewController alloc] init];
            liveVC.islLve = YES;
            liveVC.isShare = NO;
            liveVC.shareStaue = [[dict objectForKey:@"share"] intValue];
            //        liveVC.url = @"http://zb.v.qq.com:1863/?progid=3900155972";
            liveVC.url = rtmp;
            liveVC.accecc_token = self.accessToken;//
            liveVC.deviceId = deviceid;//设备ID
            liveVC.playerTitle = [[dict objectForKey:@"description"] stringByAppendingString:@"(直播)"];
            [[SliderViewController sharedSliderController].navigationController pushViewController:liveVC animated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"失败了");
            [_loadingView hide:YES];
            UIAlertView *badInternetView = [[UIAlertView alloc] initWithTitle:@"网络延时" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            [badInternetView show];
        }];
    }else
    {
        //设备不在线
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备不在线" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [view show];
    }
}
#pragma mark - cellAccessory
////点击右边附件触发的方法
- (void)accessoryButtonTappedAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UITableViewCell  *cell;
    if (iOS7) {
        cell = (UITableViewCell *)button.superview.superview;
    }else
    {
        cell = (UITableViewCell *)button.superview;
    }
    int row = [_tableView indexPathForCell:cell].row;
    CameraSetViewController *setVC = [[CameraSetViewController alloc] init];
    NSDictionary *dict = [_fakeData objectAtIndex:row];
    setVC.deviceDesc = [dict objectForKey:@"description"];
    setVC.access_token = self.accessToken;
    setVC.deviceid = [dict objectForKey:@"deviceid"];
    setVC.index = row;
    setVC.delegate = self;
    [[SliderViewController sharedSliderController].navigationController pushViewController:setVC animated:YES];
}

#pragma mark - cameraSetDelegate
- (void)logoutCameraAtindex:(int)index
{
//    [self isLoadingView];
    NSLog(@"=============_fakeData：%@",_fakeData);
    __unsafe_unretained MyCameraViewController *vc = self;
        //向服务器发起请求
    NSString *urlSTR = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=list&access_token=%@&device_type=1",self.accessToken];
    [[AFHTTPSessionManager manager] GET:urlSTR parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        //2、初始化数据
        _fakeData = [NSMutableArray array];
        downloadArr = [NSMutableArray array];
        downloadArr = [dict objectForKey:@"list"];
        NSLog(@"downloadArr:%@",downloadArr);
        [_loadingView hide:YES];

        if (downloadArr.count>20) {
            for (int i = 0; i < 20; i++) {
                [vc->_fakeData addObject:[downloadArr objectAtIndex:i]];
            }
        }else
        {
            vc->_fakeData = (NSMutableArray *)downloadArr;
        }

        [_tableView reloadData];//刷新界面

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];

    //Url示例:https://pcs.baidu.com/rest/2.0/pcs/device?method=register&deviceid=46192376&access_token=52.458ff6f376002020f442208e094ca7b7.2592000.1405677428.906252268-2271149&device_type=1&desc=都是测试数据
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)userInfoNotification:(NSNotification *)notif
//{
//    NSDictionary *userinfoDict = [notif userInfo];
//    NSLog(@"userInfoDict:%@",userinfoDict);
//    self.accessToken = [userinfoDict objectForKey:@"accessToken"];
//}

//强制不允许转屏
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

//- (void)dealloc
//{
//    //移除观察者
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (void)viewWillAppear:(BOOL)animated
{
//    [[MJRefreshHeaderView header] beginRefreshing];
}

- (void)modifySuccess:(NSNotification *)notif
{
    [self logoutCameraAtindex:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear");
}

@end
