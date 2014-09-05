//
//  AudioVideoViewController.m
//  Joyshow
//
//  Created by zhxf on 14-7-16.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "AudioVideoViewController.h"

@interface AudioVideoViewController ()<MBProgressHUDDelegate>
{
    UISwitch *audioSw;
    UITextField *streamF;
    UISegmentedControl *flipImageSeg,*ntscOrPalSeg,*imageResolutionSeg;
    MBProgressHUD *_progressView;
}
@end

@implementation AudioVideoViewController

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
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 64)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 25, 118, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"音视频设置" forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backAction:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];

    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    saveBtn.frame = CGRectMake(kWidth-65, 25-5, 55, 35);
    [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"lishijilu@2x"] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(finishAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:saveBtn];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64)];
    scrollView.contentSize = CGSizeMake(kWidth, kHeight);
    [self.view addSubview:scrollView];
    
    UILabel *audioL = [[UILabel alloc] initWithFrame:CGRectMake(15, 11, 110, 31)];
    audioL.text = @"音频输入开关";
    [scrollView addSubview:audioL];
    
    audioSw = [[UISwitch alloc] initWithFrame:CGRectMake(240, 11, 51, 31)];
    audioSw.on = self.audioIndex;
    //    [statueSw addTarget:self action:@selector(openOrClose:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:audioSw];
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(15, 54, kWidth-30, 0.5)];
    lineV.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineV];
    

    UILabel *streamL = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, 110, 31)];
    streamL.text = @"视频码流";
    [scrollView addSubview:streamL];
    
    streamF = [[UITextField alloc] initWithFrame:CGRectMake(kWidth/3, 65, 160, 31)];
    streamF.text = self.streamIndex;
    streamF.keyboardType = UIKeyboardTypeNumberPad;
//    streamF.borderStyle = UITextBorderStyleBezel;
    streamF.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:streamF];
    UILabel *streamUnitL = [[UILabel alloc] initWithFrame:CGRectMake(270, 65, 40, 31)];
    streamUnitL.text = @"kb/s";
    [scrollView addSubview:streamUnitL];
    
    UIView *lineV2 = [[UIView alloc] initWithFrame:CGRectMake(15, 108, kWidth-30, 0.5)];
    lineV2.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineV2];
    
    UILabel *flipImageV = [[UILabel alloc] initWithFrame:CGRectMake(15, 119, 110, 31)];
    flipImageV.text = @"画面方向";
    [scrollView addSubview:flipImageV];
    
    NSArray *flipArr = [NSArray arrayWithObjects:@"正常",@"倒置", nil];
    flipImageSeg = [[UISegmentedControl alloc] initWithItems:flipArr];
    flipImageSeg.frame = CGRectMake(160, 119, 150, 31);
    flipImageSeg.selectedSegmentIndex = self.flipImageIndex;
    [scrollView addSubview:flipImageSeg];
    
    UIView *lineV3 = [[UIView alloc] initWithFrame:CGRectMake(15, 161, kWidth-30, 0.5)];
    lineV3.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineV3];

    UILabel *ntscOrPalL = [[UILabel alloc] initWithFrame:CGRectMake(15, 172, 110, 31)];
    ntscOrPalL.text = @"视频制式";
    [scrollView addSubview:ntscOrPalL];
    
    NSArray *ntscArr = [NSArray arrayWithObjects:@"NTSC",@"PAL", nil];
    ntscOrPalSeg = [[UISegmentedControl alloc] initWithItems:ntscArr];
    ntscOrPalSeg.frame = CGRectMake(160, 172, 150, 31);
    ntscOrPalSeg.selectedSegmentIndex = self.ntscOrPalIndex-1;
    [scrollView addSubview:ntscOrPalSeg];

    
    UIView *lineV4 = [[UIView alloc] initWithFrame:CGRectMake(15, 214, kWidth-30, 0.5)];
    lineV4.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineV4];

    UILabel *imageResolutionL = [[UILabel alloc] initWithFrame:CGRectMake(15, 225, 110, 31)];
    imageResolutionL.text = @"图像分辨率";
    [scrollView addSubview:imageResolutionL];
    
    NSArray *imageResolutionArr = [NSArray arrayWithObjects:@"1080P",@"720P",@"标清",@"流畅", nil];
    imageResolutionSeg = [[UISegmentedControl alloc] initWithItems:imageResolutionArr];
    imageResolutionSeg.frame = CGRectMake(5, 260, 310, 41);
    imageResolutionSeg.selectedSegmentIndex = self.imageResolutionIndex-1;
    [scrollView addSubview:imageResolutionSeg];
    
    
    UIView *lineV5 = [[UIView alloc] initWithFrame:CGRectMake(15, 310, kWidth-30, 0.5)];
    lineV5.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineV5];


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

- (void)finishAction:(id)sender
{
    BOOL flagg = [self isLegalNum:60 to:3600 withNumString:streamF.text];
    if (!flagg) {
        return;
    }
    [self.view endEditing:YES];
    [self isLoadingView];
    
    NSDictionary *setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInteger:audioSw.on ],@"iEnableAudioIn",
                                       streamF.text,@"iStreamBitrate",
                                       [NSNumber numberWithInteger:flipImageSeg.selectedSegmentIndex],@"iFlipImage",
                                       [NSNumber numberWithInteger:ntscOrPalSeg.selectedSegmentIndex+1],@"iNTSCPAL",
                                       [NSNumber numberWithInteger:imageResolutionSeg.selectedSegmentIndex+1],@"iImageResolution",nil];
    NSString *setCameraDataString = [setCameraDataDict JSONString];
    NSString *strWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)setCameraDataString, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    //
    NSString *setURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
//    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:@"control",@"method",self.access_token,@"access_token",self.deviceid,@"deviceid",setCameraDataDict,@"command", nil];
    ////NSLog(@"paramDict:%@",paramDict);
    [[AFHTTPRequestOperationManager manager]POST:setURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dict = (NSDictionary*)responseObject;
        ////NSLog(@"dict:%@",dict);
        _progressView.hidden = YES;
        [self alertViewShowWithTitle:@"设置成功" andMessage:nil];
        [self backToRootViewController];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _progressView.hidden = YES;
        [self alertViewShowWithTitle:@"设置失败" andMessage:nil];
    }];
//    [[AFHTTPSessionManager manager] POST:setURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSDictionary *dict = (NSDictionary*)responseObject;
//        ////NSLog(@"dict:%@",dict);
//        _progressView.hidden = YES;
//        [self alertViewShowWithTitle:@"设置成功" andMessage:nil];
//        [self backToRootViewController];
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        _progressView.hidden = YES;
//        [self alertViewShowWithTitle:@"设置失败" andMessage:nil];
//    }];
}

- (void)backAction:(id)sender
{
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

- (void)backToRootViewController
{
    [[SliderViewController sharedSliderController].navigationController popToRootViewControllerAnimated:YES];
}

- (void)isLoadingView
{
    if (_progressView == nil) {
        _progressView = [[MBProgressHUD alloc] initWithView:self.view];
        [_progressView show:YES];
        [self.view addSubview:_progressView];
        
        _progressView.delegate = self;
        _progressView.labelText = @"loading";
        _progressView.square = YES;
        _progressView.color = [UIColor grayColor];
        return;
    }
    [_progressView show:YES];
}

- (void)alertViewShowWithTitle:(NSString*)string andMessage:(NSString*)message
{
    UIAlertView *setError = [[UIAlertView alloc] initWithTitle:string
                                                       message:message
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
    [setError show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
