//
//  CameraSetViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-10.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "CameraSetViewController.h"
#import "ShareSetViewController.h"
#import "ThumbnailViewController.h"
#import "SceneModeViewController.h"
#import "NtscOrpalViewController.h"
#import "ImageResolutionViewController.h"
#import "DeviceControlViewController.h"
#import "SensitivityViewController.h"
#import "AddDeviceViewController.h"
#import "ManageAuthorViewController.h"

#import "AudioVideoViewController.h"
#import "NightViewController.h"
#import "EventNotificationViewController.h"
#import "DeviceStatueControlViewController.h"
#import "DeviceInfoViewController.h"
#import "ModifyViewController.h"
#import "NSString+encodeChinese.h"

@interface CameraSetViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,SceneModeViewControllerDelegate,NtscOrpalViewControllerDelegate,ImageResolutionViewControllerDelegate,DeviceControlViewControlDelegate,SensitivityViewControllerDelegate,MBProgressHUDDelegate>
{
    NSArray *cameraInfoArr,*cameraInfoArrLow;
    UIButton *codeStream;
    UILabel *deviceIDL,*deviceNameL;
    UIAlertView *codeStreamView,*logOutView;
    UILabel *scenceModeL,*cameraControlL,*sensitivityL,*ntscOrpalL,*imageResolutionL;
    UISwitch *iEnableEvent,*iScene,*iFlipImage,*iEnableAudioIn,*iEnableRecord,*iEnableDeviceStatusLed;
    MBProgressHUD *_loginoutView;
    NSDictionary *cameraInfoDict;
    int count;
    BOOL islow;
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
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 64)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 25, 120, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn setTitle:@"摄像头设置" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    UIButton *seeVideoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    seeVideoBtn.frame = CGRectMake(kWidth-75, 25-3, 65, 35);
    [seeVideoBtn setTitle:@"查看录像" forState:UIControlStateNormal];
    [seeVideoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [seeVideoBtn setBackgroundImage:[UIImage imageNamed:@"lishijilu@2x"] forState:UIControlStateNormal];
    [seeVideoBtn addTarget:self action:@selector(didSeeVideoClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:seeVideoBtn];
//    self.controlONOrOFFIndex = 3;
    cameraInfoArr = [NSArray arrayWithObjects:@"音视频设置",@"夜视功能设置",@"检测灵敏度",@"录像控制",@"状态指示灯",@"时间显示",@"设备信息", nil];
    cameraInfoArrLow = [NSArray arrayWithObjects:@"音视频设置",@"检测灵敏度",@"录像控制",@"状态指示灯",@"时间显示",@"设备信息", nil];
    if (self.isAuthorDevice) {
        UIButton *dropGrantBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        dropGrantBtn.frame = CGRectMake(kWidth/2-80, kHeight/2, 160, 60);
        [dropGrantBtn setTitle:@"放弃授权" forState:UIControlStateNormal];
        [dropGrantBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [dropGrantBtn setBackgroundImage:[UIImage imageNamed:@"kaishipeizhi_anniu@2x"] forState:UIControlStateNormal];
        [dropGrantBtn addTarget:self action:@selector(dropGrantClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:dropGrantBtn];
    }else
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kWidth, [UIScreen mainScreen].bounds.size.height-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        if (self.isOnline) {
            [self getDeviceInfo];
        }
    }
    

    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
}

- (void)backBtn:(id)sender
{
    _loginoutView.hidden = YES;
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

//放弃授权
- (void)dropGrantClick
{
    UIAlertView *dropDeviceV = [[UIAlertView alloc] initWithTitle:@"放弃授权之后该摄像头将不会出现在我的摄像头列表中，并且不能观看该摄像头的录像" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"放弃授权", nil];
    [dropDeviceV show];
}
//看录像，进入录像列表
- (void)didSeeVideoClick
{
    ////NSLog(@"录像列表");
    ThumbnailViewController *thumbVC = [[ThumbnailViewController alloc] init];
    thumbVC.deviceID = self.deviceid;
    thumbVC.accessToken = self.access_token;
    thumbVC.deviceDesc = self.deviceDesc;
    [[SliderViewController sharedSliderController].navigationController pushViewController:thumbVC animated:YES];
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return 2;
    }else if (1 == section)
    {
        return count;
    }
    else
    {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdent = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    switch (indexPath.section) {
        case 0:
        {
            if (cell==nil) {
                cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, kWidth, 44)];
                if (indexPath.row) {
                    cell.textLabel.text = @"查看录像";
                }else
                    cell.textLabel.text = @"分享设置";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
            break;
        case 1:
        {
            if (cell==nil) {
                cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, kWidth, 44)];
                if (islow) {
                    cell.textLabel.text = [cameraInfoArrLow objectAtIndex:indexPath.row];
                }else
                {
                    cell.textLabel.text = [cameraInfoArr objectAtIndex:indexPath.row];
                }
            }
            if (islow) {
                switch (indexPath.row) {
                    case 2:
                    {
                        //录像控制开关
                        videooffON = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
                        [cell addSubview:videooffON];
                        //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        self.videoRecordIndex = [[cameraInfoDict objectForKey:@"iEnableRecord"] integerValue];
                        videooffON.on = self.videoRecordIndex;
                        [videooffON addTarget:self action:@selector(VideoEventAction:) forControlEvents:UIControlEventTouchUpInside];
                    }
                        break;
                    case 3:
                    {
                        //状态指示灯
                        stateLightoffON = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
                        [cell addSubview:stateLightoffON];
                        self.lightStatueIndex = [[cameraInfoDict objectForKey:@"iEnableDeviceStatusLed"] integerValue];
                        
                        stateLightoffON.on = self.lightStatueIndex;
                        [stateLightoffON addTarget:self action:@selector(stateLightEventAction:) forControlEvents:UIControlEventTouchUpInside];
                        //                cell.detailTextLabel.text = @"设备状态指示灯是否开启";
                        
                    }
                        break;
                    case 4:
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
                        
                    default:
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        break;
                }
            }else
            {
                switch (indexPath.row) {
                    case 3:
                    {
                        //录像控制开关
                        videooffON = [[UISwitch alloc] initWithFrame:CGRectMake(245, 5, 51, 31)];
                        [cell addSubview:videooffON];
                        //            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        self.videoRecordIndex = [[cameraInfoDict objectForKey:@"iEnableRecord"] integerValue];
                        videooffON.on = self.videoRecordIndex;
                        [videooffON addTarget:self action:@selector(VideoEventAction:) forControlEvents:UIControlEventTouchUpInside];
                    }
                        break;
                    case 4:
                    {
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
                        
                    default:
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        break;
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        
        case 2:
        {
            if (cell==nil) {
                cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, kWidth, 44)];
                switch (indexPath.row) {
                    case 0:
                    {
                        //更换网络
                        cell.textLabel.text = @"管理授权用户";
                        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                        break;

                    case 1:
                    {
                        //修改设备名称
                        cell.textLabel.text = @"修改设备名称";
                        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        deviceNameL = [[UILabel alloc] initWithFrame:CGRectMake(150, 10, 140, 24)];
                        deviceNameL.text = self.deviceDesc;
                        deviceNameL.textAlignment = NSTextAlignmentRight;
                        deviceNameL.textColor = [UIColor grayColor];
                        [cell addSubview:deviceNameL];
                    }
                        break;
                    case 2:
                    {
                        //更换网络
                        cell.textLabel.text = @"设备更换网络";
                        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//                        deviceNameL = [[UILabel alloc] initWithFrame:CGRectMake(150, 10, 140, 24)];
//                        deviceNameL.text = self.deviceDesc;
//                        deviceNameL.textAlignment = NSTextAlignmentRight;
//                        deviceNameL.textColor = [UIColor grayColor];
//                        [cell addSubview:deviceNameL];
                    }
                        break;
                    case 3:
                    {
                        UIButton *loggout = [UIButton buttonWithType:UIButtonTypeCustom];
                        [loggout setTitle:@"注销设备" forState:UIControlStateNormal];
                        loggout.frame = CGRectMake(80, 2, 160, 40);
                        [loggout setBackgroundImage:[UIImage imageNamed:@"kaishipeizhi_anniu@2x"] forState:UIControlStateNormal];
                        //            loggout.backgroundColor = [UIColor blueColor];
                        [cell addSubview:loggout];
                        [loggout addTarget:self action:@selector(LoginOutAction:) forControlEvents:UIControlEventTouchUpInside];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row) {
                [self didSeeVideoClick];
            }else
            {
                ShareSetViewController *shareSetVC = [[ShareSetViewController alloc] init];
                shareSetVC.index = self.shareIndex;
                shareSetVC.deviceId = self.deviceid;
                shareSetVC.cameraName = self.deviceDesc;
                shareSetVC.accecc_token = self.access_token;
                [[SliderViewController sharedSliderController].navigationController pushViewController:shareSetVC animated:YES];
            }
        }
            break;
        case 1:
        {
            //低端
            if (islow) {
                switch (indexPath.row) {
                    case 0:
                    {
                        AudioVideoViewController *avideoVC = [[AudioVideoViewController alloc] init];
                        avideoVC.access_token = self.access_token;
                        avideoVC.deviceid = self.deviceid;
                        avideoVC.audioIndex = [[cameraInfoDict objectForKey:@"iEnableAudioIn"] integerValue];
                        avideoVC.streamIndex = [cameraInfoDict objectForKey:@"iStreamBitrate"];
                        avideoVC.iAudioVolIndex = [cameraInfoDict objectForKey:@"iAudioVol"];
                        avideoVC.iMainStreamUserOptionIndex = [[cameraInfoDict objectForKey:@"iMainStreamUserOption"] integerValue];
                        avideoVC.isLow = islow;
                        [[SliderViewController sharedSliderController].navigationController pushViewController:avideoVC animated:YES];
                    }
                        break;
//                    case 1:
//                    {
//                        NightViewController *nightVC = [[NightViewController alloc] init];
//                        nightVC.access_token = self.access_token;
//                        nightVC.deviceid = self.deviceid;
//                        nightVC.isenceIndex = [[cameraInfoDict objectForKey:@"iScene"] integerValue];
//                        nightVC.filterIndex = [[cameraInfoDict objectForKey:@"iLightFilterMode"] integerValue];
//                        [[SliderViewController sharedSliderController].navigationController pushViewController:nightVC animated:YES];
//                    }
//                        break;
                    case 1:
                    {
                        EventNotificationViewController *eventNotifVC = [[EventNotificationViewController alloc] init];
                        eventNotifVC.access_token = self.access_token;
                        eventNotifVC.deviceid = self.deviceid;
//                        eventNotifVC.eventNotifIndex = [[cameraInfoDict objectForKey:@"iEnableEvent"] integerValue];
                        eventNotifVC.sensityIndex = [[cameraInfoDict objectForKey:@"iObjDetectLevel"] integerValue];
                        [[SliderViewController sharedSliderController].navigationController pushViewController:eventNotifVC animated:YES];
                    }
                        break;
//                    case 5:
//                    {
//                        DeviceStatueControlViewController *statueControlVC = [[DeviceStatueControlViewController alloc] init];
//                        statueControlVC.access_token = self.access_token;
//                        statueControlVC.deviceid = self.deviceid;
//                        [[SliderViewController sharedSliderController].navigationController pushViewController:statueControlVC animated:YES];
//                    }
//                        break;
                    case 5:
                    {
                        DeviceInfoViewController *deviceInfoVC = [[DeviceInfoViewController alloc] init];
                        deviceInfoVC.deviceInfoDict = cameraInfoDict;
                        [[SliderViewController sharedSliderController].navigationController pushViewController:deviceInfoVC animated:YES];
                    }
                        break;
                    default:
                        break;
                }
            }
            else
            {
                //高端
                switch (indexPath.row) {
                    case 0:
                    {
                        AudioVideoViewController *avideoVC = [[AudioVideoViewController alloc] init];
                        avideoVC.access_token = self.access_token;
                        avideoVC.deviceid = self.deviceid;
                        avideoVC.audioIndex = [[cameraInfoDict objectForKey:@"iEnableAudioIn"] integerValue];
                        avideoVC.streamIndex = [cameraInfoDict objectForKey:@"iStreamBitrate"];
                        avideoVC.iAudioVolIndex = [cameraInfoDict objectForKey:@"iAudioVol"];
                        avideoVC.flipImageIndex = [[cameraInfoDict objectForKey:@"iFlipImage"] integerValue];
                        avideoVC.ntscOrPalIndex = [[cameraInfoDict objectForKey:@"iNTSCPAL"] integerValue];
                        avideoVC.iStreamFpsIndex = [[cameraInfoDict objectForKey:@"iStreamFps"] integerValue]/4-1;
                        avideoVC.iMainStreamUserOptionIndex = [[cameraInfoDict objectForKey:@"iMainStreamUserOption"] integerValue];
                        avideoVC.imageResolutionIndex = [[cameraInfoDict objectForKey:@"iImageResolution"] integerValue];

                        avideoVC.isLow = islow;
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
//                        eventNotifVC.eventNotifIndex = [[cameraInfoDict objectForKey:@"iEnableEvent"] integerValue];
                        eventNotifVC.sensityIndex = [[cameraInfoDict objectForKey:@"iObjDetectLevel"] integerValue];
                        [[SliderViewController sharedSliderController].navigationController pushViewController:eventNotifVC animated:YES];
                    }
                        break;
//                    case 6:
//                    {
//                        DeviceStatueControlViewController *statueControlVC = [[DeviceStatueControlViewController alloc] init];
//                        statueControlVC.access_token = self.access_token;
//                        statueControlVC.deviceid = self.deviceid;
//                        [[SliderViewController sharedSliderController].navigationController pushViewController:statueControlVC animated:YES];
//                    }
//                        break;
                    case 6:
                    {
                        DeviceInfoViewController *deviceInfoVC = [[DeviceInfoViewController alloc] init];
                        deviceInfoVC.deviceInfoDict = cameraInfoDict;
                        [[SliderViewController sharedSliderController].navigationController pushViewController:deviceInfoVC animated:YES];
                    }
                        break;
                    default:
                        break;
                }
            }

        }
            break;
        case 2:
        {
            switch (indexPath.row) {
                case 0:
                {
                    //管理授权用户
                    ManageAuthorViewController *manageAuthorVC = [[ManageAuthorViewController alloc] init];
                    manageAuthorVC.deviceID = self.deviceid;
                    [self.navigationController pushViewController:manageAuthorVC animated:YES];
                }
                    break;
                case 1:
                {
                    //修改设备名
                    ModifyViewController *modifyVC = [[ModifyViewController alloc] init];
                    modifyVC.deviceId = self.deviceid;
                    modifyVC.deviceName = self.deviceDesc;
                    modifyVC.accessToken = self.access_token;
                    //            modifyVC.delegate = self;
                    [[SliderViewController sharedSliderController].navigationController pushViewController:modifyVC animated:YES];
                }
                    break;
                case 2:
                {
                    //更换网络
                    AddDeviceViewController *exchangeNetVC = [[AddDeviceViewController alloc] init];
                    exchangeNetVC.isAddDevice = NO;
                    exchangeNetVC.access_token = self.access_token;
//                    [self.navigationController pushViewController:exchangeNetVC animated:YES];
                    [self presentViewController:exchangeNetVC animated:YES completion:nil];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//视频录制是否打开
- (void)VideoEventAction:(id)sender
{
    _loginoutView.hidden = NO;
    self.videoRecordIndex = videooffON.on;

    NSDictionary *setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInteger:self.videoRecordIndex],@"iEnableRecord",nil];
    NSString *setCameraDataString = [setCameraDataDict JSONString];
    NSString *strWithUTF8 = [setCameraDataString encodeChinese];

//    NSString *strWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)setCameraDataString, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *setURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
    [[AFHTTPRequestOperationManager manager] POST:setURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dict = (NSDictionary*)responseObject;
        ////NSLog(@"dict:%@",dict);
        videooffON.on = self.videoRecordIndex;
        _loginoutView.hidden = YES;
//        [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        videooffON.on = !self.videoRecordIndex;
        _loginoutView.hidden = YES;
        [self alertViewShowWithTitle:@"设置失败" andMessage:nil];
    }];
}

//设备状态指示灯
- (void)stateLightEventAction:(id)sender
{
    ////NSLog(@"状态指示灯");
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
    NSString *strWithUTF8 = [setCameraDataString encodeChinese];

//    NSString *strWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)setCameraDataString, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *setURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
    [[AFHTTPRequestOperationManager manager] POST:setURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dict = (NSDictionary*)responseObject;
        ////NSLog(@"dict:%@",dict);
        stateLightoffON.on = self.lightStatueIndex;
        _loginoutView.hidden = YES;
//        [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        stateLightoffON.on = !self.lightStatueIndex;
        _loginoutView.hidden = YES;
        [self alertViewShowWithTitle:@"设置失败" andMessage:nil];
    }];

}

//是否在界面上显示时间
- (void)timeHiddenEventAction:(id)sender
{
    _loginoutView.hidden = NO;

    self.timeShowIndex = timeHidden.on;
    NSDictionary *setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInteger:self.timeShowIndex],@"iEnableOSDTime",nil];
    NSString *setCameraDataString = [setCameraDataDict JSONString];
    NSString *strWithUTF8 = [setCameraDataString encodeChinese];

//    NSString *strWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)setCameraDataString, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSString *setURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
    [[AFHTTPRequestOperationManager manager] POST:setURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dict = (NSDictionary*)responseObject;
        ////NSLog(@"dict:%@",dict);
        timeHidden.on = self.timeShowIndex;
        _loginoutView.hidden = YES;
//        [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        timeHidden.on = !self.timeShowIndex;
        _loginoutView.hidden = YES;
        [self alertViewShowWithTitle:@"设置失败" andMessage:nil];
    }];
}

//注销设备
- (void)LoginOutAction:(id)sender
{
    logOutView = [[UIAlertView alloc] initWithTitle:@"注销设备？" message:@"确定要注销设备吗？注销之后该设备的录像等信息将全部被清除" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"注销", nil];
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
//    self.controlONOrOFFIndex = index;
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
    }else
    {
        //取消授权
        if (buttonIndex) {
            _loginoutView.hidden = NO;
            NSString *dropGrantURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=dropgrantdevice&access_token=%@&deviceid=%@",self.access_token,self.deviceid];
            [[AFHTTPRequestOperationManager manager] GET:dropGrantURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(logoutCameraAtindex:)]) {
                    [self.delegate logoutCameraAtindex:100];
                }
                [self backBtn:nil];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                _loginoutView.hidden = YES;
                UIAlertView *failV = [[UIAlertView alloc] initWithTitle:@"放弃授权失败" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
                [failV show];
            }];
        }
    }
}

#pragma mark - logoutMyCamera
- (void)logoutMyCamera
{
    //注销设备
    [self isLoadingView];
    _loginoutView.mode = 0;
    _loginoutView.labelText = @"注销中……";
    _loginoutView.hidden = NO;
    //发通道消息注销
    NSDictionary *dropCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"1",@"iDeregisterDevice",nil];//注销
    NSString *dropCameraDataString = [dropCameraDataDict JSONString];
    NSString *dropstrWithUTF8 = [dropCameraDataString encodeChinese];
    //
    NSString *dropControlURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,dropstrWithUTF8];
    NSString *dropToServerurl = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=drop&deviceid=%@&access_token=%@",self.deviceid,self.access_token];

    [[AFHTTPRequestOperationManager manager]POST:dropControlURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //服务器注销
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        _loginoutView.mode = 4;
//        _loginoutView.labelText = @"注销失败";
//        [_loginoutView hide:YES];

    }];
    sleep(2);
    //延迟1S去服务器注销
    [[AFHTTPRequestOperationManager manager] POST:dropToServerurl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSDictionary *dict = (NSDictionary *)responseObject;
        //        NSString *deviceID = [dict objectForKey:@"deviceid"];
        ////NSLog(@"deviceid:%@",deviceID);
        if (self.delegate && [self.delegate respondsToSelector:@selector(logoutCameraAtindex:)]) {
            [self.delegate logoutCameraAtindex:self.index];
        }
        _loginoutView.mode = 4;
        _loginoutView.labelText = @"注销成功";
        [_loginoutView hide:YES];
        
        [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
        [self alertViewShowWithTitle:@"注销成功" andMessage:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        NSDictionary *errorDict = [error userInfo];
        //        NSString *errorMSG = [errorDict objectForKey:@"error_msg"];
        ////NSLog(@"erroeMSG:%@",errorMSG);
        _loginoutView.mode = 4;
        _loginoutView.labelText = @"注销失败";
        [_loginoutView hide:YES];
        [self alertViewShowWithTitle:@"注销失败" andMessage:nil];
    }];

}

//判断输入的值是否介于两者之间
- (BOOL)isLegalNum:(int)startNum to:(int)endNum withNumString:(NSString *)numString
{
    int bandw = [numString intValue];
    if (bandw >= startNum && bandw <= endNum) {
        return YES;
    }else{
        UIAlertView *errorV = [[UIAlertView alloc] initWithTitle:@"错误" message:[NSString stringWithFormat:@"带宽值应该设为%d-%dkb/s",startNum,endNum] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
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
//    ////NSLog(@"requestStr:%@",requestStr);
    NSString *strWithUTF8 = [requestStr encodeChinese];

//    NSString *strWithUTF8 = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)requestStr, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));

    NSString *getInfoURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
    ////NSLog(@"getInfoURL:%@",getInfoURL);
    [[AFHTTPRequestOperationManager manager] POST:getInfoURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary*)responseObject;
        NSArray *arr = [dict objectForKey:@"data"];
        NSDictionary *userData = [arr lastObject];
        //        ////NSLog(@"userData:%@",userData);
        NSString *userDataString = [userData objectForKey:@"userData"];
        ////NSLog(@"userDataDict:%@",userDataString);
        NSData *resData = [[NSData alloc] initWithData:[userDataString dataUsingEncoding:NSUTF8StringEncoding]];
        //系统自带JSON解析
        cameraInfoDict = [NSDictionary dictionary];
        cameraInfoDict = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
        NSString *deviceID = [cameraInfoDict objectForKey:@"i64DeviceId"];
        long long deviceidlong = [deviceID longLongValue];
        //左移48位，得到为0为高端设备，1为低端设备
        islow = (deviceidlong >> 48);
        if (islow) {
            count = cameraInfoArrLow.count;
        }else
        {
            count = cameraInfoArr.count;
        }
        _loginoutView.hidden = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _loginoutView.hidden = YES;
        [self alertViewShowWithTitle:@"获取设备信息失败" andMessage:[error localizedDescription]];
        //        ////NSLog(@"errorInfo:%@",[error userInfo]);
    }];
}

- (void)alertViewShowWithTitle:(NSString*)string andMessage:(NSString*)message
{
    UIAlertView *setError = [[UIAlertView alloc] initWithTitle:string
                                                       message:message
                                                      delegate:nil
                                             cancelButtonTitle:@"好"
                                             otherButtonTitles:nil, nil];
    [setError show];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
