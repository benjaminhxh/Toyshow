//
//  MyCameraViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-19.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#define kGrant @"mygrant"

#import "MyCameraViewController.h"
#import "PlayerViewController.h"
#import "MJRefresh.h"
#import "CameraSetViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Reachability1.h"
#import "ThumbnailViewController.h"

@interface MyCameraViewController ()<UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate,MBProgressHUDDelegate,CameraSetViewControllerDelegate,PlayerViewControllerDelegate>
{
    BOOL _reloading;
    UITableView *_tableView;
    MJRefreshHeaderView *_headerView;
    MJRefreshFooterView *_footerView;
    NSMutableArray *_myCameraFakeData,*_authorCameraFakeData;
    NSMutableArray *mydownloadArr;
    MBProgressHUD *_loadingView,*badInternetHub;
    UILabel *noDataLoadL,*noInternetL;
    PlayerViewController *liveVC;
    BOOL notFirstFlag;
    UIImage *setBtnImage;
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
    
    setBtnImage= [ UIImage imageNamed:@"setanniuhei@2x"];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, kWidth, [UIScreen mainScreen].bounds.size.height-65) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:_tableView];
    
    noInternetL = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, kWidth, 44)];
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

    noDataLoadL = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, kWidth, 44)];
    noDataLoadL.text = @"无更多数据加载";
    noDataLoadL.backgroundColor = [UIColor grayColor];
    noDataLoadL.font = [UIFont systemFontOfSize:14];
    noDataLoadL.textAlignment = NSTextAlignmentCenter;
    noDataLoadL.hidden = YES;
    [self.view addSubview:noDataLoadL];
    //2、初始化数据
    _myCameraFakeData = [NSMutableArray array];
    _authorCameraFakeData = [NSMutableArray array];
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

- (void)addheader{
    __unsafe_unretained MyCameraViewController *vc = self;
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        //向服务器发起请求
        //1、取 授权的摄像头列表
        NSString *listGrantURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=listgrantdevice&access_token=%@",self.accessToken];
        [[AFHTTPRequestOperationManager manager] GET:listGrantURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            notFirstFlag = YES;
            NSDictionary *dict = (NSDictionary *)responseObject;
            //2、初始化数据
            [_authorCameraFakeData removeAllObjects];
            NSMutableArray *downloadArr = [NSMutableArray array];
            downloadArr = [[dict objectForKey:@"list"] mutableCopy];
            if (downloadArr.count == 0) {
                
            }else
            {
//                if (downloadArr.count>20)
//                {
//                    for (int i = 0; i < 20; i++)
//                    {
//                        NSMutableDictionary *mutabDict = [[downloadArr objectAtIndex:i] mutableCopy];
//                        [mutabDict setValue:kGrant forKey:kGrant];
//                        [vc->_fakeData addObject:mutabDict];
//                    }
//                }else
                {
                    for (int i = 0; i < downloadArr.count; i++)
                    {
                        NSMutableDictionary *mutabDict = [[downloadArr objectAtIndex:i] mutableCopy];
                        [mutabDict setValue:kGrant forKey:kGrant];
                        [vc->_authorCameraFakeData addObject:mutabDict];
                    }
                }
            }
            //2、取我的摄像头列表
            NSString *urlSTR = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=list&access_token=%@&device_type=1",self.accessToken];
            [[AFHTTPRequestOperationManager manager] GET:urlSTR parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [_myCameraFakeData removeAllObjects];
                NSDictionary *mydict = (NSDictionary *)responseObject;
                //2、初始化数据
                mydownloadArr = [NSMutableArray array];
                mydownloadArr = [[mydict objectForKey:@"list"] mutableCopy];
                if (mydownloadArr.count == 0) {
                    [self MBprogressViewHubLoading:@"无摄像头"];
                    [badInternetHub hide:YES afterDelay:1];
                }else
                {
                    if (mydownloadArr.count>20) {
                        for (int i = 0; i < 20; i++) {
                            [vc->_myCameraFakeData addObject:[mydownloadArr objectAtIndex:i]];
                        }
                    }else
                    {
                        for (int i = 0; i < mydownloadArr.count; i++) {
                            [vc->_myCameraFakeData addObject:[mydownloadArr objectAtIndex:i]];
                        }
                    }
                }
                [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:KdurationSuccess];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                notFirstFlag = YES;
                if (vc->_authorCameraFakeData.count) {
                    
                }else
                {
                    [self MBprogressViewHubLoading:@"网络延时"];
                    [badInternetHub hide:YES afterDelay:1];}
                [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:KdurationSuccess];
            }];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            notFirstFlag = YES;
        }];
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是header
        [vc performSelector:@selector(doneWithViewWithNoInterNet:) withObject:refreshView afterDelay:KdurationFail];
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
        if(_myCameraFakeData.count < (mydownloadArr.count))
        {
            if (_myCameraFakeData.count+20 > mydownloadArr.count) {
                for (int i = _myCameraFakeData.count; i<mydownloadArr.count; i++) {
                    [_myCameraFakeData addObject:[mydownloadArr objectAtIndex:i]];
                }
            }else
            {
                for (int i = 0; i < 20; i++) {
                    [_myCameraFakeData addObject:[mydownloadArr objectAtIndex:i]];
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
    [sender endRefreshing];
    [_tableView reloadData];

}

- (void)doneWithViewWithNoInterNet:(MJRefreshBaseView*)sender
{
    //刷新表格
    [sender endRefreshing];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section) {
        return _myCameraFakeData.count;
    }else
    {
        return _authorCameraFakeData.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
   UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (indexPath.section) {
        //我的摄像头
        if (nil == cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MyCameraCell" owner:self options:nil] lastObject];
        }
        NSDictionary *myCameraDict = [_myCameraFakeData objectAtIndex:indexPath.row];
        
        self.cameraTitle.text = [myCameraDict objectForKey:@"description"];
        NSString *status = [myCameraDict objectForKey:@"status"];
        int stat = [status intValue];
        int shareStatue = [[myCameraDict objectForKey:@"share"] intValue];
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
        NSString *urlImage = [myCameraDict objectForKey:@"thumbnail"];
        [self.cameraPic setImageWithURL:[NSURL URLWithString:urlImage]];
    }else{
        //授权的摄像头
        if (nil == cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"MyCameraCell" owner:self options:nil] lastObject];
        }
        NSDictionary *cameraUserInfoDict = [_authorCameraFakeData objectAtIndex:indexPath.row];
        self.cameraTitle.text = [NSString stringWithFormat:@"(授权)%@",[cameraUserInfoDict objectForKey:@"description"]];
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
    }
    
    UIButton *button = [ UIButton buttonWithType:UIButtonTypeCustom ];
    CGRect frame;
    if (iphone5) {
      frame = CGRectMake( 0 , 0 , 60 , 60 );
    }else{
        frame = CGRectMake(0, 0, 40, 30);
    }
    button.frame = frame;
    [button setImage:setBtnImage forState:UIControlStateNormal ];
//            button.backgroundColor = [UIColor redColor ];
    [button addTarget:self action:@selector(accessoryButtonTappedAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *cameraDict = [NSDictionary dictionary];
    if (indexPath.section) {
        cameraDict = [_myCameraFakeData objectAtIndex:indexPath.row];
        liveVC.playerTitle = [[cameraDict objectForKey:@"description"] stringByAppendingString:@"(直播)"];

    }else{
        cameraDict = [_authorCameraFakeData objectAtIndex:indexPath.row];
        liveVC.playerTitle = [[cameraDict objectForKey:@"description"] stringByAppendingString:@"(授权)"];
    }
//    NSString *stream_id = [dict objectForKey:@"stream_id"];
    NSString *deviceid = [cameraDict objectForKey:@"deviceid"];
    NSString *status = [cameraDict objectForKey:@"status"];
    int stat = [status intValue];

    //判断是被是否在线，在线则可以看直播
    if (stat)
    {
        NSString *liveUrl = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=liveplay&access_token=%@&deviceid=%@",self.accessToken,deviceid];
        NSString *share = [cameraDict objectForKey:@"share"];
        liveVC.delegate = self;
        liveVC.isLive = YES;
        liveVC.isShare = NO;
        liveVC.shareStaue = [share intValue];
        ////NSLog(@"live.share:%d",liveVC.shareStaue);
        //        liveVC.url = @"http://zb.v.qq.com:1863/?progid=3900155972";
        liveVC.url = liveUrl;
        liveVC.accecc_token = self.accessToken;//
        liveVC.deviceId = deviceid;//设备ID
        
        [[SliderViewController sharedSliderController].navigationController pushViewController:liveVC animated:YES];
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
////点击右边自定义附件触发的方法
- (void)accessoryButtonTappedAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    UITableViewCell  *cell;
    if (iOS8) {
        cell = (UITableViewCell *)button.superview;
    }else if (iOS7) {
        cell = (UITableViewCell *)button.superview.superview;
    }else
    {
        cell = (UITableViewCell *)button.superview;
    }
    int row = [_tableView indexPathForCell:cell].row;
    NSDictionary *dict = [NSDictionary dictionary];
    CameraSetViewController *setVC = [[CameraSetViewController alloc] init];

    int section = [_tableView indexPathForCell:cell].section;
    if (section) {
        dict = [_myCameraFakeData objectAtIndex:(row)];
        //我的摄像头设置
        setVC.isAuthorDevice = NO;
        setVC.index = row;
        setVC.isOnline = [[dict objectForKey:@"status"] intValue];
        setVC.shareIndex = [[dict objectForKey:@"share"] intValue];
    }
    else{
        //授权的设备设置
        dict = [_authorCameraFakeData objectAtIndex:row];
        setVC.isAuthorDevice = YES;

    }
    setVC.access_token = self.accessToken;
    setVC.deviceid = [dict objectForKey:@"deviceid"];
    setVC.deviceDesc = [dict objectForKey:@"description"];
    setVC.delegate = self;

    [[SliderViewController sharedSliderController].navigationController pushViewController:setVC animated:YES];
}

#pragma mark - cameraSetDelegate
- (void)logoutCameraAtindex:(int)index
{
    [self reloadMyCameraListView];
//    [_headerView beginRefreshing];
}

#pragma mark - PlayerViewDelegate
- (void)playerViewBack:(NSString *)str
{
    [self reloadMyCameraListView];
//    [_headerView beginRefreshing];

}

- (void)reloadMyCameraListView
{
//    NSLog(@"reloadMyCameraListView");
    [self isLoadingView];
    _loadingView.detailsLabelText = @"";

    __unsafe_unretained MyCameraViewController *vc = self;
    NSString *listGrantURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=listgrantdevice&access_token=%@",self.accessToken];
    [[AFHTTPRequestOperationManager manager] GET:listGrantURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        notFirstFlag = YES;
        NSDictionary *dict = (NSDictionary *)responseObject;
        //2、初始化数据
        [_authorCameraFakeData removeAllObjects];
       NSMutableArray *downloadArr = [NSMutableArray array];
        downloadArr = [dict objectForKey:@"list"];
        if (downloadArr.count == 0) {
        }else
        {
            if (downloadArr.count>20)
            {
                for (int i = 0; i < 20; i++)
                {
                    NSMutableDictionary *mutabDict = [[downloadArr objectAtIndex:i] mutableCopy];
                    [vc->_authorCameraFakeData addObject:mutabDict];
                }
            }else
            {
                for (int i = 0; i < downloadArr.count; i++)
                {
                    NSMutableDictionary *mutabDict = [[downloadArr objectAtIndex:i] mutableCopy];
                    [mutabDict setValue:kGrant forKey:kGrant];
                    [vc->_authorCameraFakeData addObject:mutabDict];
                }
            }
        }
        //我的摄像头
        NSString *urlSTR = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=list&access_token=%@&device_type=1",self.accessToken];
        [[AFHTTPRequestOperationManager manager] GET:urlSTR parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [_loadingView hide:YES];
            [_myCameraFakeData removeAllObjects];
            NSDictionary *mydict = (NSDictionary *)responseObject;
            //2、初始化数据
            mydownloadArr = [NSMutableArray array];
            mydownloadArr = [mydict objectForKey:@"list"];
            if (mydownloadArr.count == 0) {
            }else
            {
                if (mydownloadArr.count>20) {
                    for (int i = 0; i < 20; i++) {
                        [vc->_myCameraFakeData addObject:[mydownloadArr objectAtIndex:i]];
                    }
                }else
                {
                    for (int i = 0; i < mydownloadArr.count; i++) {
                        [vc->_myCameraFakeData addObject:[mydownloadArr objectAtIndex:i]];
                    }
                }
            }
            [_tableView reloadData];//刷新界面
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [_loadingView hide:YES];
            [_myCameraFakeData removeAllObjects];
            [_tableView reloadData];//刷新界面

        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_loadingView hide:YES];
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//强制不允许转屏
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
}

- (void)dealloc
{
    //移除观察者
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    NSString *accesstoken = [[SliderViewController sharedSliderController].dict objectForKey:@"accessToken"];
    if (![self.accessToken isEqualToString:accesstoken]) {
        self.accessToken = accesstoken;
//        [self reloadMyCameraListView];
        [_headerView beginRefreshing];
        return;
    }
    else if (notFirstFlag) {
        [_headerView beginRefreshing];
        return;
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

@end
