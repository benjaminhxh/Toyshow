//
//  AudioVideoViewController.m
//  Joyshow
//
//  Created by zhxf on 14-7-16.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "AudioVideoViewController.h"
#import "NSString+encodeChinese.h"

@interface AudioVideoViewController ()<MBProgressHUDDelegate>
{
    UISwitch *audioSw;
    UITextField *streamF;
    UISegmentedControl *flipImageSeg,*ntscOrPalSeg,*iMainStreamUserOptionSeg,*imageResolutionSeg,*iStreamFpsSeg;
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
    scrollView.showsVerticalScrollIndicator = NO;
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
    
    UILabel *iMainStreamL = [[UILabel alloc] init];
    iMainStreamL.text = @"清晰度";
    [scrollView addSubview:iMainStreamL];
    
    UIView *lineV5 = [[UIView alloc] init];
    lineV5.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineV5];

    NSArray *flipArr = [NSArray arrayWithObjects:@"正常",@"倒置", nil];
    flipImageSeg = [[UISegmentedControl alloc] initWithItems:flipArr];
    flipImageSeg.frame = CGRectMake(160, 65, 150, 31);
    flipImageSeg.selectedSegmentIndex = self.flipImageIndex;
    
    NSArray *ntscArr = [NSArray arrayWithObjects:@"NTSC",@"PAL", nil];
    ntscOrPalSeg = [[UISegmentedControl alloc] initWithItems:ntscArr];
    ntscOrPalSeg.frame = CGRectMake(160, 100, 150, 31);
    ntscOrPalSeg.selectedSegmentIndex = self.ntscOrPalIndex-1;
    
    streamF = [[UITextField alloc] initWithFrame:CGRectMake(kWidth/3, 447, 160, 31)];
    streamF.text = self.streamIndex;
    streamF.keyboardType = UIKeyboardTypeNumberPad;
    //    streamF.borderStyle = UITextBorderStyleBezel;
    streamF.textAlignment = NSTextAlignmentRight;
    if (self.isLow) {
        //低端设备
        iMainStreamL.frame = CGRectMake(15, 65, 110, 31);
        lineV5.frame = CGRectMake(15, 150, kWidth-30, 0.5);
        
        NSArray *iMainStreamUserOptionArr = [NSArray arrayWithObjects:@"720P",@"标清",@"流畅", nil];
        iMainStreamUserOptionSeg = [[UISegmentedControl alloc] initWithItems:iMainStreamUserOptionArr];
        iMainStreamUserOptionSeg.frame = CGRectMake(5, 100, 310, 41);
        iMainStreamUserOptionSeg.selectedSegmentIndex = self.iMainStreamUserOption-1;
        [iMainStreamUserOptionSeg addTarget:self action:@selector(iMainStreamUserOptionSegAction:) forControlEvents:UIControlEventValueChanged];
        [scrollView addSubview:iMainStreamUserOptionSeg];

    }else
    {
        //高端设备
        UILabel *flipImageV = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, 110, 31)];
        flipImageV.text = @"画面方向";
        [scrollView addSubview:flipImageV];

        [scrollView addSubview:flipImageSeg];
        
        UIView *lineV3 = [[UIView alloc] initWithFrame:CGRectMake(15, 97, kWidth-30, 0.5)];
        lineV3.backgroundColor = [UIColor grayColor];
        [scrollView addSubview:lineV3];
        
        UILabel *ntscOrPalL = [[UILabel alloc] initWithFrame:CGRectMake(15, 100, 110, 31)];
        ntscOrPalL.text = @"视频制式";
        [scrollView addSubview:ntscOrPalL];
        [scrollView addSubview:ntscOrPalSeg];
        
        UITextView *ntscTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 135, kWidth-20, 40)];
        ntscTextView.textColor = [UIColor grayColor];
        ntscTextView.editable = NO;
        ntscTextView.font = [UIFont systemFontOfSize:12];
        ntscTextView.text = @"NTSC制式常用于日本、美国、加拿大和墨西哥等国家,PAL制式主要用于中国、香港中东地区和欧洲一带";
        ntscTextView.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:ntscTextView];
        
        UIView *lineV4 = [[UIView alloc] initWithFrame:CGRectMake(15, 176, kWidth-30, 0.5)];
        lineV4.backgroundColor = [UIColor grayColor];
        [scrollView addSubview:lineV4];
        
        NSArray *iMainStreamUserOptionArr = [NSArray arrayWithObjects:@"1080P",@"720P",@"标清",@"流畅", nil];
        iMainStreamL.frame = CGRectMake(15, 180, 110, 31);//清晰度
        iMainStreamUserOptionSeg = [[UISegmentedControl alloc] initWithItems:iMainStreamUserOptionArr];
        iMainStreamUserOptionSeg.frame = CGRectMake(10, 215, kWidth-20, 41);
        iMainStreamUserOptionSeg.selectedSegmentIndex = self.iMainStreamUserOption-1;
        [iMainStreamUserOptionSeg addTarget:self action:@selector(iMainStreamUserOptionSegAction:) forControlEvents:UIControlEventValueChanged];
        [scrollView addSubview:iMainStreamUserOptionSeg];
        
        UITextView *imageResoluTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 256, kWidth-20, 76)];
        imageResoluTextView.editable = NO;
        imageResoluTextView.font = [UIFont systemFontOfSize:12];
        imageResoluTextView.text = @"1080P建议在10M以上带宽下使用，默认1M上行码流,720P建议在4M以上带宽下使用，默认768k上行码流,标清建议在2M以上带宽下使用，默认512k上行码流，流畅建议在1M以上带宽下使用，默认256k上行码流";
        imageResoluTextView.textColor = [UIColor grayColor];
        imageResoluTextView.scrollEnabled = NO;
        [scrollView addSubview:imageResoluTextView];
         
        lineV5.frame = CGRectMake(15, 333, kWidth-30, 0.5);
        
        //高级设置
        UILabel *customerSetL = [[UILabel alloc] initWithFrame:CGRectMake(10, 335, kWidth-20, 31)];
        customerSetL.text = @"高级设置(建议熟悉音视频设置的用户选择)";
        customerSetL.backgroundColor = [UIColor grayColor];
        [scrollView addSubview:customerSetL];
        UIView *lineV6 = [[UIView alloc] initWithFrame:CGRectMake(10, 370, kWidth-20, 0.5)];
        [scrollView addSubview:lineV6];
        
        //图像分辨率
        UILabel *imageResolutionLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 371, 90, 31)];
        imageResolutionLab.text = @"图像分辨率";
        [scrollView addSubview:imageResolutionLab];
        NSArray *imageResolutionArr = [NSArray arrayWithObjects:@"1080P",@"720P",@"4CIF",@"CIF", nil];
        imageResolutionSeg = [[UISegmentedControl alloc] initWithItems:imageResolutionArr];
        imageResolutionSeg.frame = CGRectMake(10, 405, kWidth-20, 41);
        imageResolutionSeg.selectedSegmentIndex = self.iMainStreamUserOptionIndex-1;
        [imageResolutionSeg addTarget:self action:@selector(imageResolutionSegAction:) forControlEvents:UIControlEventValueChanged];
        [scrollView addSubview:imageResolutionSeg];
        
        UIView *lineV7 = [[UIView alloc] initWithFrame:CGRectMake(15, 446, kWidth-30, 0.5)];
        lineV7.backgroundColor = [UIColor grayColor];
        [scrollView addSubview:lineV7];
        
        //视频码流
        UILabel *streamL = [[UILabel alloc] initWithFrame:CGRectMake(15, 447, 110, 31)];
        streamL.text = @"视频码流";
        [scrollView addSubview:streamL];
        [scrollView addSubview:streamF];
        UILabel *streamUnitL = [[UILabel alloc] initWithFrame:CGRectMake(kWidth-50, 447, 40, 31)];
        streamUnitL.text = @"kb/s";
        [scrollView addSubview:streamUnitL];
        
        UIView *lineV8 = [[UIView alloc] initWithFrame:CGRectMake(15, 478, kWidth-30, 0.5)];
        lineV8.backgroundColor = [UIColor grayColor];
        [scrollView addSubview:lineV8];
        //视频帧率4/8/12/16/20/24/28
        UILabel *fpsL = [[UILabel alloc] initWithFrame:CGRectMake(15, 480, 120, 31)];
        fpsL.text = @"视频帧率(帧/秒)";
        fpsL.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:fpsL];
        
        NSArray *streamFpsArr = [NSArray arrayWithObjects:@"4",@"8",@"12",@"16",@"20",@"24",@"28", nil];
        iStreamFpsSeg = [[UISegmentedControl alloc] initWithItems:streamFpsArr];
        iStreamFpsSeg.frame = CGRectMake(10, 511, kWidth-20, 31);
        [iStreamFpsSeg addTarget:self action:@selector(streamFpsSegAction:) forControlEvents:UIControlEventValueChanged];
        
        [scrollView addSubview:iStreamFpsSeg];
        
    }
}

- (void)iMainStreamUserOptionSegAction:(id)sender
{
    switch (iMainStreamUserOptionSeg.selectedSegmentIndex) {
        case 0:
            streamF.text = @"1024";
            break;
        case 1:
            streamF.text = @"768";
            break;
        case 2:
            streamF.text = @"512";
            break;
        case 3:
            streamF.text = @"256";
            break;
        default:
            break;
    }
}

- (void)imageResolutionSegAction:(id)sender
{
    
}

- (void)streamFpsSegAction:(id)sender
{
    
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

- (void)finishAction:(id)sender
{
    BOOL flagg = [self isLegalNum:128 to:2000 withNumString:streamF.text];
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
                                       [NSNumber numberWithInteger:iMainStreamUserOptionSeg.selectedSegmentIndex+1],@"iImageResolution",nil];

//                                       [NSNumber numberWithInteger:iMainStreamUserOptionSeg.selectedSegmentIndex+1],@"iMainStreamUserOption",nil];
    NSString *setCameraDataString = [setCameraDataDict JSONString];
    NSString *strWithUTF8 = [setCameraDataString encodeChinese];
//    NSString *strWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)setCameraDataString, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
