//
//  HomeViewController.m
//  Toyshow
//
//  Created by zhxf on 14-2-27.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#define IOS7    [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0
#define IPHONE5  [[UIScreen mainScreen] bounds].size.height >480

#import "HomeViewController.h"
#import "MyphotoViewController.h"
#import "ShowImageViewController.h"
#import "VideoViewController.h"
#import "MVViewController.h"
#import <Frontia/Frontia.h>
#import "SiderCell.h"
#import <QuartzCore/QuartzCore.h>

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIView *_homeView;
    UIImageView *_userImageView;
    NSArray *_listArr,*_listHome;
    UILabel *_titleTextL;
    UITableView *tableView1,*tableView2;
    NSString *accessToken;
}
@end

@implementation HomeViewController

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
    accessToken = nil;
    _listArr = [NSArray array];
    _listArr = [NSArray arrayWithObjects:@"我的摄像头",@"点播",@"公共摄像头",@"收藏",@"添加设备",@"登录",@"退出登录",@"帮助",@"关于", nil];
    _listHome = [NSArray array];
    _listHome = [NSArray arrayWithObjects:@"海定区的摄像头",@"西三旗的摄像头",@"截屏", nil];
    self.navigationController.navigationBarHidden = YES;
    //侧边栏的标题
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 100, 20)];
    titleL.text = @"小度i耳目";
//    titleL.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleL];
    
    //创建侧边栏的tableView1
     tableView1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, 160, [UIScreen mainScreen].bounds.size.height-80) style:UITableViewStylePlain];
    tableView1.delegate = self;
    tableView1.dataSource = self;
    [self.view addSubview:tableView1];
    //用户头像
    _userImageView = [[UIImageView alloc] initWithFrame:CGRectMake(65, 35, 50, 50)];
    _userImageView.backgroundColor = [UIColor redColor];
//    _userImageView.image = [UIImage imageNamed:@"camera"];
    _userImageView.layer.cornerRadius = _userImageView.bounds.size.width/2;
    [self.view addSubview:_userImageView];
    
    //主页
    int y ;
    if (IOS7) {
        y = 20;
    }else{
        y = 0;
    }
    _homeView = [[UIView alloc] initWithFrame:CGRectMake(0, y, 320,[UIScreen mainScreen].bounds.size.height )];
    _homeView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_homeView];
    //主页标题
    _titleTextL = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 40)];
    _titleTextL.text = @"我的摄像头";
    _titleTextL.backgroundColor = [UIColor clearColor];
    _titleTextL.textAlignment = NSTextAlignmentCenter;
    [_homeView addSubview:_titleTextL];
    
    tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 320, [UIScreen mainScreen].bounds.size.height-50) style:UITableViewStylePlain];
    tableView2.delegate = self;
    tableView2.dataSource = self;
    [_homeView addSubview:tableView2];
    
//    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    leftBtn.frame = CGRectMake(5, 20, 40, 20);
//    leftBtn.backgroundColor = [UIColor blackColor];
//    [leftBtn addTarget:self action:@selector(siderVIewClick:) forControlEvents:UIControlEventTouchUpInside];
//    [leftBtn setTitle:@"设置" forState:UIControlStateNormal];
//    [leftBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    [_homeView addSubview:leftBtn];
    
    //右滑弹出侧边栏
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFromright:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_homeView addGestureRecognizer:recognizer];
    
    //左滑隐藏侧边栏
    UISwipeGestureRecognizer *recognizer1;
    recognizer1 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFromleft:)];
    [recognizer1 setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [_homeView addGestureRecognizer:recognizer1];

	// Do any additional setup after loading the view.
}

//弹出侧边栏
- (void)handleSwipeFromright:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        _homeView.frame = CGRectMake(160, 0, 320, 480);
    }];
}

//隐藏侧边栏
- (void)handleSwipeFromleft:(id)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        _homeView.frame = CGRectMake(0, 0, 320, 480);
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView1 == tableView) {
    static NSString *cellIde = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SiderCell" owner:self options:nil] firstObject];
            self.titleText.text = [_listArr objectAtIndex:indexPath.row];
        }
        return cell;
    }else
    if (tableView2 == tableView)
    {
        static NSString *cellIde = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"SiderCell" owner:self options:nil] lastObject];
            self.cameraTitle.text = [_listHome objectAtIndex:indexPath.row];
        }
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView1 == tableView) {
    _homeView.frame = CGRectMake(0, 0, 320, 480);
    switch (indexPath.row) {
        case 4:
        {
            //跳转到登录界面
            [self signonButtonClicked];
        }
            break;
        case 7://启动图片展示
        {
            ShowImageViewController *showImageVC = [[ShowImageViewController alloc] init];
            [self.navigationController pushViewController:showImageVC animated:YES];
        }
            break;
        case 1://视频播放测试
        {
//            VideoViewController *videoVC = [[VideoViewController alloc] init];
//            [self.navigationController pushViewController:videoVC animated:YES];
//            NSString *path = [[NSBundle mainBundle] pathForResource:@"wwmxd" ofType:@"mp4"];
//            NSURL *url = [NSURL fileURLWithPath:path];
            NSURL *url = [NSURL URLWithString:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=vod&access_token= b778fb598c717c0ad7ea8c97c8f3a46f&deviceid=12345&st=1234454&et=1234512"];
            MPMoviePlayerViewController *playC = [[MVViewController alloc] initWithContentURL:url];
            playC.view.frame = CGRectMake(0, 20, 320, 460);
            [self presentMoviePlayerViewControllerAnimated:playC];
        }
            break;
        default:
        {
            MyphotoViewController *myphVC = [[MyphotoViewController alloc] init];
            [self.navigationController pushViewController:myphVC animated:YES];
        }
            break;
    }
    }else if (tableView2 == tableView)
    {
        switch (indexPath.row) {
            case 2://截屏
            {
                UIGraphicsBeginImageContext(self.view.bounds.size);
                [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
                UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            }
                break;
            default:
                break;
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)myCamera:(id)sender
{
    MyphotoViewController *myphVC = [[MyphotoViewController alloc] init];
    [self.navigationController pushViewController:myphVC animated:YES];
}

//个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView1 == tableView) {
        if (_listArr.count) {
            return [_listArr count];
        }
    }else if(tableView2 == tableView)
    {
        if (_listHome.count) {
            return _listHome.count;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return [[UIScreen mainScreen]bounds].size.height/8;
    return 70;
}

//登录按钮
- (void)signonButtonClicked {
    FrontiaAuthorization* authorization = [Frontia getAuthorization];
    
    if(authorization) {
        
        //授权取消回调函数
        FrontiaAuthorizationCancelCallback onCancel = ^(){
            NSLog(@"OnCancel: authorization is cancelled");
        };
        
        //授权失败回调函数
        FrontiaAuthorizationFailureCallback onFailure = ^(int errorCode, NSString *errorMessage){
            NSLog(@"OnFailure: %d  %@", errorCode, errorMessage);
        };
        
        //授权成功回调函数
        FrontiaAuthorizationResultCallback onResult = ^(FrontiaUser *result){
            NSLog(@"OnResult account name: %@ account id: %@", result.accountName, result.experidDate);
            accessToken = result.accessToken;
            
            //设置授权成功的账户为当前使用者账户
            [Frontia setCurrentAccount:result];
        };
        
    
        //设置授权权限
        NSMutableArray *scope = [[NSMutableArray alloc] init];
        [scope addObject:FRONTIA_PERMISSION_USER_INFO];
        [scope addObject:FRONTIA_PERMISSION_PCS];
        
        [authorization authorizeWithPlatform:FRONTIA_SOCIAL_PLATFORM_BAIDU scope:scope supportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait isStatusBarHidden:NO cancelListener:onCancel failureListener:onFailure resultListener:onResult];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)moreClick:(id)sender {
    if (tableView2.indexPathForSelectedRow.row == 0) {
        NSLog(@"--------000000");
//        NSArray *ifs = ()CNCopySupportedInterfaces();
//        NSLog(@"Supported interfaces: %@", ifs);
//        id info = nil;
//        for (NSString *ifnam in ifs) {
//            info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
//            NSLog(@"%@ => %@", ifnam, info);
//            if (info && [info count]) { break; }
//        }
    }else if (tableView2.indexPathForSelectedRow.row == 1)
    {
        NSLog(@"1111111111");
    }
}

@end
