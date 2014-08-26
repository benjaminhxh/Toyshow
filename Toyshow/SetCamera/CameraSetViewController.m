//
//  CameraSetViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-10.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "CameraSetViewController.h"
#import "ModifyViewController.h"
#import "ThumbnailViewController.h"
#import "SceneModeViewController.h"
#import "NtscOrpalViewController.h"
#import "ImageResolutionViewController.h"
#import "DeviceControlViewController.h"
#import "SensitivityViewController.h"
#import "AudioVideoViewController.h"
#import "NightViewController.h"
#import "EventNotificationViewController.h"
#import "DeviceStatueControlViewController.h"
#import "DeviceInfoViewController.h"
@interface CameraSetViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,SceneModeViewControllerDelegate,NtscOrpalViewControllerDelegate,ImageResolutionViewControllerDelegate,DeviceControlViewControlDelegate,SensitivityViewControllerDelegate,MBProgressHUDDelegate>
{
    NSArray *cameraInfoArr;
    UIButton *codeStream;
    UILabel *deviceIDL,*deviceNameL;
    UIAlertView *codeStreamView,*logOutView;
    UILabel *scenceModeL,*cameraControlL,*sensitivityL,*ntscOrpalL,*imageResolutionL;
    UISwitch *iEnableEvent,*iScene,*iFlipImage,*iEnableAudioIn,*iEnableRecord,*iEnableDeviceStatusLed;
    MBProgressHUD *_loginoutView;
    NSDictionary *cameraInfoDict;
    int count;
    UITableView *_tableView;
    UISwitch *videooffON,*stateLightoffON,*timeHidden;
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
    [seeVideoBtn addTarget:self action:@selector(didSeeVideoClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:seeVideoBtn];
    self.controlONOrOFFIndex = 3;
    cameraInfoArr = [NSArray arrayWithObjects:@"音视频设置",@"夜视功能设置",@"事件通知",@"录像控制",@"状态指示灯",@"时间显示",@"设备状态控制",@"设备信息",@"", nil];

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, [UIScreen mainScreen].bounds.size.height-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    if (self.isOnline) {
        [self getDeviceInfo];
    }

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

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row<3 || indexPath.row>5) {
//        return 50;
//    }else
//    {
//        return 64;
//    }
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdent = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (0 == indexPath.section) {
        if (cell==nil) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdent];
            cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
            
            cell.textLabel.text = [cameraInfoArr objectAtIndex:indexPath.row];
        }
        switch (indexPath.row) {
            case 3:
            {
    //            //事件通知
    //            UISwitch *offON = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
    //            [cell addSubview:offON];
    //            [offON addTarget:self action:@selector(enaleEventAction:) forControlEvents:UIControlEventTouchUpInside];
    //            self.EnableEventIndex = [[cameraInfoDict objectForKey:@"iEnableEvent"] integerValue];
    //            offON.on = self.EnableEventIndex;
                
                //录像控制开关
                videooffON = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
                [cell addSubview:videooffON];
                //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                self.videoRecordIndex = [[cameraInfoDict objectForKey:@"iEnableRecord"] integerValue];
                videooffON.on = self.videoRecordIndex;
                [videooffON addTarget:self action:@selector(VideoEventAction:) forControlEvents:UIControlEventTouchUpInside];
//                cell.detailTextLabel.text = @"是否允许录像";
            }
                break;
            case 4:
            {
    //            //音频开关
    //            UISwitch *AudiooffON = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
    //            [cell addSubview:AudiooffON];
    //            self.audioIndex = [[cameraInfoDict objectForKey:@"iEnableAudioIn"] integerValue];
    //            AudiooffON.on = self.audioIndex;
    //            [AudiooffON addTarget:self action:@selector(AudioEventAction:) forControlEvents:UIControlEventTouchUpInside];
                //状态指示灯
                stateLightoffON = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
                [cell addSubview:stateLightoffON];
                self.lightStatueIndex = [[cameraInfoDict objectForKey:@"iEnableDeviceStatusLed"] integerValue];
                
                stateLightoffON.on = self.lightStatueIndex;
                [stateLightoffON addTarget:self action:@selector(stateLightEventAction:) forControlEvents:UIControlEventTouchUpInside];
//                cell.detailTextLabel.text = @"设备状态指示灯是否开启";

            }
                break;
            case 5:
            {
                //时间显示
                timeHidden = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
                [cell addSubview:timeHidden];
                self.timeShowIndex = [[cameraInfoDict objectForKey:@"iEnableOSDTime"] integerValue];
                timeHidden.on = self.timeShowIndex;
                [timeHidden addTarget:self action:@selector(timeHiddenEventAction:) forControlEvents:UIControlEventTouchUpInside];
//                cell.detailTextLabel.text = @"播放画面是否显示时间";
            }
                break;
    //        case 3:
    //        {
    //            //画面是否旋转
    //            UISwitch *flipImageoffON = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
    //            [cell addSubview:flipImageoffON];
    //            self.flipImageIndex = [[cameraInfoDict objectForKey:@"iFlipImage"] integerValue];
    //            flipImageoffON.on = self.flipImageIndex;
    //            [flipImageoffON addTarget:self action:@selector(flipImageoffONEventAction:) forControlEvents:UIControlEventTouchUpInside];
    //            
    //        }
    //            break;
    //        case 4:
    //        {
    //            //户外室内
    //            UISwitch *outdoorOrindoor = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
    //            [cell addSubview:outdoorOrindoor];
    //            self.screneIndex = [[cameraInfoDict objectForKey:@"iScene"] integerValue];
    //            
    //            outdoorOrindoor.on = self.screneIndex;
    //            [outdoorOrindoor addTarget:self action:@selector(outdoorOrindoorEventAction:) forControlEvents:UIControlEventTouchUpInside];
    //        }
    //            break;
    //        case 5:
    //        {
    //            //拍摄模式
    //            //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //            NSArray *arr = [NSArray arrayWithObjects:@"自动",@"白天",@"夜间", nil];
    //            scenceModeL = [[UILabel alloc] init];
    //            scenceModeL.frame = CGRectMake(250, 7, 40, 30);
    //            [cell addSubview:scenceModeL];
    //            self.lightFilterModeIndex = [[cameraInfoDict objectForKey:@"iLightFilterMode"] integerValue];
    //            scenceModeL.text = [arr objectAtIndex:self.lightFilterModeIndex];
    //            scenceModeL.textColor = [UIColor grayColor];
    //        }
    //            break;
    //        case 6:
    //        {
    //           
    //        }
    //            break;
    //        case 7:
    //        {
    //            //码流
    ////            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //
    //            codeStream = [UIButton buttonWithType:UIButtonTypeCustom];
    //            self.streamBitrateIndex = [[cameraInfoDict objectForKey:@"iStreamBitrate"] integerValue];
    //            
    //            [codeStream setTitle:[NSString stringWithFormat:@"%dkb/s",self.streamBitrateIndex] forState:UIControlStateNormal];
    //            codeStream.frame = CGRectMake(220, 5, 100, 34);
    //            [codeStream setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    //            [cell addSubview:codeStream];
    ////            [codeStream addTarget:self action:@selector(codeStreamAction:) forControlEvents:UIControlEventTouchUpInside];
    //        }
    //            break;
    //        case 8:
    //        {
    //            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //            
    //            NSArray *arr = [NSArray arrayWithObjects:@"NTSC",@"PAL", nil];
    //            ntscOrpalL = [[UILabel alloc] init];
    //            ntscOrpalL.frame = CGRectMake(240, 7, 50, 30);
    //            self.ntscOrpalIndex = [[cameraInfoDict objectForKey:@"iNTSCPAL"] integerValue];
    //            ntscOrpalL.text = [arr objectAtIndex:self.ntscOrpalIndex-1];
    //            ntscOrpalL.textColor = [UIColor grayColor];
    //            [cell addSubview:ntscOrpalL];
    //        }
    //            break;
    //        case 9:
    //        {
    //            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //            
    //            NSArray *arr = [NSArray arrayWithObjects:@"1080",@"720",@"4CIF",@"640*480",@"352*288", nil];
    //            imageResolutionL = [[UILabel alloc] init];
    //            imageResolutionL.frame = CGRectMake(200, 7, 80, 30);
    //            [cell addSubview:imageResolutionL];
    //            self.imageResolutionIndex = [[cameraInfoDict objectForKey:@"iImageResolution"] integerValue];
    //            imageResolutionL.text = [arr objectAtIndex:self.imageResolutionIndex-1];
    //            imageResolutionL.textAlignment = NSTextAlignmentRight;
    //            imageResolutionL.textColor = [UIColor grayColor];
    //        }
    //            break;
    //        case 10:
    //        {
    //            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //            
    //            NSArray *arr = [NSArray arrayWithObjects:@"睡眠",@"唤醒",@"关闭", nil];
    //            cameraControlL = [[UILabel alloc] init];
    //            cameraControlL.frame = CGRectMake(240, 7, 50, 30);
    //            [cell addSubview:cameraControlL];
    //            self.controlONOrOFFIndex = [[cameraInfoDict objectForKey:@"iDeviceControl"] integerValue];
    //            //这里未收到信息
    ////            cameraControlL.text = [arr objectAtIndex:self.controlONOrOFFIndex-1];
    //            cameraControlL.textColor = [UIColor grayColor];
    //        }
    //            break;
    //        case 11:
    //        {
    //            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //            NSArray *arr = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",nil];
    //            sensitivityL = [[UILabel alloc] init];
    //            sensitivityL.frame = CGRectMake(260, 7, 20, 30);
    //            self.sensitivityIndex = [[cameraInfoDict objectForKey:@"iObjDetectLevel"] integerValue];
    //            
    //            sensitivityL.text = [arr objectAtIndex:self.sensitivityIndex];
    //            sensitivityL.textColor = [UIColor grayColor];
    //            [cell addSubview:sensitivityL];
    //            
    //        }
    //            break;
    //        case 12:
    //        {
    //
    //        }
    //            break;
    //            
    //        case 13:
    //        {
    //            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    //            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //            deviceIDL = [[UILabel alloc] initWithFrame:CGRectMake(130, 10, 160, 24)];
    //            //            self.deviceid = [[cameraInfoDict objectForKey:@"i64DeviceId"] integerValue];
    //            
    //            deviceIDL.text = self.deviceid;
    //            deviceIDL.textAlignment = NSTextAlignmentRight;
    //            deviceIDL.textColor = [UIColor grayColor];
    //            [cell addSubview:deviceIDL];
    //        }
    //            break;
//            case 7:
//            {
//                //修改设备名称
//                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                deviceNameL = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 130, 24)];
//                deviceNameL.text = self.deviceDesc;
//                deviceNameL.textAlignment = NSTextAlignmentRight;
//                deviceNameL.textColor = [UIColor grayColor];
//                [cell addSubview:deviceNameL];
//            }
//                break;
    //        case 15:
    //        {
    //            UIButton *setFinish = [UIButton buttonWithType:UIButtonTypeCustom];
    //            [setFinish setTitle:@"完成设置" forState:UIControlStateNormal];
    //            setFinish.frame = CGRectMake(80, 3, 160, 40);
    //            [setFinish setBackgroundImage:[UIImage imageNamed:@"kaishipeizhi_anniu@2x"] forState:UIControlStateNormal];
    //            //            setFinish.backgroundColor = [UIColor blueColor];
    //            [cell addSubview:setFinish];
    //            [setFinish addTarget:self action:@selector(setFinishAction:) forControlEvents:UIControlEventTouchUpInside];
    //            //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //        }
    //            break;
    //        case 9:
    //        {
    //            
    //            //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //            
    //        }
    //            break;
            default:
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else
    {
        if (cell==nil) {
            cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];

            if (indexPath.row) {
                UIButton *loggout = [UIButton buttonWithType:UIButtonTypeCustom];
                [loggout setTitle:@"注销设备" forState:UIControlStateNormal];
                loggout.frame = CGRectMake(80, 3, 160, 40);
                [loggout setBackgroundImage:[UIImage imageNamed:@"kaishipeizhi_anniu@2x"] forState:UIControlStateNormal];
                //            loggout.backgroundColor = [UIColor blueColor];
                [cell addSubview:loggout];
                [loggout addTarget:self action:@selector(LoginOutAction:) forControlEvents:UIControlEventTouchUpInside];
            }else
            {
                //修改设备名称
                cell.textLabel.text = @"修改设备名称";
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                deviceNameL = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 130, 24)];
                deviceNameL.text = self.deviceDesc;
                deviceNameL.textAlignment = NSTextAlignmentRight;
                deviceNameL.textColor = [UIColor grayColor];
                [cell addSubview:deviceNameL];
            }
        }
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (cameraInfoArr.count) {
//        return cameraInfoArr.count;
//    }else
//    {
//        return 0;
//    }
    if (0 == section) {
        return count;
    }else
    {
        return 2;
    }
//    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
            switch (indexPath.row) {
    //        case 5:
    //        {
    //            SceneModeViewController *modeVC = [[SceneModeViewController alloc] init];
    //            modeVC.delegate = self;
    //            modeVC.lightFilterIndex = self.lightFilterModeIndex;
    //            modeVC.scenceMode = scenceModeL.text;
    //            [[SliderViewController sharedSliderController].navigationController pushViewController:modeVC animated:YES];
    //        }
    //            break;
    //          case 7:
    //        {
    //            [self codeStreamAction:nil];
    //        }
    //            break;
    //        case 8:
    //        {
    //            NtscOrpalViewController *ntscOrpalVC = [[NtscOrpalViewController alloc] init];
    //            ntscOrpalVC.delegate = self;
    //            ntscOrpalVC.ntscOrpalIndex = self.ntscOrpalIndex;
    //            ntscOrpalVC.ntscOrpalMode = ntscOrpalL.text;
    //            [[SliderViewController sharedSliderController].navigationController pushViewController:ntscOrpalVC animated:YES];
    //        }
    //            break;
    //        case 9:
    //        {
    //            ImageResolutionViewController *resolutionlVC = [[ImageResolutionViewController alloc] init];
    //            resolutionlVC.delegate = self;
    //            resolutionlVC.imageResolutionIndex = self.imageResolutionIndex;
    //            resolutionlVC.resolution = imageResolutionL.text;
    //            [[SliderViewController sharedSliderController].navigationController pushViewController:resolutionlVC animated:YES];
    //        }
    //            break;
    //        case 10:
    //        {
    //            DeviceControlViewController *deviceControlVC = [[DeviceControlViewController alloc] init];
    //            deviceControlVC.delegate = self;
    //            deviceControlVC.index = self.controlONOrOFFIndex;
    //            [[SliderViewController sharedSliderController].navigationController pushViewController:deviceControlVC animated:YES];
    //        }
    //            break;
    //        case 11:
    //        {
    //            SensitivityViewController *sensitivityVC = [[SensitivityViewController alloc] init];
    //            sensitivityVC.delegate = self;
    //            sensitivityVC.index = self.sensitivityIndex;
    //            [[SliderViewController sharedSliderController].navigationController pushViewController:sensitivityVC animated:YES];
    //        }
    //            break;
            case 0:
            {
                AudioVideoViewController *avideoVC = [[AudioVideoViewController alloc] init];
                avideoVC.access_token = self.access_token;
                avideoVC.deviceid = self.deviceid;
                avideoVC.audioIndex = [[cameraInfoDict objectForKey:@"iEnableAudioIn"] integerValue];
                avideoVC.streamIndex = [cameraInfoDict objectForKey:@"iStreamBitrate"];
                avideoVC.flipImageIndex = [[cameraInfoDict objectForKey:@"iFlipImage"] integerValue];
                avideoVC.ntscOrPalIndex = [[cameraInfoDict objectForKey:@"iNTSCPAL"] integerValue];
                avideoVC.imageResolutionIndex = [[cameraInfoDict objectForKey:@"iImageResolution"] integerValue];
                NSLog(@"分辨率：%@",[cameraInfoDict objectForKey:@"iImageResolution"]);
                [[SliderViewController sharedSliderController].navigationController pushViewController:avideoVC animated:YES];
            }
                break;
            case 1:
            {
                NightViewController *nightVC = [[NightViewController alloc] init];
                nightVC.access_token = self.access_token;
                nightVC.deviceid = self.deviceid;
                nightVC.isenceIndex = [[cameraInfoDict objectForKey:@"iScene"] integerValue];
                nightVC.filterIndex = [[cameraInfoDict objectForKey:@"iLightFilterMode"] integerValue];
                [[SliderViewController sharedSliderController].navigationController pushViewController:nightVC animated:YES];
            }
                break;
            case 2:
            {
                EventNotificationViewController *eventNotifVC = [[EventNotificationViewController alloc] init];
                eventNotifVC.access_token = self.access_token;
                eventNotifVC.deviceid = self.deviceid;
                eventNotifVC.eventNotifIndex = [[cameraInfoDict objectForKey:@"iEnableEvent"] integerValue];
                eventNotifVC.sensityIndex = [[cameraInfoDict objectForKey:@"iObjDetectLevel"] integerValue];
                [[SliderViewController sharedSliderController].navigationController pushViewController:eventNotifVC animated:YES];
            }
                break;
            case 6:
            {
                DeviceStatueControlViewController *statueControlVC = [[DeviceStatueControlViewController alloc] init];
                statueControlVC.access_token = self.access_token;
                statueControlVC.deviceid = self.deviceid;
                [[SliderViewController sharedSliderController].navigationController pushViewController:statueControlVC animated:YES];
            }
                break;
            case 7:
            {
                DeviceInfoViewController *deviceInfoVC = [[DeviceInfoViewController alloc] init];
                deviceInfoVC.deviceInfoDict = cameraInfoDict;
                [[SliderViewController sharedSliderController].navigationController pushViewController:deviceInfoVC animated:YES];
            }
                break;
            default:
                break;
        }
    }else
    {
        if (0 == indexPath.row) {
            ModifyViewController *modifyVC = [[ModifyViewController alloc] init];
            modifyVC.deviceId = self.deviceid;
            modifyVC.deviceName = self.deviceDesc;
            modifyVC.accessToken = self.access_token;
            //            modifyVC.delegate = self;
            [[SliderViewController sharedSliderController].navigationController pushViewController:modifyVC animated:YES];
        }
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section) {
//        return 24;
//    }else
//    return 0;
//}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section) {
//        return @"";
//    }else
//        return nil;
//}
#pragma mark - setMethod
//- (void)enaleEventAction:(id)sender
//{
//    UISwitch *offswitch = (UISwitch *)sender;
//    NSLog(@"offswtich.on:%d",offswitch.on);
//    if (offswitch.on) {
//        NSLog(@"打开的");
//        self.EnableEventIndex = 1;
//    }
//    else
//    {
//        self.EnableEventIndex = 0;
//        NSLog(@"关闭的");
//    }
//}
//音频是否打开
//- (void)AudioEventAction:(id)sender
//{
//    UISwitch *offswitch = (UISwitch *)sender;
//    NSLog(@"offswtich.on:%d",offswitch.on);
//    if (offswitch.on) {
//        NSLog(@"打开的音频");
//        self.audioIndex = 1;
//    }
//    else
//    {
//        NSLog(@"关闭的");
//        self.audioIndex = 0;
//    }
//}
//视频录制是否打开
- (void)VideoEventAction:(id)sender
{
//    UISwitch *offswitch = (UISwitch *)sender;
//    if (offswitch.on) {
//        NSLog(@"打开的视频");
//        self.videoRecordIndex = 1;
//    }
//    else
//    {
//        NSLog(@"关闭的");
//        self.videoRecordIndex = 0;
//    }
    _loginoutView.hidden = NO;
    self.videoRecordIndex = videooffON.on;

    NSDictionary *setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInteger:self.videoRecordIndex],@"iEnableRecord",nil];
    NSString *setCameraDataString = [setCameraDataDict JSONString];
    NSString *strWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)setCameraDataString, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *setURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
    [[AFHTTPRequestOperationManager manager] POST:setURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary*)responseObject;
        NSLog(@"dict:%@",dict);
        videooffON.on = self.videoRecordIndex;
        _loginoutView.hidden = YES;
        [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        videooffON.on = !self.videoRecordIndex;
        _loginoutView.hidden = YES;
        [self alertViewShowWithTitle:@"设置失败" andMessage:nil];
    }];
}
////画面是否旋转
//- (void)flipImageoffONEventAction:(id)sender
//{
//    UISwitch *offswitch = (UISwitch *)sender;
//    if (offswitch.on) {
//        NSLog(@"打开的");
//        self.flipImageIndex = 1;
//    }
//    else
//    {
//        NSLog(@"关闭的");
//        self.flipImageIndex = 0;
//    }
//}

////室内室外
//- (void)outdoorOrindoorEventAction:(id)sender
//{
//    UISwitch *outdoorOrindoor = (UISwitch *)sender;
//    if (outdoorOrindoor.on) {
//        self.screneIndex = 1;
//        
//    }else
//    {
//        self.screneIndex = 0;
//    }
//    NSLog(@"室内室外");
//}

//设备状态指示灯
- (void)stateLightEventAction:(id)sender
{
    NSLog(@"状态指示灯");
    _loginoutView.hidden = NO;
//    UISwitch *offswitch = (UISwitch *)sender;
//    if (offswitch.on) {
//        self.lightStatueIndex = 1;
//    }
//    else
//    {
//        self.lightStatueIndex = 0;
//    }
    self.lightStatueIndex = stateLightoffON.on;
    NSDictionary *setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInteger:self.lightStatueIndex],@"iEnableDeviceStatusLed",nil];
    NSString *setCameraDataString = [setCameraDataDict JSONString];
    NSString *strWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)setCameraDataString, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *setURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
    [[AFHTTPRequestOperationManager manager] POST:setURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary*)responseObject;
        NSLog(@"dict:%@",dict);
        stateLightoffON.on = self.lightStatueIndex;
        _loginoutView.hidden = YES;
        [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        stateLightoffON.on = !self.lightStatueIndex;
        _loginoutView.hidden = YES;
        [self alertViewShowWithTitle:@"设置失败" andMessage:nil];
    }];

}

//码流设置
//- (void)codeStreamAction:(id)sender
//{
//    codeStreamView = [[UIAlertView alloc] initWithTitle:@"带宽控制" message:@"带宽值应该设为60-3000kb/s" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
//    codeStreamView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    [codeStreamView show];
//}

//是否在界面上显示时间
- (void)timeHiddenEventAction:(id)sender
{
    NSLog(@"时间是否显示");
    _loginoutView.hidden = NO;
//    UISwitch *timeStaueSwitch = (UISwitch *)sender;
//    if (timeStaueSwitch.on) {
//        self.timeShowIndex = 1;
//    }
//    else
//    {
//        self.timeShowIndex = 0;
//    }

    self.timeShowIndex = timeHidden.on;
    NSDictionary *setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInteger:self.timeShowIndex],@"iEnableOSDTime",nil];
    NSString *setCameraDataString = [setCameraDataDict JSONString];
    NSString *strWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)setCameraDataString, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *setURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
    [[AFHTTPRequestOperationManager manager] POST:setURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary*)responseObject;
        NSLog(@"dict:%@",dict);
        timeHidden.on = self.timeShowIndex;
        _loginoutView.hidden = YES;
        [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        timeHidden.on = !self.timeShowIndex;
        _loginoutView.hidden = YES;
        [self alertViewShowWithTitle:@"设置失败" andMessage:nil];
    }];
}

//完成设置
//- (void)setFinishAction:(id)sender
//{
//    NSLog(@"setFinishAction");
//    _loginoutView.hidden = NO;
//    NSString *str = [NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d",self.EnableEventIndex,self.audioIndex,self.videoRecordIndex,self.flipImageIndex,self.screneIndex,self.lightFilterModeIndex,self.lightStatueIndex,self.streamBitrateIndex,self.ntscOrpalIndex,self.imageResolutionIndex,self.controlONOrOFFIndex,self.sensitivityIndex,self.timeShowIndex];
//    NSLog(@"str:%@",str);
//    NSDictionary *setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   [NSNumber numberWithInteger:self.EnableEventIndex],@"iEnableEvent",
//                                   [NSNumber numberWithInteger:self.audioIndex],@"iEnableAudioIn",
//                                   [NSNumber numberWithInteger:self.videoRecordIndex],@"iEnableRecord",
//                                   [NSNumber numberWithInteger:self.flipImageIndex],@"iFlipImage",
//                                   [NSNumber numberWithInteger:self.screneIndex],@"iScene",
//                                   [NSNumber numberWithInteger:self.lightFilterModeIndex],@"iLightFilterMode",
//                                   [NSNumber numberWithInteger:self.lightStatueIndex],@"iEnableDeviceStatusLed",
//                                   [NSNumber numberWithInteger:self.streamBitrateIndex],@"iStreamBitrate",
//                                   [NSNumber numberWithInteger:self.ntscOrpalIndex],@"iNTSCPAL",
//                                   [NSNumber numberWithInteger:self.imageResolutionIndex],@"iEnableAudioIn",
//                                   [NSNumber numberWithInteger:self.controlONOrOFFIndex],@"iEnableAudioIn",
//                                   [NSNumber numberWithInteger:self.sensitivityIndex],@"iObjDetectLevel",
//                                   [NSNumber numberWithInteger:self.timeShowIndex],@"iEnableOSDTime",
//                                   nil];
//    NSLog(@"setCameraDataDict:%@",setCameraDataDict);
////    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"iNTSCPAL", nil];
//    NSString *setCameraDataString = [setCameraDataDict JSONString];
//    NSString *strWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)setCameraDataString, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
//    NSString *setURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
//////    NSString *setURL = @"http://119.188.2.50/data2/video04/2013/04/27/00ab3b24-74de-432b-b703-a46820c9cd6f.mp4";
//    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:@"control",@"method",self.access_token,@"access_token",self.deviceid,@"deviceid",setCameraDataDict,@"command", nil];
//    NSLog(@"paramDict:%@",paramDict);
//    [[AFHTTPSessionManager manager] POST:setURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSDictionary *dict = (NSDictionary*)responseObject;
//        NSLog(@"dict:%@",dict);
//        [self alertViewShowWithTitle:@"设置成功" andMessage:nil];
//        if (self.delegate && [self.delegate respondsToSelector:@selector(logoutCameraAtindex:)]) {
//            [self.delegate logoutCameraAtindex:self.index];
//        }
//        _loginoutView.hidden = YES;
//        [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
//
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        _loginoutView.hidden = YES;
//        [self alertViewShowWithTitle:@"设置失败" andMessage:nil];
//        
//    }];
//}

//注销设备
- (void)LoginOutAction:(id)sender
{
    logOutView = [[UIAlertView alloc] initWithTitle:@"注销设备？" message:@"确定要注销设备吗？注销之后该设备的录像等信息将全部被清除" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    logOutView.delegate = self;
    [logOutView show];
}

#pragma mark - SetParameDelegate
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
    if (_loginoutView) {
        [_loginoutView show:YES];
        return;
    }
    _loginoutView = [[MBProgressHUD alloc] initWithView:_tableView];
    [_tableView addSubview:_loginoutView];
    _loginoutView.delegate = self;
    _loginoutView.labelText = @"loading";
//    _loginoutView.detailsLabelText = @"正在注销，请稍后……";
    _loginoutView.square = YES;
    _loginoutView.color = [UIColor grayColor];
    [_loginoutView show:YES];
}
#pragma mark - alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (logOutView == alertView) {
        //注销
        if (buttonIndex)
        {
            [self logoutMyCamera];
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

#pragma mark - logoutMyCamera
- (void)logoutMyCamera
{
    //注销设备
    _loginoutView.mode = 0;
    _loginoutView.labelText = @"注销中……";
    _loginoutView.hidden = NO;
    NSString *urlStr = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=drop&deviceid=%@&access_token=%@",self.deviceid,self.access_token];
    NSLog(@"urlStr:%@",urlStr);
    [[AFHTTPRequestOperationManager manager] POST:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSString *deviceID = [dict objectForKey:@"deviceid"];
        NSLog(@"deviceid:%@",deviceID);
        if (self.delegate && [self.delegate respondsToSelector:@selector(logoutCameraAtindex:)]) {
            [self.delegate logoutCameraAtindex:self.index];
        }
        _loginoutView.mode = 4;
        _loginoutView.labelText = @"注销成功";
        [_loginoutView hide:YES];
        
        [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
//        [self alertViewShowWithTitle:@"注销成功" andMessage:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *errorDict = [error userInfo];
        NSString *errorMSG = [errorDict objectForKey:@"error_msg"];
        NSLog(@"erroeMSG:%@",errorMSG);
        _loginoutView.mode = 4;
        _loginoutView.labelText = @"注销失败";
        [_loginoutView hide:YES];
//        [self alertViewShowWithTitle:@"注销失败" andMessage:errorMSG];
    }];
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

//首次进来获取设备的详细信息
- (void)getDeviceInfo
{
    [self isLoadingView];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"iGetDeviceConfig", nil];
//    NSDictionary *getInfoparamDict = [NSDictionary dictionaryWithObjectsAndKeys:dict,@"command", nil];
    NSString *requestStr = [dict JSONString];
//    NSLog(@"requestStr:%@",requestStr);
    NSString *strWithUTF8 = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)requestStr, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));

    NSString *getInfoURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
    NSLog(@"getInfoURL:%@",getInfoURL);
    [[AFHTTPRequestOperationManager manager] POST:getInfoURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary*)responseObject;
        NSArray *arr = [dict objectForKey:@"data"];
        NSDictionary *userData = [arr lastObject];
        //        NSLog(@"userData:%@",userData);
        NSString *userDataString = [userData objectForKey:@"userData"];
        NSLog(@"userDataDict:%@",userDataString);
        NSData *resData = [[NSData alloc] initWithData:[userDataString dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析
        cameraInfoDict = [NSDictionary dictionary];
        cameraInfoDict = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        count = 8;
        _loginoutView.hidden = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            //            [self.view setNeedsDisplay]; //7
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _loginoutView.hidden = YES;
        [self alertViewShowWithTitle:@"获取设备信息失败" andMessage:[error localizedDescription]];
        //        NSLog(@"errorInfo:%@",[error userInfo]);
    }];
}

- (void)alertViewShowWithTitle:(NSString*)string andMessage:(NSString*)message
{
    UIAlertView *setError = [[UIAlertView alloc] initWithTitle:string
                                                       message:message
                                                      delegate:nil
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:nil, nil];
    [setError show];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
