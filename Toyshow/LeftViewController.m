//
//  LeftViewController.m
//  LeftRightSlider
//
//  Created by Zhao Yiqi on 13-11-27.
//  Copyright (c) 2013年 Zhao Yiqi. All rights reserved.
//

#import "LeftViewController.h"
#import "SliderViewController.h"
#import "ZBarSDK.h"
#import <Frontia/Frontia.h>
#import <Frontia/FrontiaShare.h>
#import <Frontia/FrontiaShareContent.h>
#import <Frontia/FrontiaShareDelegate.h>
#import "SiderCell.h"
#import "MyCameraViewController.h"
#import "AddDeviceViewController.h"
#import "MainViewController.h"
#import "CameraSetViewController.h"
#import "HelpViewController.h"
#import "AboutViewController.h"
#import "MyphotoViewController.h"

@interface LeftViewController ()<UITableViewDataSource,UITableViewDelegate,ZBarReaderDelegate,UIAlertViewDelegate>
{
    NSArray *_listArr,*_imageArr;
    UILabel *_titleTextL;
    UITableView *tableView1,*tableView2;
    NSString *accessToken,*userID;
    int num;
    BOOL upOrdown,_flag;
    NSTimer * timer;
    BOOL _reloading;
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
//    [self shouldAutorotate];
    UIImageView *imgV=[[UIImageView alloc] initWithFrame:self.view.bounds];
    [imgV setImage:[UIImage imageNamed:backGroundImage]];
    [self.view addSubview:imgV];
    _listArr = [NSArray array];
    _listArr = [NSArray arrayWithObjects:@"我的摄像头",@"添加新设备",@"分享的摄像头",@"退出登录等",@"帮助",@"关于", nil];
    UIImage *image1 = [UIImage imageNamed:@"shejingtou@2x"];
    UIImage *image2 = [UIImage imageNamed:@"tianjia@2x"];
    UIImage *image3 = [UIImage imageNamed:@"fenxiang@2x"];
//    UIImage *image4 = [UIImage imageNamed:@"shejingtou_shezhi@2x"];
    UIImage *image5 = [UIImage imageNamed:@"tuichudenglu@2x"];
    UIImage *image6 = [UIImage imageNamed:@"bangzhu@2x"];
    UIImage *image7 = [UIImage imageNamed:@"guanyu@2x"];
//    UIImage *image8 = [UIImage imageNamed:@"fenxiang@2x"];
    _imageArr = [NSArray arrayWithObjects:image1,image2,image3,image5,image6,image7, nil];

    self.navigationController.navigationBarHidden = YES;
//    self.cameraThumb.layer.cornerRadius = self.cameraThumb.bounds.size.height/2;
    
    //用户头像
    self.userImageVIew = [[UIImageView alloc] initWithFrame:CGRectMake(75, 30, 70, 70)];
    self.userImageVIew.layer.cornerRadius = self.userImageVIew.bounds.size.width/2;
    self.userImageVIew.image = [UIImage imageNamed:@"touxiang_n@2x"];
    [self.view addSubview:self.userImageVIew];
    
    UIImageView *cirleView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 25, 80, 80)];
    cirleView.image = [UIImage imageNamed:@"touxiang_quan@2x"];
    [self.view addSubview:cirleView];

    userID = nil;
    //用户名
    self.userNameL = [[UILabel alloc] initWithFrame:CGRectMake(20, 105, 180, 20)];
    self.userNameL.text = @"请登录";
    self.userNameL.textColor = [UIColor whiteColor];
    self.userNameL.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.userNameL];
    UITableView *tableV=[[UITableView alloc] initWithFrame:CGRectMake(0, 130, leftWidth, self.view.frame.size.height-130)];
    tableV.backgroundColor=[UIColor clearColor];
    tableV.delegate=self;
    tableV.dataSource=self;
    [self.view addSubview:tableV];
    
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
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0://我的摄像头
        {
            if ([self accessTokenIsExist]) {
                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:userID,@"userID",accessToken,@"accessToken",nil];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kUserInfoNotification object:nil userInfo:dict];
                [[SliderViewController sharedSliderController] showContentControllerWithModel:@"MyCameraViewController" withDictionary:dict];
            }
        }
            break;
        case 1://添加设备、扫描二维码
            if ([self accessTokenIsExist]) {
                [self scanBtnAction];
            }
            break;
        case 2://分享的设备
            [[SliderViewController sharedSliderController] showContentControllerWithModel:@"MainViewController" withDictionary:nil];
            break;
//        case 3://摄像头设置
//            [[SliderViewController sharedSliderController] showContentControllerWithModel:@"CameraSetViewController"];
//            break;
        case 3://登录or退出
        {
            if (!accessToken) {
                //------------------------登录
                [self signonButtonClicked];
                //5
            }else
            {
                UIAlertView *logoutView = [[UIAlertView alloc] initWithTitle:@"退出提醒" message:@"确定要注销登录？" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                [logoutView show];
                //------------------------退出登录
            }
        }
            break;
        case 4://帮助
            [[SliderViewController sharedSliderController] showContentControllerWithModel:@"HelpViewController" withDictionary:nil];
            break;
        case 5://关于
            [[SliderViewController sharedSliderController] showContentControllerWithModel:@"AboutViewController" withDictionary:nil];
            break;
        case 6://分享到……
            [self shareToQQ];
            break;
        default:
            break;
    }
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)accessTokenIsExist
{
    if (!accessToken) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"请登陆" message:@"请先登陆" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
        return NO;
    }
    return YES;
}

#pragma mark - ZBar 二维码扫描
//扫描二维码
-(void)scanBtnAction
{
    num = 0;
    upOrdown = NO;
    //初始话ZBar
    ZBarReaderViewController * reader = [ZBarReaderViewController new];
    //设置代理
    reader.readerDelegate = self;
    //支持界面旋转
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    reader.showsHelpOnFail = NO;
    reader.scanCrop = CGRectMake(0.1, 0.2, 0.8, 0.8);//扫描的感应框
    ZBarImageScanner * scanner = reader.scanner;
    [scanner setSymbology:ZBAR_I25
                   config:ZBAR_CFG_ENABLE
                       to:0];
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 420)];
    view.backgroundColor = [UIColor clearColor];
    reader.cameraOverlayView = view;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 40)];
    label.text = @"请将设备的二维码至于下面的扫描框内\n谢谢！";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = 1;
    label.lineBreakMode = 0;
    label.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    [view addSubview:label];
    
    UIImageView * image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pick_bg.png"]];
    image.frame = CGRectMake(20, 80, 280, 280);
    [view addSubview:image];
    
    
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(30, 10, 220, 2)];
    _line.image = [UIImage imageNamed:@"line.png"];
    [image addSubview:_line];
    //定时器，设定时间过1.5秒，
    timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    [self presentViewController:reader animated:YES completion:^{
        
    }];
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(30, 10+2*num, 220, 2);
        if (2*num == 260) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(30, 10+2*num, 220, 2);
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
//扫描完成
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [timer invalidate];
    _line.frame = CGRectMake(30, 10, 220, 2);
    num = 0;
    upOrdown = NO;
    [picker dismissViewControllerAnimated:YES completion:^{
        [picker removeFromParentViewController];
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
        //初始化
        ZBarReaderController * read = [ZBarReaderController new];
        //设置代理
        read.readerDelegate = self;
        CGImageRef cgImageRef = image.CGImage;
        ZBarSymbol * symbol = nil;
        id <NSFastEnumeration> results = [read scanImage:cgImageRef];
        for (symbol in results)
        {
            break;
        }
        NSString * result;
        if ([symbol.data canBeConvertedToEncoding:NSShiftJISStringEncoding])
            
        {
            result = [NSString stringWithCString:[symbol.data cStringUsingEncoding: NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
//-----------------------------------------------------------------------------//
            //扫描成功获得设备二维码--->跳转到WiFi设置页面
            AddDeviceViewController *addDeviceVC = [[AddDeviceViewController alloc] init];
            addDeviceVC.deviceID = result;
            addDeviceVC.access_token = accessToken;
            addDeviceVC.userID = userID;
            [self.navigationController pushViewController:addDeviceVC animated:YES];
        }
        else
        {
            result = symbol.data;
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"扫描失败" message:@"请重新扫描" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [view show];
        }
//        NSLog(@"%@",result);
    }];
}
#pragma mark - baidu登陆
//登录按钮
- (void)signonButtonClicked {
    FrontiaAuthorization* authorization = [Frontia getAuthorization];
    
    if(authorization) {
        
        //授权取消回调函数
        FrontiaAuthorizationCancelCallback onCancel = ^(){
            NSLog(@"OnCancel: authorization is cancelled");//不继续登陆
        };
        
        //授权失败回调函数
        FrontiaAuthorizationFailureCallback onFailure = ^(int errorCode, NSString *errorMessage){
            NSLog(@"OnFailure: %d  %@", errorCode, errorMessage);
        };
        
        //授权成功回调函数 登录之后 2（授权中……） 输入密码之后
        FrontiaAuthorizationResultCallback onResult = ^(FrontiaUser *result){
            NSLog(@"OnResult account name: %@ account id: %@", result.accountName, result.experidDate);
            accessToken = result.accessToken;
//            self.titleText.text = @"退出登录";
            NSLog(@"授权成功的accessToken：%@",result.accessToken);//有
            //设置授权成功的账户为当前使用者账户
            self.userNameL.text = result.accountName;
            userID = result.accountName;
            [Frontia setCurrentAccount:result];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.view setNeedsDisplay]; //
//            });
            [self onUserInfo];
        };
        //---------------------------------------------------------
        
        //设置授权权限 1----->进入登陆页面
        NSMutableArray *scope = [[NSMutableArray alloc] init];
        [scope addObject:FRONTIA_PERMISSION_USER_INFO];
        [scope addObject:FRONTIA_PERMISSION_PCS];
        
        [authorization authorizeWithPlatform:FRONTIA_SOCIAL_PLATFORM_BAIDU scope:scope supportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait isStatusBarHidden:NO cancelListener:onCancel failureListener:onFailure resultListener:onResult];
    }
}

- (void)onUserInfo{
    //获取用户详细信息成功回调 3
    FrontiaAuthorization* authorization = [Frontia getAuthorization];
    if(authorization) {
        //获取用户信息失败回调
        FrontiaUserInfoFailureCallback onFailure = ^(int errorCode, NSString *errorMessage){
            NSLog(@"get user detail info failed with ID: %d and message:%@", errorCode, errorMessage);
        };
        //获取用户信息成功回调
        FrontiaUserInfoResultCallback onUserResult = ^(FrontiaUserDetail *result) {
            //  5
            NSLog(@"get user detail info success with userName: %@ ----headURL：%@", result.accountName,result.headUrl);
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:result.headUrl]];
            UIImage *userImage = [UIImage imageWithData:data];
            self.userImageVIew.image = [self circleImage:userImage withParam:2];
            self.userImageVIew.layer.cornerRadius = self.userImageVIew.bounds.size.width/2;
//            self.userNameL.text = result.accountName;
//            userID = result.accountName;
//            self.titleText.text = @"退出登录";
            //            accessToken = result.accessToken;
            NSLog(@"用户信息的accessToken:%@",result.accessToken);//null
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view setNeedsDisplay]; //7
            });
        };
        //传递授权返回的令牌信息 4
        [authorization getUserInfoWithPlatform:FRONTIA_SOCIAL_PLATFORM_BAIDU failureListener:onFailure resultListener:onUserResult];
    }
}

//退出登录
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        FrontiaAuthorization *auth = [Frontia getAuthorization];
        if ([auth clearAllAuthorizationInfo]) {
            
            NSLog(@"clear清除成功");
            self.userImageVIew.image = [UIImage imageNamed:@"touxiang_n@2x"];
            self.userNameL.text = @"请登录";
//            self.titleText.text = @"登录";
            accessToken = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.view setNeedsDisplay];
                exit(0);
            });
        }else
        {
            [auth clearAllAuthorizationInfo];
            NSLog(@"fail");
        }
    }else
    {
        NSLog(@"000--------0000");
    }
}
#pragma mark - shareTo
//分享
- (void)shareToQQ
{
    FrontiaShare *share = [Frontia getShare];
    [share registerQQAppId:@"100358052" enableSSO:NO];//QQ
    [share registerWeixinAppId:@"wx70162e2c344d4c79"];//微信
    
    //授权取消回调函数
    FrontiaShareCancelCallback onCancel = ^(){
        NSLog(@"OnCancel: share is cancelled");
    };
    
    //授权失败回调函数
    FrontiaShareFailureCallback onFailure = ^(int errorCode, NSString *errorMessage){
        NSLog(@"OnFailure: %d  %@", errorCode, errorMessage);
    };
    
    //授权成功回调函数
    FrontiaMultiShareResultCallback onResult = ^(NSDictionary *respones){
        NSLog(@"OnResult: %@", [respones description]);
    };
    
    FrontiaShareContent *content=[[FrontiaShareContent alloc] init];
    content.url = @"http://developer.baidu.com/soc/share";
    content.title = @"中和讯飞--乐现";
    content.description = @"乐现是由北京中和讯飞开发的一款家居类APP，它可以让你身在千里之外都能随时观看家中情况，店铺情况，看你所看。";
    content.imageObj = @"http://apps.bdimg.com/developer/static/04171450/developer/images/icon/terminal_adapter.png";
    
    NSArray *platforms = @[FRONTIA_SOCIAL_SHARE_PLATFORM_SINAWEIBO,FRONTIA_SOCIAL_SHARE_PLATFORM_WEIXIN_TIMELINE,FRONTIA_SOCIAL_SHARE_PLATFORM_QQ,FRONTIA_SOCIAL_SHARE_PLATFORM_WEIXIN_SESSION,FRONTIA_SOCIAL_SHARE_PLATFORM_QQFRIEND,FRONTIA_SOCIAL_SHARE_PLATFORM_EMAIL,FRONTIA_SOCIAL_SHARE_PLATFORM_SMS];
    
    [share showShareMenuWithShareContent:content displayPlatforms:platforms supportedInterfaceOrientations:UIInterfaceOrientationMaskPortrait isStatusBarHidden:NO targetViewForPad:nil cancelListener:onCancel failureListener:onFailure resultListener:onResult];
}

//裁剪头像
- (UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset {
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    CGContextStrokePath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

//强制不允许转屏
//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
//}
//
//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
