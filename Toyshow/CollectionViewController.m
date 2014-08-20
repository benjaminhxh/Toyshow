//
//  CollectionViewController.m
//  Joyshow
//
//  Created by zhxf on 14-7-29.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "CollectionViewController.h"
#import "MJRefreshFooterView.h"
#import "MJRefreshHeaderView.h"
#import "Reachability1.h"
#import "UIImageView+AFNetworking.h"
#import "ShareCamereViewController.h"

@interface CollectionViewController ()<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate,ShareCamereViewControllerDelegate>
{
    UITableView *_tableView;
    UILabel *noInternetL,*noDataLoadL;
    MBProgressHUD *_loadingView,*badInternetHub;
    NSMutableArray *_fakeData,*downloadArr;
    NSString *accessToken;
    ShareCamereViewController *liveVC;
}
@end

@implementation CollectionViewController

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
    UIImageView *imgV=[[UIImageView alloc] initWithFrame:self.view.bounds];
    [imgV setImage:[UIImage imageNamed:@"dabeijing@2x"]];
    [self.view addSubview:imgV];
    
    UIImageView *navBar=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    navBar.image=[UIImage imageNamed:navigationBarImageiOS7];
    //    navBar.alpha=0.8;
    navBar.userInteractionEnabled = YES;
    [self.view addSubview:navBar];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 90, 22);
    [backBtn setTitle:@"我的收藏" forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(leftClick) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:backBtn];
    accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kUserAccessToken];

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
    liveVC = [[SliderViewController sharedSliderController].dict objectForKey:kplayerKey];
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
    [[SliderViewController sharedSliderController] leftItemClick];
}

-(void)btnNextClick:(id)sender{
    //    [[SliderViewController sharedSliderController].navigationController pushViewController:[[ViewController1 alloc] init] animated:YES];
}

- (void)addheader{
    __unsafe_unretained CollectionViewController *vc = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        //向服务器发起请求
        NSString *urlSTR = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=listsubscribe&access_token=%@",accessToken];
        [[AFHTTPSessionManager manager] GET:urlSTR parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
//            NSLog(@"收藏的dict:%@",dict);
            //2、初始化数据
            _fakeData = [NSMutableArray array];
            downloadArr = [NSMutableArray array];
            downloadArr = [dict objectForKey:@"device_list"];
//            NSLog(@"downloadArr:%@",downloadArr);
            if (downloadArr.count == 0) {
                [self MBprogressViewHubLoading:@"无摄像头" withMode:4];
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

            [self MBprogressViewHubLoading:@"网络延时" withMode:4];
            [badInternetHub hide:YES afterDelay:1];
            [vc performSelector:@selector(doneWithViewWithNoInterNet:) withObject:refreshView afterDelay:KdurationSuccess];
        }];
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是header
        [vc performSelector:@selector(doneWithViewWithNoInterNet:) withObject:refreshView afterDelay:KdurationFail];
        NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
//    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
//        // 刷新完毕就会回调这个Block
//        NSLog(@"%@----刷新完毕", refreshView.class);
//    };
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
}

- (void)addFooter
{
    __unsafe_unretained CollectionViewController *vc = self;
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
        cell = [[[NSBundle mainBundle] loadNibNamed:@"collectCell" owner:self options:nil] lastObject];
    
        NSDictionary *cameraUserInfoDict = [_fakeData objectAtIndex:indexPath.row];
        self.collectTitle.text = [cameraUserInfoDict objectForKey:@"description"];
        NSNumber *status = [cameraUserInfoDict objectForKey:@"status"];
        int stat = [status intValue];
        if (stat) {
            self.collectStatue.text = @"在线";
            self.collectStatue.textColor = [UIColor blueColor];
        }else
        {
            self.collectStatue.text = @"离线";
            self.collectStatue.textColor = [UIColor grayColor];
        }
        NSString *urlImage = [cameraUserInfoDict objectForKey:@"thumbnail"];
        [self.collectImageView setImageWithURL:[NSURL URLWithString:urlImage]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cameraDict = [_fakeData objectAtIndex:indexPath.row];
    NSString *deviceId = [cameraDict objectForKey:@"deviceid"];
    NSString *shareid = [cameraDict objectForKey:@"shareid"];
    NSString *status = [cameraDict objectForKey:@"status"];
    NSString *uk = [cameraDict objectForKey:@"uk"];
    int stat = [status intValue];
    //判断是被是否在线，在线则可以看直播
    if (stat) {
        [self isLoadingView];
        NSString *liveUrl = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=liveplay&shareid=%@&uk=%@",shareid,uk];
        NSLog(@"collectURL:%@",liveUrl);
        [[AFHTTPRequestOperationManager manager] POST:liveUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [_loadingView hide:YES];
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSLog(@"播放摄像头的dict:%@",dict);
            //获取直播rtmp地址
            NSString *rtmp = [dict objectForKey:@"url"];
            NSString *share = [cameraDict objectForKey:@"share"];
            liveVC.isLive = YES;
            liveVC.isShare = YES;
            liveVC.shareId = shareid;
            liveVC.uk = uk;
            liveVC.shareStaue = [share intValue];
//            NSLog(@"shareStaue:%d",liveVC.shareStaue);
            liveVC.url = rtmp;
            liveVC.isCollect = YES;
            liveVC.delegate = self;
            liveVC.accecc_token = accessToken;//
            liveVC.deviceId = deviceId;//设备ID
            liveVC.playerTitle = [[dict objectForKey:@"description"] stringByAppendingString:@"(收藏)"];
            [[SliderViewController sharedSliderController].navigationController pushViewController:liveVC animated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"失败了");
            [_loadingView hide:YES];
            [self MBprogressViewHubLoading:@"网络延时"withMode:4];
            [badInternetHub hide:YES afterDelay:1];
        }];
    }else
    {
        [self MBprogressViewHubLoading:@"设备不在线" withMode:4];
        [badInternetHub hide:YES afterDelay:1];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)MBprogressViewHubLoading:(NSString *)labtext withMode:(int)mode
{
    if (badInternetHub) {
        badInternetHub.labelText = labtext;
//        badInternetHub.mode = mode;
        [badInternetHub show:YES];
        return;
    }
    badInternetHub = [[MBProgressHUD alloc] initWithView:_tableView];
    badInternetHub.labelText = labtext;
//    badInternetHub.mode = mode;
    badInternetHub.square = YES;
    [_tableView addSubview:badInternetHub];
    [badInternetHub show:YES];
}

#pragma mark - cancelCollectCamere
- (void)cancelCameraCollection
{
    [self reloadCollectList];
}

- (void)reloadCollectList
{
    __unsafe_unretained CollectionViewController *vc = self;
    //向服务器发起请求
    NSString *urlSTR = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=listsubscribe&access_token=%@",accessToken];
    [self MBprogressViewHubLoading:@"" withMode:0];
    [[AFHTTPSessionManager manager] GET:urlSTR parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSLog(@"收藏的dict:%@",dict);
        //2、初始化数据
        _fakeData = [NSMutableArray array];
        downloadArr = [NSMutableArray array];
        downloadArr = [dict objectForKey:@"device_list"];
        NSLog(@"downloadArr:%@",downloadArr);
        if (downloadArr.count == 0) {
            [self MBprogressViewHubLoading:@"无摄像头" withMode:4];
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
//            [self MBprogressViewHubLoading:@"" withMode:0];
            [badInternetHub hide:YES afterDelay:1];
        }
        
        [_tableView reloadData];//刷新界面
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self MBprogressViewHubLoading:@"网络延时" withMode:4];
        [badInternetHub hide:YES afterDelay:1];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSString *accessT = [[NSUserDefaults standardUserDefaults] objectForKey:kUserAccessToken];
    if (![accessToken isEqualToString:accessT]) {
        accessToken = accessT;
        [self reloadCollectList];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
