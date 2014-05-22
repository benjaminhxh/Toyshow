
//
//  MainViewController.m
//  LeftRightSlider
//
//  Created by Zhao Yiqi on 13-11-27.
//  Copyright (c) 2013年 Zhxf. All rights reserved.
//分享的摄像头页面

#import "MainViewController.h"
#import "SliderViewController.h"
#import "ShareCamereViewController.h"
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"
//#import "NetworkRequest.h"
#import "AFNetworking.h"
#import "Reachability1.h"

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_shareCameraListArr;
    BOOL _reloading;
//    EGORefreshTableHeaderView *_refreshView;
    UITableView *_tableView;
    MJRefreshHeaderView *_headerView;
    MJRefreshFooterView *_footerView;
    NSMutableArray *_fakeData;
    NSArray *downloadArr;
    UIActivityIndicatorView *activiView;
    UILabel *blockLabel,*noDataLoadL;
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

- (NSDateFormatter *)dateFormate
{
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"MM-dd HH:mm"];
    return dateFormate;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"MM-dd HH:mm"];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:datenow];
    NSDate *localeDate = [datenow  dateByAddingTimeInterval: interval];
    NSString *nowTimeStr = [dateFormate stringFromDate:localeDate];
    NSLog(@"nowTimeStr:%@", nowTimeStr);
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[localeDate timeIntervalSince1970]];
//    NSLog(@"timeSp:%@",timeSp); //时间戳的值
//    NSDate *nowTime = [NSDate dateWithTimeIntervalSince1970:[timeSp integerValue]];
//    NSLog(@"1363948516  = %@",nowTime);
   NSInteger endTime = ([timeSp integerValue]/30)*30;
    NSLog(@"endTime:%d",endTime);
    NSDate *endT = [NSDate dateWithTimeIntervalSince1970:endTime];
    NSDateFormatter *dateFormate2 = [[NSDateFormatter alloc] init];
    [dateFormate2 setDateFormat:@"MM-dd HH:mm"];
    NSString *lastTime = [dateFormate2 stringFromDate:endT];
//    NSLog(@"最近半小时= %@",endT);
    NSLog(@"last:%@",lastTime);
//    [self networkReloadData];
//       ([UIScreen currentScreenSizeWithInterfaceOrientation:UIInterfaceOrientationPortrait].height > 480)
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
    
//    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    rightBtn.frame = CGRectMake(self.view.frame.size.width-44, [UIApplication sharedApplication].statusBarFrame.size.height, 44, 44);
//    [rightBtn setTitle:@"右" forState:UIControlStateNormal];
//    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [rightBtn addTarget:self action:@selector(rightItemClick) forControlEvents:UIControlEventTouchUpInside];
//    [navBar addSubview:rightBtn];
    
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(25, 25, 120, 24)];
//    title.textColor = [UIColor whiteColor];
//    title.text = @"分享的摄像头";
//    title.textAlignment = NSTextAlignmentLeft;
//    [self.view addSubview:title];
	// Do any additional setup after loading the view.
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, 320, [UIScreen mainScreen].bounds.size.height-65) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    //2、初始化数据
    _fakeData = [NSMutableArray array];
    [self addheader];
    [self addFooter];

    blockLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, 320, 44)];
    blockLabel.text = @"当前网络不可用，请检查你的网络设置";
    blockLabel.backgroundColor = [UIColor grayColor];
    blockLabel.font = [UIFont systemFontOfSize:14];
    blockLabel.textAlignment = NSTextAlignmentCenter;
    blockLabel.hidden = YES;
    [self.view addSubview:blockLabel];
    
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
            blockLabel.hidden = YES;
        });
    };
    
    reachab.unreachableBlock = ^(Reachability1 *unreachabil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            blockLabel.hidden = NO;
        });
    };
    [reachab startNotifier];
}

- (void)addheader{
    __unsafe_unretained MainViewController *vc = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        //向服务器发起请求
//        [[AFHTTPRequestOperationManager manager]GET:@"http://www.douban.com/j/app/radio/channels" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSDictionary *dict = (NSDictionary *)responseObject;
//            //2、初始化数据
//            _fakeData = [NSMutableArray array];
//            downloadArr = [NSArray array];
//            downloadArr = [dict objectForKey:@"channels"];
//            NSLog(@"downloadArr:%@",downloadArr);
//            if (downloadArr.count>20) {
//                for (int i = 0; i < 20; i++) {
//                    [vc->_fakeData addObject:[downloadArr objectAtIndex:i]];
//                }
//            }else
//            {
//                vc->_fakeData = (NSMutableArray *)downloadArr;
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            
//        }];

        [[AFHTTPSessionManager manager] GET:@"http://www.douban.com/j/app/radio/channels" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            //2、初始化数据
            _fakeData = [NSMutableArray array];
            downloadArr = [NSArray array];
            downloadArr = [dict objectForKey:@"channels"];
//            NSLog(@"downloadArr:%@",downloadArr);
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
            NSLog(@"下载数据失败");
            NSLog(@"tabsk%@",task);
            NSLog(@"eror:%@",error);
        }];
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是header
        [vc performSelector:@selector(doneWithViewWithNoInterNet:) withObject:refreshView afterDelay:KdurationFail];
        
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
    {
        if (nil == cell) {
            //            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ShareCameraCell" owner:self options:nil] lastObject];
            self.cameraId.text = @"20140312";
            self.cameraName.text = [[_fakeData objectAtIndex:indexPath.row] objectForKey:@"name"];
            self.cameraStatus.text = @"在线";
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            [self.cameraHead.image setImageWithURL:[(NSURL *)url];    //AFNetWorking

        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShareCamereViewController *shareVC = [[ShareCamereViewController alloc] init];
    shareVC.islLve = YES;
    shareVC.isShare = YES;
    shareVC.playerTitle = @"浙江卫视(分享)";
    shareVC.url = @"http://zb.v.qq.com:1863/?progid=1975434150";
    [[SliderViewController sharedSliderController].navigationController pushViewController:shareVC animated:YES];
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

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
//- (void)viewWillAppear:(BOOL)animated
//{
//    activiView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(130, 210, 120, 120)];
//    activiView.backgroundColor = [UIColor grayColor];
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(45, 60, 60, 60)];
//    title.text = @"正在加载……";
//    title.font = [UIFont systemFontOfSize:8];
//    title.textAlignment = NSTextAlignmentCenter;
//    [activiView addSubview:title];
//    [activiView startAnimating];
//    [_tableView addSubview:activiView];
//
//}
//- (IBAction)clickMOreAction:(id)sender {
//    UIButton *button = (UIButton *)sender;
//    cell = (UITableViewCell *)[button superview];
//    int row = [_tableView indexPathForCell:cell].row;
//    NSLog(@"row:%d",row);
//}
@end
