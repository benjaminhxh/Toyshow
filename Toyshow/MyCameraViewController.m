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
#import "ThumbnailViewController.h"
#import "ShareCamereViewController.h"
#import "MJRefresh.h"
#import "AFNetworking.h"

@interface MyCameraViewController ()<UITableViewDelegate,UITableViewDataSource,MJRefreshBaseViewDelegate,MBProgressHUDDelegate>
{
    NSArray *_titleArr,*_imageArr;
    NSArray *_shareCameraListArr;
    BOOL _reloading;
    UITableView *_tableView;
    MJRefreshHeaderView *_headerView;
    MJRefreshFooterView *_footerView;
    NSMutableArray *_fakeData;
    NSArray *downloadArr;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoNotification:) name:kUserInfoNotification object:nil];
    
    UIImageView *imgV=[[UIImageView alloc] initWithFrame:self.view.bounds];
    [imgV setImage:[UIImage imageNamed:@"dabeijing@2x"]];
    [self.view addSubview:imgV];
    
    UIImageView *navBar=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    navBar.image=[UIImage imageNamed:navigationBarImageiOS7];
    //    navBar.alpha=0.8;
    navBar.userInteractionEnabled = YES;
    [self.view addSubview:navBar];
    UIImage *image1 = [UIImage imageNamed:@"wo_shejingtou"];
    UIImage *image2 = [UIImage imageNamed:@"tianjia"];
    UIImage *image3 = [UIImage imageNamed:@"fxsjt"];
    UIImage *image4 = [UIImage imageNamed:@"shejingtou_shezhi"];
    UIImage *image5 = [UIImage imageNamed:@"tuichu"];
    UIImage *image6 = [UIImage imageNamed:@"bangzhu_tubiao"];
    UIImage *image7 = [UIImage imageNamed:@"guanyu"];
    _imageArr = [NSArray arrayWithObjects:image1,image2,image3,image4,image5,image6,image7,image3, nil];
    _titleArr = @[@"北京",@"上海",@"广州",@"深圳",@"天津",@"南京",@"重庆",@"成都"];
    

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 120, 22);
    [backBtn setTitle:@"我的摄像头" forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(leftClick) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:backBtn];
    
//    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightBtn.frame = CGRectMake(self.view.frame.size.width-44, [UIApplication sharedApplication].statusBarFrame.size.height, 44, 44);
//    [rightBtn setTitle:@"右" forState:UIControlStateNormal];
//    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [rightBtn addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
//    [navBar addSubview:rightBtn];
    
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(25, 25, 120, 24)];
//    title.textColor = [UIColor whiteColor];
//    title.text = @"我的摄像头";
//    title.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:title];
	// Do any additional setup after loading the view.
//    _refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 65, 320, self.view.frame.size.height-65)];
//    _refreshView.delegate = self;
//    _refreshView.userInteractionEnabled = YES;
//    _refreshView.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:_refreshView];
//    [_refreshView refreshLastUpdatedDate];
    
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

//    [self isLoadingView];//模拟正在加载
}

- (void)isLoadingView
{
    _loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_loadingView];
    
    _loadingView.delegate = self;
    _loadingView.labelText = @"loading";
    _loadingView.detailsLabelText = @"正在加载，请稍后……";
    _loadingView.square = YES;
    [_loadingView showWhileExecuting:@selector(isLoadingAnimation) onTarget:self withObject:nil animated:YES];

}

- (void)isLoadingAnimation
{
    sleep(3);
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
            downloadArr = [NSArray array];
            downloadArr = [dict objectForKey:@"list"];
            NSLog(@"downloadArr:%@",downloadArr);
//            {“count”:N,
//        “list”:[{DEVICE_ID1, STREAM_ID1, STATUS1, DESC1, CVR_DAY1, EXPIRE_TIME1,SHARE_TYPE1, THUMBNAIL1},
//                {DEVICE_ID2, STREAM_ID2,STATUS2,DESC2, CVR_DAY2, EXPIRE_TIME2,SHARE_TYPE2, THUMBNAIL1},...
//                {DEVICE_IDN, STREAM_IDN,STATUSN,DESCN, CVR_DAYn, EXPIRE_TIMEn,SHARE_TYPEn, THUMBNAILn}],
//                “request_id”:12345678}
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
            }else
            {
                self.cameraStatus.text = @"离线";
            }

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
    ShareCamereViewController *liveVC = [[ShareCamereViewController alloc] init];
    liveVC.islLve = YES;
    liveVC.isShare = NO;
    liveVC.url = @"http://zb.v.qq.com:1863/?progid=3900155972";
    liveVC.playerTitle = @"东方卫视（直播……）";
    [[SliderViewController sharedSliderController].navigationController pushViewController:liveVC animated:YES];
}
#pragma mark - cellAccessory
////点击右边附件触发的方法
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"accessoryType:%d",indexPath.row);
    ThumbnailViewController *thumbVC = [[ThumbnailViewController alloc] init];
    [[SliderViewController sharedSliderController].navigationController pushViewController:thumbVC animated:YES];
}

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
    NSLog(@"row:%d",row);
    ThumbnailViewController *thumbVC = [[ThumbnailViewController alloc] init];
    [[SliderViewController sharedSliderController].navigationController pushViewController:thumbVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)userInfoNotification:(NSNotification *)notif
{
    NSDictionary *userinfoDict = [notif userInfo];
    NSLog(@"userInfoDict:%@",userinfoDict);
    self.accessToken = [userinfoDict objectForKey:@"accessToken"];
}

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
@end
