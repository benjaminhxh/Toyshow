//
//  ThumbnailViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-28.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

//点播缩略图
#import "ThumbnailViewController.h"
#import "ShareCamereViewController.h"
#import "MJRefreshFooterView.h"
#import "MJRefreshHeaderView.h"
#import "SliderViewController.h"
#import "AFNetworking.h"

@interface ThumbnailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_fakeData;
    NSArray *downloadArr;
    MJRefreshFooterView *_footerView;
    MJRefreshHeaderView *_headerView;
    UILabel *noDataLoadL,*noInternetL;

}
@end

@implementation ThumbnailViewController

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
    UIImageView *background = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    background.image = [UIImage imageNamed:backGroundImage];
//    [self.view addSubview:background];
    background.userInteractionEnabled = YES;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 100, 22);
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn setTitle:@"点播列表" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];

//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(100, 25, 120, 24)];
//    title.textColor = [UIColor whiteColor];
//    title.text = @"点播列表";
//    title.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:title];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, 320, [UIScreen mainScreen].bounds.size.height-65) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_tableView addGestureRecognizer:recognizer];

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
}

- (NSDateFormatter *)dateFormateAlltime
{
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return dateFormate;
}

- (NSDate *)dateFrom:(NSDate *)datenow
{
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:datenow];
    NSDate *localeDate = [datenow  dateByAddingTimeInterval: interval];
    return localeDate;
}

- (void)backBtn
{
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

- (void)addheader{
    __unsafe_unretained ThumbnailViewController *vc = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _tableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        //向服务器发起请求
        NSDate *datenow = [NSDate dateWithTimeIntervalSinceNow:0];//现在时间,你可以输出来看下是什么格式
//        NSDate *localDate = [self dateFrom:datenow];
//        NSLog(@"当地时间localDate:%@",localDate);
//        NSString *nowTimeStr = [[self dateFormateAlltime] stringFromDate:datenow];
//        NSLog(@"现在时间:%@", nowTimeStr);
        long et = (long)[datenow timeIntervalSince1970];
//        NSLog(@"et:%ld",et);
        int st = et - 24*3600;
        NSString *urlStr = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=playlist&access_token=%@&deviceid=%@&st=%d&et=%ld",self.accessToken,self.deviceID,st,et];
        [[AFHTTPSessionManager manager] GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
//            NSLog(@"dict:%@",dict);
            //2、初始化数据
            _fakeData = [NSMutableArray array];
            downloadArr = [NSArray array];
            downloadArr = [dict objectForKey:@"results"];
            NSLog(@"downloadArr:%@=====%d",downloadArr,downloadArr.count);
            
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
            NSDictionary *errorDict = [error userInfo];
            NSLog(@"errorDict:%@",errorDict);
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
    __unsafe_unretained ThumbnailViewController *vc = self;
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
            cell = [[[NSBundle mainBundle] loadNibNamed:@"thumbCell" owner:self options:nil] lastObject];
            self.thumbTitle.text = self.deviceDesc;
            NSArray *arr = [downloadArr objectAtIndex:indexPath.row];
            NSNumber *st = [arr objectAtIndex:0];
            float stf = [st floatValue];
            NSDate *currentTime = [NSDate dateWithTimeIntervalSince1970:stf];
            NSString *startT = [[self dateFormatterMMddHHmm] stringFromDate:currentTime];
            
            NSNumber *et = [arr objectAtIndex:1];
//            NSLog(@"et:%d",[et intValue]);
            float endtf = [et floatValue];
            NSDate *endfTime = [NSDate dateWithTimeIntervalSince1970:endtf];
            NSString *endT = [[self dateFormatterMMddHHmm] stringFromDate:endfTime];
            NSLog(@"endT:%@",endT);
           NSLog(@"数组里的元素%@",[downloadArr objectAtIndex:indexPath.row]);
            self.thumbDeadlines.text = [NSString stringWithFormat:@"%@  ----%@",startT,[endT substringFromIndex:5]];
            self.thumbPic.image = [UIImage imageNamed:@"shipinkuang@2x"];
            //            [self.thumbPic.image setImageWithURL:[(NSURL *)url];    //AFNetWorking
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = [downloadArr objectAtIndex:indexPath.row];
    NSNumber *st = [arr objectAtIndex:0];
    int stf = [st intValue];
    NSNumber *et = [arr objectAtIndex:1];
    int endtf = [et intValue];

    ShareCamereViewController *vodVC = [[ShareCamereViewController alloc] init];
    vodVC.islLve = NO;
    NSString *URLstring = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=vod&access_token=%@&deviceid=%@&st=%d&et=%d",self.accessToken,self.deviceID,stf,endtf];
    vodVC.url = URLstring;
//    vodVC.url = @"http://119.188.2.50/data2/video04/2013/04/27/00ab3b24-74de-432b-b703-a46820c9cd6f.mp4";
    vodVC.playerTitle = @"汶川地震(录像)";
    vodVC.deviceId = self.deviceID;
    vodVC.accecc_token = self.accessToken;
    [[SliderViewController sharedSliderController].navigationController pushViewController:vodVC animated:YES];
}

- (NSDateFormatter *)dateFormatterMMddHHmm {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd HH:mm"];
    return dateFormat;
}

//强制不允许转屏
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
