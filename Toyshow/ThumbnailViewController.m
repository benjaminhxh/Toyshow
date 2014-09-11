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
#import "UIImageView+AFNetworking.h"

@interface ThumbnailViewController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_fakeData;
    NSMutableArray *downloadArr;
    MJRefreshFooterView *_footerView;
    MJRefreshHeaderView *_headerView;
    UILabel *noDataLoadL,*noInternetL;
    long st,et;
    UIPickerView *pickView;
    UIView *dateView;
    NSMutableArray *timeStrArr,*timeIntArr,*imageURLARR;
    NSInteger pickRow;
    NSString *downloadImageURL;
    MBProgressHUD *badInternetHub;
    ShareCamereViewController *vodVC;
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
    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.
//    UIImageView *background = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    background.image = [UIImage imageNamed:backGroundImage];
//    [self.view addSubview:background];
//    background.userInteractionEnabled = YES;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 64)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 25, 100, 22);
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn setTitle:@"点播列表" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];

    UIButton *timeSelectBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    timeSelectBtn.frame = CGRectMake(kWidth-75, 22, 65, 35);
    [timeSelectBtn setTitle:@"时间选择" forState:UIControlStateNormal];
    [timeSelectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [timeSelectBtn setBackgroundImage:[UIImage imageNamed:@"lishijilu@2x"] forState:UIControlStateNormal];
    [timeSelectBtn addTarget:self action:@selector(timeSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:timeSelectBtn];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, kWidth, [UIScreen mainScreen].bounds.size.height-65) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];

    NSDate *datenow = [NSDate dateWithTimeIntervalSinceNow:0];//现在时间
    et = (long)[datenow timeIntervalSince1970];
    st = et - 7*24*3600;
    
    dateView = [[UIView alloc] initWithFrame:CGRectMake(0, kHeight, kWidth, 202)];
    dateView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:dateView];
    
    pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 34, kWidth, 160)];
    pickView.delegate = self;
    pickView.dataSource = self;
    pickView.showsSelectionIndicator = YES;
    [dateView addSubview:pickView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(10, 2, 60, 30);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(cancelDatePickSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    [dateView addSubview:cancelBtn];
    
    UIButton *OKBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    OKBtn.frame = CGRectMake(250, 2, 60, 30);
    [OKBtn setBackgroundImage:[UIImage imageNamed:@"anniu@2x"] forState:UIControlStateNormal];
    [OKBtn setTitle:@"确定" forState:UIControlStateNormal];
    
    [OKBtn addTarget:self action:@selector(OKBtnDatePickSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    [dateView addSubview:OKBtn];
    timeStrArr = [NSMutableArray array];
    timeIntArr = [NSMutableArray array];
    [timeStrArr addObject:@"全部"];
    [timeStrArr addObject:@"今天"];
    
    //现在时间、以及对于的int值
    NSString *nowTime = [[self dateFormatterHHmmss] stringFromDate:datenow];
    NSArray *timeArrary = [nowTime componentsSeparatedByString:@":"];
    int startT =[[timeArrary objectAtIndex:0] intValue]*3600+[[timeArrary objectAtIndex:1] intValue]*60+[[timeArrary objectAtIndex:2] intValue];
    
    [timeIntArr addObject:[NSNumber numberWithLong:et]];
    //昨天一天的时间
    long yesterday = et-startT;
    [timeIntArr addObject:[NSNumber numberWithLong:yesterday]];
    
    for (int i = 1; i<7; i++) {
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-i*24*3600];
        NSString *timeTitle = [[self dateFormatterYYYYMMdd] stringFromDate:date];
        [timeStrArr addObject:timeTitle];
        long qiantian = et-startT-24*3600*i;
        [timeIntArr addObject:[NSNumber numberWithLong:qiantian]];
    }
    
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_tableView addGestureRecognizer:recognizer];

    noInternetL = [[UILabel alloc] initWithFrame:CGRectMake(0, 65, kWidth, 44)];
    noInternetL.text = @"当前网络不可用，请检查你的网络设置";
    noInternetL.backgroundColor = [UIColor grayColor];
    noInternetL.font = [UIFont systemFontOfSize:14];
    noInternetL.textAlignment = NSTextAlignmentCenter;
    noInternetL.hidden = YES;
    [self.view addSubview:noInternetL];
    
    noDataLoadL = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, kWidth, 44)];
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
    vodVC = [[[SliderViewController sharedSliderController].dict objectForKey:kplayerDict] objectForKey:kplayerKey];

}

- (NSDateFormatter *)dateFormatterYYYYMMdd {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd"];
    return dateFormat;
}

- (NSDateFormatter *)dateFormatterHHmmss {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    return dateFormat;
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
//        NSDate *datenow = [NSDate dateWithTimeIntervalSinceNow:0];//现在时间
//        long et = (long)[datenow timeIntervalSince1970];
//        long st = et - 7*24*3600;
      
        //请求点播时间
        NSString *urlStr = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=playlist&access_token=%@&deviceid=%@&st=%ld&et=%ld",self.accessToken,self.deviceID,st,et];
        [[AFHTTPRequestOperationManager manager] GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            //            ////NSLog(@"dict:%@",dict);
            //2、初始化数据
            _fakeData = [NSMutableArray array];
            downloadArr = [NSMutableArray array];
            downloadArr = [dict objectForKey:@"results"];
            NSLog(@"downloadArr。count=====%d",downloadArr.count);
            
            if (downloadArr.count == 0) {
                [self MBprogressViewHubLoading:@"无录像"];
                [badInternetHub hide:YES afterDelay:1];
            }else
            {
                if (downloadArr.count>20) {
                    //从尾到头遍历选出最后那20条数据
                    for (int i = downloadArr.count; i > (downloadArr.count-20); i--) {
                        //                        ////NSLog(@"downLoadArr:------i--------%d",i);
                        [vc->_fakeData addObject:[downloadArr objectAtIndex:i-1]];
                    }
                }
                else
                {
                    for (int i = downloadArr.count; i > 0; i--) {
                        [vc->_fakeData addObject:[downloadArr objectAtIndex:i-1]];
                    }
                }
                //请求点播缩略图
                //获取视频流最后一张缩略图:
                NSString *imageURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=thumbnail&access_token=%@&deviceid=%@&latest=%d",self.accessToken,self.deviceID,1];
                //获取一段时间内的缩略图列表:
//                NSString *imageURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=thumbnail&access_token=%@&deviceid=%@&st=%ld&et=%ld",self.accessToken,self.deviceID,st,et];
                NSLog(@"imageURL:%@",imageURL);
//                [[AFHTTPRequestOperationManager manager]POST:imageURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                    NSDictionary *dict = (NSDictionary *)responseObject;
//                    NSLog(@"视频流的图像：%@",dict);
//                    NSArray *imageArr = [NSArray array];
//                    imageArr = [dict objectForKey:@"list"];
//                    NSLog(@"imageArr.count:%d",imageArr.count);
//                    NSDictionary *imageURLDict = [imageArr objectAtIndex:0];
////                    NSLog(@"imageURLDict:%@",imageURLDict);
//                    downloadImageURL = [imageURLDict objectForKey:@"url"];
//                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
////                    NSDictionary *errorDict = [error userInfo];
//                    ////NSLog(@"errorDict:%@",errorDict);
//                }];
            }
            [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:KdurationSuccess];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSDictionary *errorDict = [error userInfo];
            ////NSLog(@"errorDict:%@",errorDict);
            [self MBprogressViewHubLoading:@"网络延时"];
            [badInternetHub hide:YES afterDelay:1];
            [vc performSelector:@selector(doneWithViewWithNoInterNet:) withObject:refreshView afterDelay:KdurationSuccess];
            
        }];

        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是header
        [vc performSelector:@selector(doneWithViewWithNoInterNet:) withObject:refreshView afterDelay:KdurationFail];
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
    __unsafe_unretained ThumbnailViewController *vc = self;
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    footer.scrollView = _tableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        if(_fakeData.count < downloadArr.count)
        {
            if (_fakeData.count+20 > downloadArr.count)
            {
                for (int i = (downloadArr.count-_fakeData.count); i > 0; i--) {
                    [vc->_fakeData addObject:[downloadArr objectAtIndex:i-1]];
                }
            }
            else
            {
               int a = (downloadArr.count-_fakeData.count-20);
                for (int i = (downloadArr.count-_fakeData.count); i > a; i--) {
                    [_fakeData addObject:[downloadArr objectAtIndex:i-1]];
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
//        ////NSLog(@"tableView.count:%d",_fakeData.count);
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
        //            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [[[NSBundle mainBundle] loadNibNamed:@"thumbCell" owner:self options:nil] lastObject];
        self.thumbTitle.text = self.deviceDesc;
        NSArray *arr = [_fakeData objectAtIndex:indexPath.row];
        NSNumber *stt = [arr objectAtIndex:0];
        int stf = [stt intValue];
        NSDate *currentTime = [NSDate dateWithTimeIntervalSince1970:stf];
        NSString *startT = [[self dateFormatterMMddHHmm] stringFromDate:currentTime];
        
        NSNumber *ett = [arr objectAtIndex:1];
        int endtf = [ett intValue];
        NSDate *endfTime = [NSDate dateWithTimeIntervalSince1970:endtf];
        NSString *endT = [[self dateFormatterMMddHHmm] stringFromDate:endfTime];
        self.thumbDeadlines.text = [NSString stringWithFormat:@"%@-—%@",startT,[endT substringFromIndex:5]];
//            NSString *imageURL = [[imageURLARR objectAtIndex:indexPath.row] objectForKey:@"url"];
        NSString *imageURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=thumbnail&access_token=%@&deviceid=%@&st=%d&et=%d",self.accessToken,self.deviceID,stf,endtf];
        [[AFHTTPRequestOperationManager manager] POST:imageURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSLog(@"视频流的图像：%@",dict);
            NSArray *imageArr = [NSArray array];
            imageArr = [dict objectForKey:@"list"];
            if (imageArr.count) {
                //            NSLog(@"imageArr.count:%d",imageArr.count);
                NSDictionary *imageURLDict = [imageArr objectAtIndex:0];
                //            NSLog(@"imageURLDict:%@",imageURLDict);
                NSString *imageURLl = [imageURLDict objectForKey:@"url"];
                [self.thumbPic setImageWithURL:[NSURL URLWithString:imageURLl]];
            }else
            {
                self.thumbPic.image = [UIImage imageNamed:@"shipinkuang.png"];
            }

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = [_fakeData objectAtIndex:indexPath.row];
    NSNumber *stt = [arr objectAtIndex:0];
    int stf = [stt intValue];
    NSDate *startTimeData = [NSDate dateWithTimeIntervalSince1970:stf];
    NSString *startTimeStr = [[self dateFormatterMMddHHmm] stringFromDate:startTimeData];
    NSString *substringTime = [startTimeStr substringFromIndex:5];//截取时间 12：20：20
    NSArray *timeArr = [substringTime componentsSeparatedByString:@":"];
    int startT =[[timeArr objectAtIndex:0] intValue]*3600+[[timeArr objectAtIndex:1] intValue]*60+[[timeArr objectAtIndex:2] intValue];
    
    NSNumber *ett = [arr objectAtIndex:1];
    int endtf = [ett intValue];

    vodVC.isLive = NO;
    NSString *URLstring = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=vod&access_token=%@&deviceid=%@&st=%d&et=%d",self.accessToken,self.deviceID,stf,endtf];
    vodVC.url = URLstring;
//    vodVC.url = @"http://119.188.2.50/data2/video04/2013/04/27/00ab3b24-74de-432b-b703-a46820c9cd6f.mp4";
//    vodVC.playerTitle = @"汶川地震(录像)";
    vodVC.playerTitle = [self.deviceDesc stringByAppendingString:@"(录像)"];
    vodVC.deviceId = self.deviceID;
    vodVC.accecc_token = self.accessToken;
    vodVC.startTimeInt = startT;
    [[SliderViewController sharedSliderController].navigationController pushViewController:vodVC animated:YES];
}

#pragma mark - pickViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return timeStrArr.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [timeStrArr objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    pickRow = row;
}

#pragma mark - TimeSelectMethod
- (void)timeSelectAction:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        dateView.frame = CGRectMake(0, kHeight-202, kWidth, 202);
    }];
}

- (void)cancelDatePickSelectAction:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        dateView.frame = CGRectMake(0, kHeight, kWidth, 202);
    }];
}

- (void)OKBtnDatePickSelectAction:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        dateView.frame = CGRectMake(0, kHeight, kWidth, 202);
    }];
    st = [[timeIntArr objectAtIndex:pickRow] longValue];
    if (pickRow==0) {
//        ////NSLog(@"起始时间：%@------%@",[timeIntArr objectAtIndex:pickRow],[timeIntArr objectAtIndex:7]);
        et = [[timeIntArr objectAtIndex:7] longValue];
    }else
    {
//        ////NSLog(@"起始时间：%@------%@",[timeIntArr objectAtIndex:pickRow],[timeIntArr objectAtIndex:pickRow-1]);
        et = [[timeIntArr objectAtIndex:pickRow-1] longValue];
    }
    [self requestDataWithSelectTime];
}

- (NSDateFormatter *)dateFormatterMMddHHmm {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd HH:mm:ss"];
    return dateFormat;
}

- (void)requestDataWithSelectTime
{
    __unsafe_unretained ThumbnailViewController *vc = self;
    //请求点播时间
    NSString *urlStr = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=playlist&access_token=%@&deviceid=%@&st=%ld&et=%ld",self.accessToken,self.deviceID,st,et];
    [[AFHTTPRequestOperationManager manager] GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        //            ////NSLog(@"dict:%@",dict);
        //2、初始化数据
        _fakeData = [NSMutableArray array];
        downloadArr = [NSMutableArray array];
        downloadArr = [dict objectForKey:@"results"];
        if (downloadArr.count == 0) {
            [self MBprogressViewHubLoading:@"无录像"];
            [badInternetHub hide:YES afterDelay:1];
        }else
        {
            if (downloadArr.count>20) {
                //从尾到头遍历选出最后那20条数据
                for (int i = downloadArr.count; i > (downloadArr.count-20); i--) {
                    [vc->_fakeData addObject:[downloadArr objectAtIndex:i-1]];
                }
            }else
            {
                for (int i = downloadArr.count; i > 0; i--) {
                    [vc->_fakeData addObject:[downloadArr objectAtIndex:i-1]];
                }
            }
            NSString *imageURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=thumbnail&access_token=%@&deviceid=%@&latest=%d",self.accessToken,self.deviceID,1];
            [[AFHTTPRequestOperationManager manager]GET:imageURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dict = (NSDictionary *)responseObject;
                NSArray *imageArr = [NSArray array];
                imageArr = [dict objectForKey:@"list"];
                NSDictionary *imageURLDict = [imageArr objectAtIndex:0];
                downloadImageURL = [imageURLDict objectForKey:@"url"];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSDictionary *errorDict = [error userInfo];
                ////NSLog(@"errorDict:%@",errorDict);
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSDictionary *errorDict = [error userInfo];
        ////NSLog(@"errorDict:%@",errorDict);
        [self MBprogressViewHubLoading:@"网络延时"];
        [badInternetHub hide:YES afterDelay:1];
    }];
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

//强制不允许转屏
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIView animateWithDuration:0.3 animations:^{
        dateView.frame = CGRectMake(0, kHeight, kWidth, 202);
    }];
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
