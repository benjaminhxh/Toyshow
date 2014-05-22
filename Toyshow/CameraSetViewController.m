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

@interface CameraSetViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSArray *_listArr,*_cellImageArr,*_cellHightLightArr;
    BOOL nightFlag;
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

//    seeVideoBtn.backgroundColor = [UIColor blackColor];
    seeVideoBtn.frame = CGRectMake(kWidth-65, [UIApplication sharedApplication].statusBarFrame.size.height+2, 55, 35);
    [seeVideoBtn setTitle:@"看录像" forState:UIControlStateNormal];
    [seeVideoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [seeVideoBtn setBackgroundImage:[UIImage imageNamed:@"lishijilu@2x"] forState:UIControlStateNormal];
//    [seeVideoBtn setImage:[UIImage imageNamed:@"lishijilu@2x"] forState:UIControlStateNormal];
    [seeVideoBtn addTarget:self action:@selector(didSeeVideoClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:seeVideoBtn];
    
    _listArr = [NSArray arrayWithObjects:@"看录像",@"夜间模式",@"定时开关机",@"清晰度设置",@"音频设置",@"修改名称",@"注销设备", nil];
    _cellImageArr = [NSArray arrayWithObjects:@"qingxidu_h@2x",@"yejian_h@2x",@"dingshi_h@2x",@"qingxidu_h@2x",@"yinpin_h@2x",@"xiugai_h@2x",@"tuichudenglu@2x", nil];
    _cellHightLightArr = [NSArray arrayWithObjects:@"qingxidu_b@2x",@"yejian_b@2x",@"dingshi_b",@"qingxidu_b@2x",@"yinpin_b@2x",@"xiugai_b@2x",@"tuichudenglu@2x", nil];

    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 320, [UIScreen mainScreen].bounds.size.height-64) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
//    tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    
}

- (void)backBtn:(id)sender
{
    [[SliderViewController sharedSliderController] leftItemClick];
}

- (void)didSeeVideoClick
{
    NSLog(@"history");
}

#pragma mark - tableviewDeegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_listArr.count) {
        return _listArr.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentif = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentif];
    if (nil == cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentif];
        cell = [[[NSBundle mainBundle] loadNibNamed:@"cameraSet" owner:self options:nil] lastObject];
//        UIImageView *cellimageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 10, 8)];
//        cellimageView.image = [UIImage imageNamed:[_cellImageArr objectAtIndex:indexPath.row]];
//        cellimageView.contentMode = UIViewContentModeScaleAspectFit;
//        cell.imageView.image = cellimageView.image;
//        cell.imageView.image = [UIImage imageNamed:[_cellImageArr objectAtIndex:indexPath.row]];
//        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.cellImage.image = [UIImage imageNamed:[_cellImageArr objectAtIndex:indexPath.row]];
        self.cellImage.highlightedImage = [UIImage imageNamed:[_cellHightLightArr objectAtIndex:indexPath.row]];
        self.cellLabelT.text = [_listArr objectAtIndex:indexPath.row];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        UIImageView *cellView = [[UIImageView alloc] initWithFrame:cell.frame];
        cellView.image = [UIImage imageNamed:@"xuanzhongtiao1@2x"];
        cell.selectedBackgroundView = cellView;
    }
    if (1 == indexPath.row) {
        UISwitch *switchNo = [[UISwitch alloc] initWithFrame:CGRectMake(260,16,51,31)];
        switchNo.on = NO;
//        [switchNo setOn:YES animated:YES];
        [switchNo addTarget:self action:@selector(nightOrDay) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:switchNo];
    }
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            
            break;
        case 1:
            
            break;
        case 2:
            
            break;
        case 3:
            
            break;
        case 4:
            
            break;

        case 5:
        {
            ModifyViewController *modifyVC = [[ModifyViewController alloc] init];
            modifyVC.deviceId = @"123456";
            modifyVC.deviceName = @"中和讯飞";
            modifyVC.accessToken = @"1382750198753014";
            [[SliderViewController sharedSliderController].navigationController pushViewController:modifyVC animated:YES];
        }
            break;
        case 6:
            //注销设备
        {
            UIAlertView *logOutView = [[UIAlertView alloc] initWithTitle:@"注销设备？" message:@"确定要注销设备吗？注销之后该设备的录像等信息将全部被清除" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            logOutView.delegate = self;
            [logOutView show];
        }
            break;
        default:
            break;
    }
}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (0 == indexPath.row) {
//        return NO;
//    }
//    return YES;
//}

//强制不允许转屏
//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
//}
//
//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}

- (void)nightOrDay
{
    if (nightFlag) {
        NSLog(@"00000000000000");
    }else{
        NSLog(@"11111111111111");
    }
    nightFlag = !nightFlag;
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        NSLog(@"注销设备了");
        NSString *urlStr = @"https://pcs.baidu.com/rest/2.0/pcs/device?method=drop&deviceid=123456&access_token= b778fb598c717c0ad7ea8c97c8f3a46f";
        NSURL *url = [NSURL URLWithString:urlStr];
        [[SliderViewController sharedSliderController] leftItemClick];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
