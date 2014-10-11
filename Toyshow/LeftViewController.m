//
//  LeftViewController.m
//  LeftRightSlider
//
//  Created by Zhao Yiqi on 13-11-27.
//  Copyright (c) 2013年 Zhao Yiqi. All rights reserved.
//

#import "LeftViewController.h"
#import "ZBarSDK.h"
#import <Frontia/Frontia.h>
#import <Frontia/FrontiaShare.h>
#import <Frontia/FrontiaShareContent.h>
#import <Frontia/FrontiaShareDelegate.h>
#import "SiderCell.h"
#import "MyCameraViewController.h"
#import "AddDeviceViewController.h"
#import "MainViewController.h"
#import "CollectionViewController.h"
#import "CameraSetViewController.h"
#import "HelpViewController.h"
#import "AboutViewController.h"
#import "WXApi.h"
#import "WeixinSessionActivity.h"
#import "WeixinTimelineActivity.h"
#import "UIImageView+AFNetworking.h"
#import "ShareCamereViewController.h"

@interface LeftViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,WXApiDelegate,ZBarReaderDelegate>
{
    NSArray *_listArr,*_imageArr;
    UILabel *_titleTextL,*loginOrOutL;
    UITableView *tableView1,*tableView2;
    int num,scanNum;
    BOOL upOrdown,_flag;
    NSTimer *timer;
    BOOL _reloading;
    NSArray *activity;
    UIAlertView *_loginView,*scanFailView;
    ShareCamereViewController *_playVC;
    NSDictionary *_playDict;
    ZBarReaderViewController *reader;
}
@end

@implementation LeftViewController

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
    UIImageView *imgV=[[UIImageView alloc] initWithFrame:self.view.bounds];
    [imgV setImage:[UIImage imageNamed:backGroundImage]];
    [self.view addSubview:imgV];
    _listArr = [NSArray arrayWithObjects:@"我的摄像头",@"我的收藏",@"分享的摄像头",@"添加新设备",@"",@"帮助",@"关于", nil];
    UIImage *image1 = [UIImage imageNamed:@"shejingtou@2x"];
    UIImage *image2 = [UIImage imageNamed:@"collection@2x"];
    UIImage *image3 = [UIImage imageNamed:@"fenxiang@2x"];
    UIImage *image4 = [UIImage imageNamed:@"tianjia@2x"];
    UIImage *image5 = [UIImage imageNamed:@"tuichudenglu@2x"];
    UIImage *image6 = [UIImage imageNamed:@"bangzhu@2x"];
    UIImage *image7 = [UIImage imageNamed:@"guanyu@2x"];
    _imageArr = [NSArray arrayWithObjects:image1,image2,image3,image4,image5,image6,image7, nil];

    self.navigationController.navigationBarHidden = YES;
//    self.cameraThumb.layer.cornerRadius = self.cameraThumb.bounds.size.height/2;
    
    //用户头像
    self.userImageVIew = [[UIImageView alloc] initWithFrame:CGRectMake(75, 30, 70, 70)];
    self.userImageVIew.layer.cornerRadius = self.userImageVIew.bounds.size.width/2;
    [self.view addSubview:self.userImageVIew];
    
    UIImageView *cirleView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 25, 80, 80)];
    cirleView.image = [UIImage imageNamed:@"touxiang_quan@2x"];
    [self.view addSubview:cirleView];

    //用户名
    self.userNameL = [[UILabel alloc] initWithFrame:CGRectMake(20, 105, 180, 20)];
    self.userNameL.textColor = [UIColor whiteColor];
    self.userNameL.backgroundColor = [UIColor clearColor];
    self.userNameL.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.userNameL];
    UITableView *tableV=[[UITableView alloc] initWithFrame:CGRectMake(0, 130, leftWidth, self.view.frame.size.height-130)];
    tableV.backgroundColor=[UIColor clearColor];
    tableV.delegate=self;
    tableV.dataSource=self;
    [self.view addSubview:tableV];
    if (![self checkAccessTokenIsExist]) {
        self.userNameL.text = @"请登录";
        self.userImageVIew.image = [UIImage imageNamed:@"touxiang_n@2x"];
    }else
    {
        self.userNameL.text = [[NSUserDefaults standardUserDefaults] stringForKey:kUserName];
        self.userImageVIew.clipsToBounds = YES;
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:kUserHeadImage];
        self.userImageVIew.image = [UIImage imageWithData:imageData];
        self.userImageVIew.image = [self scaleToSize:self.userImageVIew.image size:self.userImageVIew.frame.size];
        self.accessToken = [[NSUserDefaults standardUserDefaults]stringForKey:kUserAccessToken];
    }
    //创建播放器对象
    _playVC = [[ShareCamereViewController alloc] init];
    _playDict = [NSDictionary dictionaryWithObjectsAndKeys:_playVC,kplayerKey, nil];
    [SliderViewController sharedSliderController].dict = _playDict;
    [[NSNotificationCenter defaultCenter] postNotificationName:kplayerObj object:nil userInfo:_playDict];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableViewDelegate
//个数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_listArr.count) {
        return [_listArr count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIde = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell == nil) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SiderCell" owner:self options:nil] firstObject];
        self.titleText.text = [_listArr objectAtIndex:indexPath.row];
        self.imageIcon.image = [_imageArr objectAtIndex:indexPath.row];
        if (4 == indexPath.row) {
            loginOrOutL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 123, 50)];
            loginOrOutL.textColor = [UIColor whiteColor];
            loginOrOutL.backgroundColor = [UIColor clearColor];

            [self.titleText addSubview:loginOrOutL];
            if ([self checkAccessTokenIsExist]) {
                loginOrOutL.text = @"退出";
            }else
            {
                loginOrOutL.text = @"登陆";
            }
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0://我的摄像头
        {
            if ([self accessTokenIsExist]) {
                
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] stringForKey:kUserName],@"userID",self.accessToken,@"accessToken",_playDict,kplayerDict,nil];
                ////NSLog(@"my camera dict:%@",dict);
//                [[NSNotificationCenter defaultCenter] postNotificationName:kUserInfoNotification object:nil userInfo:dict];
                [[SliderViewController sharedSliderController] showContentControllerWithModel:@"MyCameraViewController" withDictionary:dict];
            }
        }
            break;
        case 1://我的收藏
            if ([self accessTokenIsExist]) {
                [[SliderViewController sharedSliderController] showContentControllerWithModel:@"CollectionViewController" withDictionary:_playDict];
            }
            break;
        case 2://分享的设备
            [[SliderViewController sharedSliderController] showContentControllerWithModel:@"MainViewController" withDictionary:_playDict];
            break;
        case 3://添加设备、扫描二维码
            if ([self accessTokenIsExist]) {
                [self scanBtnAction];
                ////NSLog(@"扫描二维码");
//                AddDeviceViewController *addDeviceVC = [[AddDeviceViewController alloc] init];
////                addDeviceVC.deviceID = result;
//                addDeviceVC.access_token = self.accessToken;
//                addDeviceVC.userID = [[NSUserDefaults standardUserDefaults] stringForKey:kUserName];
//                [self.navigationController pushViewController:addDeviceVC animated:YES];

            }
            break;
        case 4://登录or退出
        {
            if ([self accessTokenIsExist]) {
                //5
                UIAlertView *logoutView = [[UIAlertView alloc] initWithTitle:@"退出提醒" message:@"确定要注销登录？" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                [logoutView show];
                //------------------------退出登录
            }else
            {
                //------------------------登录
            }
        }
            break;
        case 5://帮助
            [[SliderViewController sharedSliderController] showContentControllerWithModel:@"HelpViewController" withDictionary:nil];
            break;
        case 6://关于
            [[SliderViewController sharedSliderController] showContentControllerWithModel:@"AboutViewController" withDictionary:nil];
            break;
        default:
            break;
    }
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)checkAccessTokenIsExist
{
    NSString *userAccessToken = [[NSUserDefaults standardUserDefaults]stringForKey:kUserAccessToken];
    if (userAccessToken == nil) {
        return NO;
    }
    return YES;
}

- (BOOL)accessTokenIsExist
{
    NSString *userAccessToken = [[NSUserDefaults standardUserDefaults]stringForKey:kUserAccessToken];
    if (userAccessToken == nil) {
        _loginView = [[UIAlertView alloc] initWithTitle:@"请登陆" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        [_loginView show];
        return NO;
    }else
    return YES;
}

#pragma mark - ZBar 二维码扫描
//扫描二维码
-(void)scanBtnAction
{
    num = 0;
    upOrdown = NO;
    //初始话ZBar
    if (reader) {
        
    }else
    {
        reader = [ZBarReaderViewController new];
    }
    //设置代理
    reader.readerDelegate = self;
    //支持界面旋转
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    reader.showsHelpOnFail = NO;
    reader.scanCrop = CGRectMake(0.0, 0.2, 1.0, 0.6);//扫描的感应框
    ZBarImageScanner * scanner = reader.scanner;
    [scanner setSymbology:ZBAR_CODE128  //ZBAR_I25
                   config:ZBAR_CFG_ENABLE
                       to:1];           //0
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 420)];
    view.backgroundColor = [UIColor clearColor];
    reader.cameraOverlayView = view;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 40)];
    label.text = @"请将设备的MAC地址二维码置于扫描框正中间内谢谢！";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = 1;
    label.lineBreakMode = 0;
    label.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    UIImageView * image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pick_bg.png"]];
    image.frame = CGRectMake(20, 80, kWidth-40, 280);
    [view addSubview:image];
    
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(30, 10, 220, 1)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [image addSubview:_line];
    //定时器，设定时间过1.5秒，
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    [self presentViewController:reader animated:YES completion:nil];
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(30, 10+2*num, 220, 1);
        if (2*num == 260) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(30, 10+2*num, 220, 1);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}

//取消设备扫描
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [timer invalidate];
    _line.frame = CGRectMake(30, 10, 220, 2);
    num = 0;
    upOrdown = NO;
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
    }];
}
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
//{
//    NSLog(@"editingInfo%@",editingInfo);
//}

//扫描完成
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    NSLog(@"info:%@",info);
    [timer invalidate];
    _line.frame = CGRectMake(30, 10, 220, 1);
    num = 0;
    upOrdown = NO;
    [picker dismissViewControllerAnimated:NO completion:^{
        [picker removeFromParentViewController];
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        //初始化
        ZBarReaderController *read = [ZBarReaderController new];
        //设置代理
        read.readerDelegate = self;
        CGImageRef cgImageRef = image.CGImage;
        ZBarSymbol * symbol = nil;
        id <NSFastEnumeration> results = [read scanImage:cgImageRef];
//        NSLog(@"results:%@",results);
        for (symbol in results)
        {
            break;
        }
        NSString * result;
//        NSLog(@"symbol.data:%@--results:%@",symbol.data,results);
        if ([symbol.data canBeConvertedToEncoding:NSShiftJISStringEncoding])
        {
            result = [NSString stringWithCString:[symbol.data cStringUsingEncoding: NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
//-----------------------------------------------------------------------------//
            //扫描成功获得设备二维码--->跳转到WiFi设置页面
            AddDeviceViewController *addDeviceVC = [[AddDeviceViewController alloc] init];
            addDeviceVC.deviceID = result;
            addDeviceVC.access_token = self.accessToken;
            addDeviceVC.isScanFlag = YES;
//            addDeviceVC.imageData = image;
//            addDeviceVC.userID = [[NSUserDefaults standardUserDefaults] stringForKey:kUserName];
            scanNum = 0;
            [self.navigationController pushViewController:addDeviceVC animated:YES];
        }else
        {
            scanNum++;
            if (scanNum>2) {
                scanFailView = [[UIAlertView alloc] initWithTitle:@"扫描失败" message:@"已连续扫描3次失败，是否换到手动输入？" delegate:self cancelButtonTitle:@"再扫一次" otherButtonTitles:@"手动输入", nil];
                [scanFailView show];
                scanNum = 0;
            }else
            [self scanBtnAction];
//            self.userImageVIew.image = image;
//            result = symbol.data;
            
        }
    }];
}

#pragma mark - baidu登陆
//登录按钮
- (void)signonButtonClicked {
    FrontiaAuthorization* authorization = [Frontia getAuthorization];
    if(authorization) {
        //授权取消回调函数
        FrontiaAuthorizationCancelCallback onCancel = ^(){
            ////NSLog(@"OnCancel: authorization is cancelled");//不继续登陆
        };
        
        //授权失败回调函数
        FrontiaAuthorizationFailureCallback onFailure = ^(int errorCode, NSString *errorMessage){
            ////NSLog(@"OnFailure: %d  %@", errorCode, errorMessage);
        };
        
        //授权成功回调函数 登录之后 2（授权中……） 输入密码之后
        FrontiaAuthorizationResultCallback onResult = ^(FrontiaUser *result){
            ////NSLog(@"OnResult account name: %@ account experidDate: %@  account.accessToken:%@", result.accountName, result.experidDate,result.accessToken);
//            NSLog(@"平台信息：%@",result.platform);
            [[NSUserDefaults standardUserDefaults] setObject:result.accountName forKey:kUserName];
            [[NSUserDefaults standardUserDefaults] setObject:result.accessToken forKey:kUserAccessToken];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.accessToken = result.accessToken;
//            NSLog(@"授权成功的accessToken：%@",result.accessToken);//有
            //设置授权成功的账户为当前使用者账户
            self.userNameL.text = result.accountName;
            [Frontia setCurrentAccount:result];
            [self onUserInfo];
        };
        //---------------------------------------------------------
        
        //设置授权权限 1----->进入登陆页面
        NSMutableArray *scope = [[NSMutableArray alloc] init];
        [scope addObject:FRONTIA_PERMISSION_USER_INFO];
        [scope addObject:FRONTIA_PERMISSION_PCS];
//        ////NSLog(@"-------fengexian---------scope:%@",scope);
        [authorization authorizeWithPlatform:FRONTIA_SOCIAL_PLATFORM_BAIDU scope:scope supportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait isStatusBarHidden:NO cancelListener:onCancel failureListener:onFailure resultListener:onResult];
    }
}

- (void)onUserInfo{
    //获取用户详细信息成功回调 3
    FrontiaAuthorization* authorization = [Frontia getAuthorization];
    if(authorization) {
        //获取用户信息失败回调
        FrontiaUserInfoFailureCallback onFailure = ^(int errorCode, NSString *errorMessage){
            ////NSLog(@"get user detail info failed with ID: %d and message:%@", errorCode, errorMessage);
        };
        //获取用户信息成功回调
        FrontiaUserInfoResultCallback onUserResult = ^(FrontiaUserDetail *result) {
            //  5
            ////NSLog(@"get user detail info success with userName: %@ ----headURL：%@", result.accountName,result.headUrl);

            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:result.headUrl]];
//            NSLog(@"result.url:%@",result.headUrl);
            UIImage *userImage = [UIImage imageWithData:data];
            self.userImageVIew.clipsToBounds = YES;
            self.userImageVIew.image = [self scaleToSize:userImage size:self.userImageVIew.frame.size];
            self.userImageVIew.layer.cornerRadius = self.userImageVIew.bounds.size.width/2;
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserHeadImage];
            [[NSUserDefaults standardUserDefaults] synchronize];
            loginOrOutL.text = @"退出";
//            self.userNameL.text = result.accountName;
//            self.titleText.text = @"退出登录";
            //            accessToken = result.accessToken;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view setNeedsDisplay]; //7
            });
        };
        //传递授权返回的令牌信息 4
        [authorization getUserInfoWithPlatform:FRONTIA_SOCIAL_PLATFORM_BAIDU failureListener:onFailure resultListener:onUserResult];
    }
    
    FrontiaAccount *accountt = [Frontia currentAccount];
    [[NSUserDefaults standardUserDefaults] setObject:accountt.mediaUid forKey:kUserId];
    [[NSUserDefaults standardUserDefaults] synchronize];

//    NSLog(@"medID:%@---accontID:%@--accountName:%@",accountt.mediaUid,accountt.accountId,accountt.accountName);
}

//退出登录
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_loginView == alertView) {
        if (buttonIndex) {
            [self signonButtonClicked];
        }else
        {
        }
    }else if (scanFailView == alertView)
    {
        if (buttonIndex) {
            AddDeviceViewController *addDeviceVC = [[AddDeviceViewController alloc] init];
            addDeviceVC.access_token = self.accessToken;
            addDeviceVC.isScanFlag = NO;
            [self.navigationController pushViewController:addDeviceVC animated:YES];
        }else
        {
            [self scanBtnAction];
        }
    }
    else
    {
        if (buttonIndex) {
            [self logout];
        }else
        {
        }
    }
}

- (void)logout
{
    FrontiaAuthorization *auth = [Frontia getAuthorization];
    if ([auth clearAllAuthorizationInfo]) {
        self.userImageVIew.image = [UIImage imageNamed:@"touxiang_n@2x"];
        self.userNameL.text = @"请登录";
        loginOrOutL.text = @"登陆";
        //清楚cookie
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies])
        {
            [storage deleteCookie:cookie];
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserAccessToken];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserHeadImage];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserName];
        [[SliderViewController sharedSliderController] showContentControllerWithModel:@"MainViewController" withDictionary:nil];
    }
}

//裁剪头像
-(UIImage*)scaleToSize:(UIImage*)img size:(CGSize)size
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

@end