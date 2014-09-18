//
//  MyCameraViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-19.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "MyCameraViewController.h"
#import "ShareCamereViewController.h"
#import "MJRefresh.h"
#import "CameraSetViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Reachability1.h"
#import "ThumbnailViewController.h"

@interface MyCameraViewController ()<UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate,MBProgressHUDDelegate,CameraSetViewControllerDelegate,ShareCamereViewControllerDelegate>
{
    BOOL _reloading;
    UITableView *_tableView;
    MJRefreshHeaderView *_headerView;
    MJRefreshFooterView *_footerView;
    NSMutableArray *_fakeData;
    NSMutableArray *downloadArr;
    MBProgressHUD *_loadingView,*badInternetHub;
    UILabel *noDataLoadL,*noInternetL;
    ShareCamereViewController *liveVC;
    BOOL notFirstFlag;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.accessToken = [[SliderViewController sharedSliderController].dict objectForKey:@"accessToken"];
    
    UIImageView *imgV=[[UIImageView alloc] initWithFrame:self.view.bounds];
    [imgV setImage:[UIImage imageNamed:@"dabeijing@2x"]];
    [self.view addSubview:imgV];
    
    UIImageView *navBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 64)];
    navBar.image=[UIImage imageNamed:navigationBarImageiOS7];
    //    navBar.alpha=0.8;
    navBar.userInteractionEnabled = YES;
    [self.view addSubview:navBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifySuccess:) name:@"modifySuccess" object:nil];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 25, 120, 22);
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
    liveVC = [[[SliderViewController sharedSliderController].dict objectForKey:kplayerDict] objectForKey:kplayerKey];

}

- (void)isLoadingView
{
    if (_loadingView) {
        [_loadingView show:YES];
        return;
    }
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
    __unsafe_unretained MyCameraViewController *vc = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        //向服务器发起请求
        NSString *urlSTR = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=list&access_token=%@&device_type=1",self.accessToken];
        [[AFHTTPRequestOperationManager manager] GET:urlSTR parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            notFirstFlag = YES;
            NSDictionary *dict = (NSDictionary *)responseObject;
            //2、初始化数据
            _fakeData = [NSMutableArray array];
            downloadArr = [NSMutableArray array];
            downloadArr = [dict objectForKey:@"list"];
            //            ////NSLog(@"downloadArr:%@",downloadArr);
            if (downloadArr.count == 0) {
                //                UIAlertView *noDataView = [[UIAlertView alloc] initWithTitle:@"无摄像头" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
                //                [noDataView show];
                [self MBprogressViewHubLoading:@"无摄像头"];
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
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //            UIAlertView *noDataView = [[UIAlertView alloc] initWithTitle:@"网络延时" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
            //            [noDataView show];
            notFirstFlag = YES;
            [self MBprogressViewHubLoading:@"网络延时"];
            [badInternetHub hide:YES afterDelay:1];
            [vc performSelector:@selector(doneWithViewWithNoInterNet:) withObject:refreshView afterDelay:KdurationSuccess];
        }];
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是header
        [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:KdurationFail];
        ////NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
//    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
//        // 刷新完毕就会回调这个Block
//        ////NSLog(@"%@----刷新完毕", refreshView.class);
//    };
//    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
//        // 控件的刷新状态切换了就会调用这个block
//        switch (state) {
//            case MJRefreshStateNormal:
//                ////NSLog(@"%@----切换到：普通状态", refreshView.class);
//                break;
//                
//            case MJRefreshStatePulling:
//                ////NSLog(@"%@----切换到：松开即可刷新的状态", refreshView.class);
//                break;
//                
//            case MJRefreshStateRefreshing:
//                ////NSLog(@"%@----切换到：正在刷新状态", refreshView.class);
//                break;
//            default:
//                break;
//        }
//    };
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
            ////NSLog(@"%@----开始进入刷新状态", refreshView.class);
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
        }
            NSDictionary *cameraUserInfoDict = [_fakeData objectAtIndex:indexPath.row];
//            self.cameraId.text = [cameraUserInfoDict objectForKey:@"deviceid"];
            self.cameraTitle.text = [cameraUserInfoDict objectForKey:@"description"];
            NSString *status = [cameraUserInfoDict objectForKey:@"status"];
            int stat = [status intValue];
            int shareStatue = [[cameraUserInfoDict objectForKey:@"share"] intValue];
            if (stat) {
                self.cameraStatus.text = @"在线";
                self.cameraStatus.textColor = [UIColor blueColor];
            }else
            {
                self.cameraStatus.text = @"离线";
                self.cameraStatus.textColor = [UIColor grayColor];
            }
            switch (shareStatue) {
                case 0:
                    self.shareStatue.text = @"";
                    break;
                case 1:
                    self.shareStatue.text = @"公开分享";
                    break;
                case 2:
                    self.shareStatue.text = @"私密分享";
                    break;
                default:
                    break;
            }
            NSString *urlImage = [cameraUserInfoDict objectForKey:@"thumbnail"];
            [self.cameraPic setImageWithURL:[NSURL URLWithString:urlImage]];
            UIImage *image= [ UIImage imageNamed:@"setanniuhei@2x"];
            UIButton *button = [ UIButton buttonWithType:UIButtonTypeCustom ];
            CGRect frame = CGRectMake( 0.0 , 0.0 , 40 , 34 );
            button.frame = frame;
            [button setImage:image forState:UIControlStateNormal ];
//            button.backgroundColor = [UIColor clearColor ];
            [button addTarget:self action:@selector(accessoryButtonTappedAction:) forControlEvents:UIControlEventTouchUpInside];
            cell. accessoryView = button;
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cameraDict = [_fakeData objectAtIndex:indexPath.row];
//    NSString *stream_id = [dict objectForKey:@"stream_id"];
    NSString *deviceid = [cameraDict objectForKey:@"deviceid"];
    NSString *status = [cameraDict objectForKey:@"status"];
    int stat = [status intValue];

    //判断是被是否在线，在线则可以看直播
    if (stat) {
        [self isLoadingView];
        NSString *liveUrl = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=liveplay&access_token=%@&deviceid=%@",self.accessToken,deviceid];
        [[AFHTTPRequestOperationManager manager] POST:liveUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [_loadingView hide:YES];
            NSDictionary *dict = (NSDictionary *)responseObject;
            ////NSLog(@"播放摄像头的dict:%@",dict);
            //获取直播rtmp地址
            NSString *rtmp = [dict objectForKey:@"url"];
            NSString *share = [cameraDict objectForKey:@"share"];
            liveVC.delegate = self;
            liveVC.isLive = YES;
            liveVC.isShare = NO;
            liveVC.shareStaue = [share intValue];
            ////NSLog(@"live.share:%d",liveVC.shareStaue);
            ////NSLog(@"shareStaue:%d",liveVC.shareStaue);
            //        liveVC.url = @"http://zb.v.qq.com:1863/?progid=3900155972";
            liveVC.url = rtmp;
            liveVC.accecc_token = self.accessToken;//
            liveVC.deviceId = deviceid;//设备ID
            liveVC.playerTitle = [[dict objectForKey:@"description"] stringByAppendingString:@"(直播)"];
            [[SliderViewController sharedSliderController].navigationController pushViewController:liveVC animated:YES];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ////NSLog(@"失败了");
            [_loadingView hide:YES];
            [self MBprogressViewHubLoading:@"网络延时"];
            [badInternetHub hide:YES afterDelay:1];
        }];
    }else
    {
        //设备不在线,跳到录像列表
        ThumbnailViewController *thumbVC = [[ThumbnailViewController alloc] init];
        thumbVC.deviceID = deviceid;
        thumbVC.accessToken = self.accessToken;
        thumbVC.deviceDesc = [cameraDict objectForKey:@"description"];
        [[SliderViewController sharedSliderController].navigationController pushViewController:thumbVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    NSDictionary *dict = [_fakeData objectAtIndex:row];

//   BOOL status = [[dict objectForKey:@"status"] intValue];
//    if (status) {
        CameraSetViewController *setVC = [[CameraSetViewController alloc] init];
        setVC.deviceDesc = [dict objectForKey:@"description"];
        setVC.access_token = self.accessToken;
        setVC.deviceid = [dict objectForKey:@"deviceid"];
        setVC.index = row;
        setVC.isOnline = [[dict objectForKey:@"status"] intValue];
        setVC.delegate = self;
        [[SliderViewController sharedSliderController].navigationController pushViewController:setVC animated:YES];
//    }else
//    {
//        ThumbnailViewController *thumbVC = [[ThumbnailViewController alloc] init];
//        thumbVC.deviceID = [dict objectForKey:@"deviceid"];
//        thumbVC.accessToken = self.accessToken;
//        thumbVC.deviceDesc = [dict objectForKey:@"description"];
//        [[SliderViewController sharedSliderController].navigationController pushViewController:thumbVC animated:YES];
//
//    }
}

#pragma mark - cameraSetDelegate
- (void)logoutCameraAtindex:(int)index
{
//    [self isLoadingView];
    [self reloadMyCameraListView];
//    [_headerView beginRefreshing];
}

#pragma mark - PlayerViewDelegate
- (void)playerViewBack:(NSString *)str
{
    ////NSLog(@"str:%@",str);
    [self reloadMyCameraListView];
//    [_headerView beginRefreshing];

}

- (void)reloadMyCameraListView
{
    [self isLoadingView];
    _loadingView.detailsLabelText = @"";

    __unsafe_unretained MyCameraViewController *vc = self;
    //向服务器发起请求
    NSString *urlSTR = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=list&access_token=%@&device_type=1",self.accessToken];
    [[AFHTTPRequestOperationManager manager] GET:urlSTR parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        //2、初始化数据
        _fakeData = [NSMutableArray array];
        downloadArr = [NSMutableArray array];
        downloadArr = [dict objectForKey:@"list"];
        ////NSLog(@"downloadArr:%@",downloadArr);
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingView hide:YES];
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
//    ////NSLog(@"userInfoDict:%@",userinfoDict);
//    self.accessToken = [userinfoDict objectForKey:@"accessToken"];
//}

//强制不允许转屏
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc
{
    //移除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    NSString *accesstoken = [[SliderViewController sharedSliderController].dict objectForKey:@"accessToken"];
    if (![self.accessToken isEqualToString:accesstoken]) {
        self.accessToken = accesstoken;
        [self reloadMyCameraListView];
//        [_headerView beginRefreshing];
        return;
    }
    if (notFirstFlag) {
        [_headerView beginRefreshing];
    }
}
- (void)modifySuccess:(NSNotification *)notif
{
    [self logoutCameraAtindex:0];
}

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

@end
