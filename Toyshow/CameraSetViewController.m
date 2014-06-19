//
//  CameraSetViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-10.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "CameraSetViewController.h"
#import "SliderViewController.h"
#import "ModifyViewController.h"
#import "AFNetworking.h"
#import "ThumbnailViewController.h"
#import "SceneModeViewController.h"
#import "NtscOrpalViewController.h"
#import "ImageResolutionViewController.h"
#import "DeviceControlViewController.h"
#import "SensitivityViewController.h"
#import "MBProgressHUD.h"

@interface CameraSetViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,SceneModeViewControllerDelegate,NtscOrpalViewControllerDelegate,ImageResolutionViewControllerDelegate,DeviceControlViewControlDelegate,SensitivityViewControllerDelegate,MBProgressHUDDelegate>
{
    NSArray *cameraInfoArr;
    UIButton *codeStream;
    UILabel *deviceIDL,*deviceNameL;
    UIAlertView *codeStreamView,*logOutView;
    UILabel *scenceModeL,*cameraControlL,*sensitivityL,*ntscOrpalL,*imageResolutionL;
    UISwitch *iEnableEvent,*iScene,*iFlipImage,*iEnableAudioIn,*iEnableRecord,*iEnableDeviceStatusLed;
    MBProgressHUD *_loginoutView;
}
@end

@implementation CameraSetViewController

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
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+3, 120, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn setTitle:@"摄像头设置" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    UIButton *seeVideoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    seeVideoBtn.frame = CGRectMake(kWidth-65, [UIApplication sharedApplication].statusBarFrame.size.height+2, 55, 35);
    [seeVideoBtn setTitle:@"看录像" forState:UIControlStateNormal];
    [seeVideoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [seeVideoBtn setBackgroundImage:[UIImage imageNamed:@"lishijilu@2x"] forState:UIControlStateNormal];
//    [seeVideoBtn setImage:[UIImage imageNamed:@"lishijilu@2x"] forState:UIControlStateNormal];
    [seeVideoBtn addTarget:self action:@selector(didSeeVideoClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:seeVideoBtn];
    self.controlONOrOFFIndex = 3;
    self.lightFilterModeIndex = 1;
    self.imageResolutionIndex = 1;

    cameraInfoArr = [NSArray arrayWithObjects:@"事件通知",@"音频开关",@"视频开关",@"画面旋转",@"户外模式",@"拍摄模式",@"状态指示灯",@"码流设置",@"NTSC或PAL制式",@"分辨率",@"设备控制",@"灵敏度",@"设备ID",@"修改设备名称",@"",@"", nil];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, [UIScreen mainScreen].bounds.size.height-64) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
//    tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
}

- (void)backBtn:(id)sender
{
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

//看录像，进入录像列表
- (void)didSeeVideoClick
{
    NSLog(@"录像列表");
    ThumbnailViewController *thumbVC = [[ThumbnailViewController alloc] init];
    thumbVC.deviceID = self.deviceid;
    thumbVC.accessToken = self.access_token;
    thumbVC.deviceDesc = self.deviceDesc;
    [[SliderViewController sharedSliderController].navigationController pushViewController:thumbVC animated:YES];

}
//        UIImageView *cellView = [[UIImageView alloc] initWithFrame:cell.frame];
//        cellView.image = [UIImage imageNamed:@"xuanzhongtiao1@2x"];
//        cell.selectedBackgroundView = cellView;
#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdent = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        cell.textLabel.text = [cameraInfoArr objectAtIndex:indexPath.row];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    switch (indexPath.row) {
        case 0:
        {
            //事件通知
            UISwitch *offON = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
            [cell addSubview:offON];
            [offON addTarget:self action:@selector(enaleEventAction:) forControlEvents:UIControlEventTouchUpInside];
            offON.on = YES;
        }
            break;
        case 1:
        {
            //音频开关
            UISwitch *AudiooffON = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
            [cell addSubview:AudiooffON];
            AudiooffON.on = YES;
            [AudiooffON addTarget:self action:@selector(AudioEventAction:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 2:
        {
            //视频开关
            UISwitch *videooffON = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
            [cell addSubview:videooffON];
            //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            videooffON.on = YES;
            [videooffON addTarget:self action:@selector(VideoEventAction:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 3:
        {
            //画面是否旋转
            UISwitch *flipImageoffON = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
            [cell addSubview:flipImageoffON];
            [flipImageoffON addTarget:self action:@selector(flipImageoffONEventAction:) forControlEvents:UIControlEventTouchUpInside];
            
        }
            break;
        case 4:
        {
            UISwitch *outdoorOrindoor = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
            [cell addSubview:outdoorOrindoor];
            [outdoorOrindoor addTarget:self action:@selector(outdoorOrindoorEventAction:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 5:
        {
            //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NSArray *arr = [NSArray arrayWithObjects:@"自动",@"白天",@"夜间", nil];
            scenceModeL = [[UILabel alloc] init];
            scenceModeL.frame = CGRectMake(250, 7, 40, 30);
            [cell addSubview:scenceModeL];
            scenceModeL.text = [arr objectAtIndex:self.lightFilterModeIndex - 1];
            scenceModeL.textColor = [UIColor grayColor];
        }
            break;
        case 6:
        {
            UISwitch *stateLightoffON = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
            [cell addSubview:stateLightoffON];
            stateLightoffON.on = YES;
            [stateLightoffON addTarget:self action:@selector(stateLightEventAction:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 7:
        {
            codeStream = [UIButton buttonWithType:UIButtonTypeCustom];
            [codeStream setTitle:@"60kb/s" forState:UIControlStateNormal];
            codeStream.frame = CGRectMake(220, 5, 100, 34);
            [codeStream setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [cell addSubview:codeStream];
            [codeStream addTarget:self action:@selector(codeStreamAction:) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
        case 8:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            NSArray *arr = [NSArray arrayWithObjects:@"NTSC",@"PAL", nil];
            ntscOrpalL = [[UILabel alloc] init];
            ntscOrpalL.frame = CGRectMake(240, 7, 50, 30);
            ntscOrpalL.text = [arr objectAtIndex:self.ntscOrpalIndex];
            ntscOrpalL.textColor = [UIColor grayColor];
            [cell addSubview:ntscOrpalL];
        }
            break;
        case 9:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            NSArray *arr = [NSArray arrayWithObjects:@"1080",@"720",@"4CIF",@"640*480",@"352*288", nil];
            imageResolutionL = [[UILabel alloc] init];
            imageResolutionL.frame = CGRectMake(200, 7, 80, 30);
            [cell addSubview:imageResolutionL];
            imageResolutionL.text = [arr objectAtIndex:self.imageResolutionIndex-1];
            imageResolutionL.textAlignment = NSTextAlignmentRight;
            imageResolutionL.textColor = [UIColor grayColor];
        }
            break;
            
        case 10:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            NSArray *arr = [NSArray arrayWithObjects:@"睡眠",@"唤醒",@"关闭", nil];
            cameraControlL = [[UILabel alloc] init];
            cameraControlL.frame = CGRectMake(240, 7, 50, 30);
            [cell addSubview:cameraControlL];
            cameraControlL.text = [arr objectAtIndex:self.controlONOrOFFIndex - 1];
            cameraControlL.textColor = [UIColor grayColor];
        }
            break;
        case 11:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            NSArray *arr = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",nil];
            sensitivityL = [[UILabel alloc] init];
            sensitivityL.frame = CGRectMake(260, 7, 20, 30);
            sensitivityL.text = [arr objectAtIndex:self.sensitivityIndex];
            sensitivityL.textColor = [UIColor grayColor];
            [cell addSubview:sensitivityL];
            
        }
            break;
        case 12:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            deviceIDL = [[UILabel alloc] initWithFrame:CGRectMake(130, 10, 160, 24)];
            deviceIDL.text = self.deviceid;
            deviceIDL.textAlignment = NSTextAlignmentRight;
            deviceIDL.textColor = [UIColor grayColor];
            [cell addSubview:deviceIDL];
        }
            break;
        case 13:
        {
            //修改设备名称
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            deviceNameL = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 130, 24)];
            deviceNameL.text = self.deviceDesc;
            deviceNameL.textAlignment = NSTextAlignmentRight;
            deviceNameL.textColor = [UIColor grayColor];
            [cell addSubview:deviceNameL];
        }
            break;
        case 14:
        {
            UIButton *setFinish = [UIButton buttonWithType:UIButtonTypeCustom];
            [setFinish setTitle:@"完成设置" forState:UIControlStateNormal];
            setFinish.frame = CGRectMake(80, 3, 160, 40);
            [setFinish setBackgroundImage:[UIImage imageNamed:@"kaishipeizhi_anniu@2x"] forState:UIControlStateNormal];
//            setFinish.backgroundColor = [UIColor blueColor];
            [cell addSubview:setFinish];
            [setFinish addTarget:self action:@selector(setFinishAction:) forControlEvents:UIControlEventTouchUpInside];
            //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 15:
        {
            UIButton *loggout = [UIButton buttonWithType:UIButtonTypeCustom];
            [loggout setTitle:@"注销设备" forState:UIControlStateNormal];
            loggout.frame = CGRectMake(80, 3, 160, 40);
            [loggout setBackgroundImage:[UIImage imageNamed:@"kaishipeizhi_anniu@2x"] forState:UIControlStateNormal];
//            loggout.backgroundColor = [UIColor blueColor];
            [cell addSubview:loggout];
            [loggout addTarget:self action:@selector(LoginOutAction:) forControlEvents:UIControlEventTouchUpInside];
            //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
            break;
        default:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (cameraInfoArr.count) {
        return cameraInfoArr.count;
    }else
    {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 5:
        {
            SceneModeViewController *modeVC = [[SceneModeViewController alloc] init];
            modeVC.delegate = self;
            modeVC.lightFilterIndex = self.lightFilterModeIndex;
            modeVC.scenceMode = scenceModeL.text;
            [[SliderViewController sharedSliderController].navigationController pushViewController:modeVC animated:YES];
        }
            break;
            
        case 8:
        {
            NtscOrpalViewController *ntscOrpalVC = [[NtscOrpalViewController alloc] init];
            ntscOrpalVC.delegate = self;
            ntscOrpalVC.ntscOrpalIndex = self.ntscOrpalIndex;
            ntscOrpalVC.ntscOrpalMode = ntscOrpalL.text;
            [[SliderViewController sharedSliderController].navigationController pushViewController:ntscOrpalVC animated:YES];
        }
            break;
        case 9:
        {
            ImageResolutionViewController *resolutionlVC = [[ImageResolutionViewController alloc] init];
            resolutionlVC.delegate = self;
            resolutionlVC.imageResolutionIndex = self.imageResolutionIndex;
            resolutionlVC.resolution = imageResolutionL.text;
            [[SliderViewController sharedSliderController].navigationController pushViewController:resolutionlVC animated:YES];
        }
            break;
        case 10:
        {
            DeviceControlViewController *deviceControlVC = [[DeviceControlViewController alloc] init];
            deviceControlVC.delegate = self;
            deviceControlVC.index = self.controlONOrOFFIndex;
            [[SliderViewController sharedSliderController].navigationController pushViewController:deviceControlVC animated:YES];
        }
            break;
        case 11:
        {
            SensitivityViewController *sensitivityVC = [[SensitivityViewController alloc] init];
            sensitivityVC.delegate = self;
            sensitivityVC.index = self.sensitivityIndex;
            [[SliderViewController sharedSliderController].navigationController pushViewController:sensitivityVC animated:YES];
        }
            break;
        case 13:
        {
            ModifyViewController *modifyVC = [[ModifyViewController alloc] init];
            modifyVC.deviceId = self.deviceid;
            modifyVC.deviceName = self.deviceDesc;
            modifyVC.accessToken = self.access_token;
//            modifyVC.delegate = self;
            [[SliderViewController sharedSliderController].navigationController pushViewController:modifyVC animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - setMethod
- (void)enaleEventAction:(id)sender
{
    UISwitch *offswitch = (UISwitch *)sender;
    NSLog(@"offswtich.on:%d",offswitch.on);
    if (offswitch.on) {
        NSLog(@"打开的");
        self.EnableEventIndex = 1;
    }
    else
    {
        self.EnableEventIndex = 0;
        NSLog(@"关闭的");
    }
}
//音频是否打开
- (void)AudioEventAction:(id)sender
{
    UISwitch *offswitch = (UISwitch *)sender;
    NSLog(@"offswtich.on:%d",offswitch.on);
    if (offswitch.on) {
        NSLog(@"打开的音频");
        self.audioIndex = 1;
    }
    else
    {
        NSLog(@"关闭的");
        self.audioIndex = 0;
    }
}
//视频录制是否打开
- (void)VideoEventAction:(id)sender
{
    UISwitch *offswitch = (UISwitch *)sender;
    if (offswitch.on) {
        NSLog(@"打开的视频");
        self.videoRecordIndex = 1;
    }
    else
    {
        NSLog(@"关闭的");
        self.videoRecordIndex = 0;
    }
}
//画面是否旋转
- (void)flipImageoffONEventAction:(id)sender
{
    UISwitch *offswitch = (UISwitch *)sender;
    if (offswitch.on) {
        NSLog(@"打开的");
        self.flipImageIndex = 1;
    }
    else
    {
        NSLog(@"关闭的");
        self.flipImageIndex = 0;
    }
}

//室内室外
- (void)outdoorOrindoorEventAction:(id)sender
{
    UISwitch *outdoorOrindoor = (UISwitch *)sender;
    if (outdoorOrindoor.on) {
        self.screneIndex = 1;
        
    }else
    {
        self.screneIndex = 0;
    }
    NSLog(@"室内室外");
}

//状态指示灯
- (void)stateLightEventAction:(id)sender
{
    NSLog(@"状态指示灯");
    UISwitch *offswitch = (UISwitch *)sender;
    if (offswitch.on) {
        self.lightStatueIndex = 1;
    }
    else
    {
        self.lightStatueIndex = 0;
    }
}

//码流设置
- (void)codeStreamAction:(id)sender
{
    codeStreamView = [[UIAlertView alloc] initWithTitle:@"带宽控制" message:@"带宽值应该设为60-3000kb/s" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    codeStreamView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [codeStreamView show];
}

//完成设置
- (void)setFinishAction:(id)sender
{
    NSLog(@"setFinishAction");
    NSString *str = [NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",self.EnableEventIndex,self.audioIndex,self.videoRecordIndex,self.flipImageIndex,self.screneIndex,self.lightFilterModeIndex,self.lightStatueIndex,self.streamBitrateIndex,self.ntscOrpalIndex,self.imageResolutionIndex,self.controlONOrOFFIndex,self.controlONOrOFFIndex];
    NSLog(@"str:%@",str);
    if (self.delegate && [self.delegate respondsToSelector:@selector(logoutCameraAtindex:)]) {
        [self.delegate logoutCameraAtindex:self.index];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

//注销设备
- (void)LoginOutAction:(id)sender
{
    logOutView = [[UIAlertView alloc] initWithTitle:@"注销设备？" message:@"确定要注销设备吗？注销之后该设备的录像等信息将全部被清除" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    logOutView.delegate = self;
    [logOutView show];
}

#pragma mark - Delegate
- (void)scenceMode:(NSString *)mode withIndex:(NSInteger)index
{
    scenceModeL.text = mode;
    self.lightFilterModeIndex = index;
}

- (void)ntscOrpalMode:(NSString *)mode withIndex:(NSInteger)index
{
    ntscOrpalL.text = mode;
    self.ntscOrpalIndex = index;
}

- (void)imageResolution:(NSString *)resolution withIndex:(NSInteger)index
{
    imageResolutionL.text = resolution;
    self.imageResolutionIndex = index;
}

- (void)deviceControlMode:(NSString *)deviceMode withIndex:(NSInteger)index
{
    cameraControlL.text = deviceMode;
    self.controlONOrOFFIndex = index;
}

- (void)SensitivityleWithIndex:(NSInteger)index
{
    sensitivityL.text = [NSString stringWithFormat:@"%d",index];
    self.sensitivityIndex = index;
}

- (void)isLoadingView
{
    _loginoutView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_loginoutView];
    
    _loginoutView.delegate = self;
    _loginoutView.labelText = @"loading";
    _loginoutView.detailsLabelText = @"正在注销，请稍后……";
    _loginoutView.square = YES;
    _loginoutView.color = [UIColor grayColor];
    [_loginoutView show:YES];
}
#pragma mark - alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (logOutView == alertView) {
        //注销
        if (buttonIndex) {
//            NSLog(@"注销设备了");
            [self isLoadingView];
            NSString *urlStr = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=drop&deviceid=%@&access_token=%@",self.deviceid,self.access_token];
            NSLog(@"urlStr:%@",urlStr);
            [[AFHTTPRequestOperationManager manager] POST:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSDictionary *dict = (NSDictionary *)responseObject;
                NSString *deviceID = [dict objectForKey:@"deviceid"];
                NSLog(@"deviceid:%@",deviceID);
                if (self.delegate && [self.delegate respondsToSelector:@selector(logoutCameraAtindex:)]) {
                    [self.delegate logoutCameraAtindex:self.index];
                }
                [_loginoutView hide:YES];

                [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
                UIAlertView *tipView = [[UIAlertView alloc] initWithTitle:@"注销成功" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [tipView show];
                                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSDictionary *errorDict = [error userInfo];
                NSString *errorMSG = [errorDict objectForKey:@"error_msg"];
                NSLog(@"erroeMSG:%@",errorMSG);
                [_loginoutView hide:YES];

                UIAlertView *tipView = [[UIAlertView alloc] initWithTitle:@"注销失败" message:[NSString stringWithFormat:@"%@",errorMSG] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [tipView show];
            }];
        }
    }else if (codeStreamView == alertView)
    {
        if (buttonIndex) {
            UITextField *textfied = [alertView textFieldAtIndex:0];
            BOOL flag = [self isLegalNum:60 to:3000 withNumString:textfied.text];
            if (flag) {
                [codeStream setTitle:[textfied.text stringByAppendingString:@"kb/s"] forState:UIControlStateNormal];
                self.streamBitrateIndex = [textfied.text integerValue];
            }
        }
    }
    
}
//判断输入的值是否介于两者之间
- (BOOL)isLegalNum:(int)startNum to:(int)endNum withNumString:(NSString *)numString
{
    int bandw = [numString intValue];
    if (bandw >= startNum && bandw <= endNum) {
        return YES;
    }else{
        UIAlertView *errorV = [[UIAlertView alloc] initWithTitle:@"错误" message:[NSString stringWithFormat:@"带宽值应该设为%d-%dkb/s",startNum,endNum] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil];
        [errorV show];
        return NO;
    }
}

#pragma mark - modifyDelegate
- (void)modifySuccessWith:(NSString *)newName
{
    deviceNameL.text = newName;
    if (self.delegate && [self.delegate respondsToSelector:@selector(logoutCameraAtindex:)]) {
        [self.delegate logoutCameraAtindex:self.index];
        [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:NO];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
