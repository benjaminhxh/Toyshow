//
//  DeviceInfoViewController.m
//  Joyshow
//
//  Created by zhxf on 14-7-16.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "DeviceInfoViewController.h"

@interface DeviceInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    NSArray *deviceInfoArr;
}
@end

@implementation DeviceInfoViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *background = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    background.userInteractionEnabled = YES;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 95, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"设备信息" forState:UIControlStateNormal];
    [topView addSubview:backBtn];

    deviceInfoArr = [NSArray arrayWithObjects:@"设备ID",@"设备类型",@"管理软件",@"采集软件",@"传输软件",@"MAC地址",@"WiFi IP地址",@"AP IP地址",@"发布日期",@"视频频道",@"音频频道",@"报警输入",@"报警输出",@"WiFi通道数", nil];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backAction:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_tableView addGestureRecognizer:recognizer];

}

- (void)backAction:(id)sender
{
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 14;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdent;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdent];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, kWidth, 44)];
        cell.textLabel.text = [deviceInfoArr objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *infoL = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 130, 24)];
//        infoL.text = [deviceInfoArr objectAtIndex:indexPath.row];
        switch (indexPath.row) {
            case 0:
                infoL.text = [self.deviceInfoDict objectForKey:@"i64DeviceId"];
                break;
            case 1:
                infoL.text = [self.deviceInfoDict objectForKey:@"strDeviceType"];
                break;
            case 2:
                infoL.text = [self.deviceInfoDict objectForKey:@"strManagerVersion"];
                break;
            case 3:
                infoL.text = [self.deviceInfoDict objectForKey:@"strCapturerVersion"];
                break;
            case 4:
                infoL.text = [self.deviceInfoDict objectForKey:@"strClientVersion"];
                break;
            case 5:
                infoL.text = [self.deviceInfoDict objectForKey:@"strMacAddr"];
                break;
            case 6:
                infoL.text = [self.deviceInfoDict objectForKey:@"strStationIpAddr"];
                break;
            case 7:
                infoL.text = [self.deviceInfoDict objectForKey:@"strAPIpAddr"];
                break;
            case 8:
            {
                int stf = [[self.deviceInfoDict objectForKey:@"i64ReleaseDate"] intValue];
                NSDate *currentTime = [NSDate dateWithTimeIntervalSince1970:stf];
                infoL.text = [[self dateFormateAlltime] stringFromDate:currentTime];
            }
                break;
            case 9:
                infoL.text = [self.deviceInfoDict objectForKey:@"iVideoChannelNum"];
                break;
            case 10:
                infoL.text = [self.deviceInfoDict objectForKey:@"iAudioChannelNum"];
                break;
            case 11:
                infoL.text = [self.deviceInfoDict objectForKey:@"iAlarmInNum"];
                break;
            case 12:
                infoL.text = [self.deviceInfoDict objectForKey:@"iAlarmOutNum"];
                break;
            case 13:
                infoL.text = [self.deviceInfoDict objectForKey:@"iWiFiChannelNum"];
                break;
            default:
                break;
        }
        infoL.textColor = [UIColor grayColor];
        infoL.textAlignment = NSTextAlignmentRight;
        [cell addSubview:infoL];
    }
    return cell;
}

- (NSDateFormatter *)dateFormateAlltime
{
    NSDateFormatter *dateFormate = [[NSDateFormatter alloc] init];
    [dateFormate setDateFormat:@"yyyy-MM-dd"];
    return dateFormate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
