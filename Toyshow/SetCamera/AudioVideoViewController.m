//
//  AudioVideoViewController.m
//  Joyshow
//
//  Created by zhxf on 14-7-16.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "AudioVideoViewController.h"
#import "NSString+encodeChinese.h"

@interface AudioVideoViewController ()<MBProgressHUDDelegate,UITextFieldDelegate>
{
    UISwitch *audioSw,*customerSetSw;
    UITextField *streamF,*audioVolF;
    UISegmentedControl *flipImageSeg,*ntscOrPalSeg,*iMainStreamUserOptionSeg,*imageResolutionSeg,*iStreamFpsSeg;
    MBProgressHUD *_progressView;
    UIScrollView *scrollView;
    NSArray *streamFpsArr;
    UIView *customerView;
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
//6228481710873829819
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
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64)];
    scrollView.contentSize = CGSizeMake(kWidth, 800);
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    UILabel *audioL = [[UILabel alloc] initWithFrame:CGRectMake(15, 11, 110, 31)];
    audioL.text = @"音频输入开关";
    [scrollView addSubview:audioL];
    
    audioSw = [[UISwitch alloc] initWithFrame:CGRectMake(kWidth-80, 11, 51, 31)];
    audioSw.on = self.audioIndex;
    //    [statueSw addTarget:self action:@selector(openOrClose:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:audioSw];
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(15, 54, kWidth-30, 0.5)];
    lineV.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineV];
    
    //相机音量
    UILabel *audioVolL = [[UILabel alloc] initWithFrame:CGRectMake(15, 65, 130, 31)];
    audioVolL.text = @"相机音量(0--100)";
    [scrollView addSubview:audioVolL];
    
    audioVolF = [[UITextField alloc] initWithFrame:CGRectMake(kWidth-170, 65, 150, 31)];
    audioVolF.keyboardType = UIKeyboardTypeNumberPad;
    audioVolF.text = self.iAudioVolIndex;
    audioVolF.textAlignment = NSTextAlignmentRight;
    [scrollView addSubview:audioVolF];
    
    UIView *lineV2 = [[UIView alloc] initWithFrame:CGRectMake(15, 107, kWidth-30, 0.5)];
    lineV2.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineV2];
    
    UILabel *iMainStreamL = [[UILabel alloc] init];
    iMainStreamL.text = @"清晰度";
    [scrollView addSubview:iMainStreamL];
    
    UIView *lineV5 = [[UIView alloc] init];
    lineV5.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineV5];

    NSArray *flipArr = [NSArray arrayWithObjects:@"正常",@"倒置", nil];
    flipImageSeg = [[UISegmentedControl alloc] initWithItems:flipArr];
    flipImageSeg.frame = CGRectMake(160, 118, 150, 31);
    flipImageSeg.selectedSegmentIndex = self.flipImageIndex;
    
    NSArray *ntscArr = [NSArray arrayWithObjects:@"NTSC",@"PAL", nil];
    ntscOrPalSeg = [[UISegmentedControl alloc] initWithItems:ntscArr];
    ntscOrPalSeg.frame = CGRectMake(160, 171, 150, 31);
    ntscOrPalSeg.selectedSegmentIndex = self.ntscOrPalIndex-1;
    
    if (self.isLow) {
        //低端设备
        iMainStreamL.frame = CGRectMake(15, 118, 110, 31);
        lineV5.frame = CGRectMake(15, 150, kWidth-30, 0.5);
        
        NSArray *iMainStreamUserOptionArr = [NSArray arrayWithObjects:@"720P",@"标清",@"流畅", nil];
        iMainStreamUserOptionSeg = [[UISegmentedControl alloc] initWithItems:iMainStreamUserOptionArr];
        iMainStreamUserOptionSeg.frame = CGRectMake(5, 153, 310, 41);
        iMainStreamUserOptionSeg.selectedSegmentIndex = self.iMainStreamUserOptionIndex-1;
        [iMainStreamUserOptionSeg addTarget:self action:@selector(iMainStreamUserOptionSegAction:) forControlEvents:UIControlEventValueChanged];
        [scrollView addSubview:iMainStreamUserOptionSeg];

    }else
    {
        //高端设备
        UILabel *flipImageV = [[UILabel alloc] initWithFrame:CGRectMake(15, 118, 110, 31)];
        flipImageV.text = @"画面方向";
        [scrollView addSubview:flipImageV];

        [scrollView addSubview:flipImageSeg];
        
        UIView *lineV3 = [[UIView alloc] initWithFrame:CGRectMake(15, 165, kWidth-30, 0.5)];
        lineV3.backgroundColor = [UIColor grayColor];
        [scrollView addSubview:lineV3];
        
        UILabel *ntscOrPalL = [[UILabel alloc] initWithFrame:CGRectMake(15, 171, 110, 31)];
        ntscOrPalL.text = @"视频制式";
        [scrollView addSubview:ntscOrPalL];
        [scrollView addSubview:ntscOrPalSeg];
        
        UITextView *ntscTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 203, kWidth-20, 40)];
        ntscTextView.textColor = [UIColor grayColor];
        ntscTextView.editable = NO;
        ntscTextView.font = [UIFont systemFontOfSize:12];
        ntscTextView.scrollEnabled = NO;
        ntscTextView.text = @"NTSC制式常用于日本、美国、加拿大和墨西哥等国家,PAL制式主要用于中国、香港中东地区和欧洲一带";
        ntscTextView.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:ntscTextView];
        
        UIView *lineV4 = [[UIView alloc] initWithFrame:CGRectMake(15, 253, kWidth-30, 0.5)];
        lineV4.backgroundColor = [UIColor grayColor];
        [scrollView addSubview:lineV4];
        
        //清晰度
        NSArray *iMainStreamUserOptionArr = [NSArray arrayWithObjects:@"1080P",@"720P",@"标清",@"流畅", nil];
        iMainStreamL.frame = CGRectMake(15, 263, 110, 31);
        iMainStreamUserOptionSeg = [[UISegmentedControl alloc] initWithItems:iMainStreamUserOptionArr];
        iMainStreamUserOptionSeg.frame = CGRectMake(10, 304, kWidth-20, 31);
        iMainStreamUserOptionSeg.selectedSegmentIndex = self.iMainStreamUserOptionIndex-1;
//        NSLog(@"清晰度：%d",self.iMainStreamUserOptionIndex);
        [iMainStreamUserOptionSeg addTarget:self action:@selector(iMainStreamUserOptionSegAction:) forControlEvents:UIControlEventValueChanged];
        [scrollView addSubview:iMainStreamUserOptionSeg];
        
        UITextView *imageResoluTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, 335, kWidth-20, 76)];
        imageResoluTextView.editable = NO;
        imageResoluTextView.font = [UIFont systemFontOfSize:12];
        imageResoluTextView.text = @"1080P建议在10M以上带宽下使用，默认1M上行码流,720P建议在4M以上带宽下使用，默认768k上行码流,标清建议在2M以上带宽下使用，默认512k上行码流，流畅建议在1M以上带宽下使用，默认256k上行码流";
        imageResoluTextView.textColor = [UIColor grayColor];
        imageResoluTextView.scrollEnabled = NO;
        [scrollView addSubview:imageResoluTextView];
         
        lineV5.frame = CGRectMake(15, 415, kWidth-30, 0.5);
        
        //高级设置
        UILabel *customerSetL = [[UILabel alloc] initWithFrame:CGRectMake(10, 418, 90, 31)];
        customerSetL.text = @"高级设置";
        customerSetL.font = [UIFont systemFontOfSize:19];
        customerSetL.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:customerSetL];
        customerSetSw = [[UISwitch alloc] initWithFrame:CGRectMake(kWidth-80, 418, 51, 31)];
        [customerSetSw addTarget:self action:@selector(customerSetSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:customerSetSw];
        
        UILabel *customerSetExplainL = [[UILabel alloc] initWithFrame:CGRectMake(10, 450, kWidth-100, 24)];
        customerSetExplainL.text = @"(建议熟悉音视频设置的用户选择)";
        customerSetExplainL.font = [UIFont systemFontOfSize:12];
        customerSetExplainL.textColor = [UIColor grayColor];
        customerSetExplainL.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:customerSetExplainL];
        
        customerView = [[UIView alloc] initWithFrame:CGRectMake(0, 474, kWidth, 220)];
        [scrollView addSubview:customerView];
        if(self.iMainStreamUserOptionIndex>0)
        {
            customerView.hidden = YES;
            customerSetSw.on = NO;

        }else
        {
            customerView.hidden = NO;
            customerSetSw.on = YES;
        }
        customerView.backgroundColor = [UIColor whiteColor];
        
        UIView *lineV6 = [[UIView alloc] initWithFrame:CGRectMake(10, 1, kWidth-20, 0.5)];
        lineV6.backgroundColor = [UIColor grayColor];
        [customerView addSubview:lineV6];

        //图像分辨率
        UILabel *imageResolutionLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 90, 31)];
        imageResolutionLab.text = @"图像分辨率";
        [customerView addSubview:imageResolutionLab];
        NSArray *imageResolutionArr = [NSArray arrayWithObjects:@"1080P",@"720P",@"4CIF",@"CIF", nil];
        imageResolutionSeg = [[UISegmentedControl alloc] initWithItems:imageResolutionArr];
        imageResolutionSeg.frame = CGRectMake(10, 36, kWidth-20, 31);
        imageResolutionSeg.selectedSegmentIndex = self.imageResolutionIndex-1;
        [imageResolutionSeg addTarget:self action:@selector(imageResolutionSegAction:) forControlEvents:UIControlEventValueChanged];
        [customerView addSubview:imageResolutionSeg];
        
        UIView *lineV7 = [[UIView alloc] initWithFrame:CGRectMake(15, 75, kWidth-30, 0.5)];
        lineV7.backgroundColor = [UIColor grayColor];
        [customerView addSubview:lineV7];
        
        //视频码流
        UILabel *streamL = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, 110, 31)];
        streamL.text = @"视频码流";
        [customerView addSubview:streamL];
        
        streamF = [[UITextField alloc] initWithFrame:CGRectMake(kWidth/3, 80, 160, 31)];
        streamF.text = self.streamIndex;
//        streamF.delegate = self;
        streamF.keyboardType = UIKeyboardTypeNumberPad;
        //    streamF.borderStyle = UITextBorderStyleBezel;
        streamF.textAlignment = NSTextAlignmentRight;
        [customerView addSubview:streamF];
        UILabel *streamUnitL = [[UILabel alloc] initWithFrame:CGRectMake(kWidth-50, 80, 40, 31)];
        streamUnitL.text = @"kb/s";
        streamUnitL.backgroundColor = [UIColor clearColor];
        [customerView addSubview:streamUnitL];
        UILabel *bandExplainL = [[UILabel alloc] initWithFrame:CGRectMake(15, 111, kWidth-20, 24)];
        bandExplainL.text = @"请根据您的带宽选择合适的码流(128--2000)";
        bandExplainL.font = [UIFont systemFontOfSize:12];
        bandExplainL.textColor = [UIColor grayColor];
        bandExplainL.backgroundColor = [UIColor clearColor];
        [customerView addSubview:bandExplainL];
        
        UIView *lineV8 = [[UIView alloc] initWithFrame:CGRectMake(15, 140, kWidth-30, 0.5)];
        lineV8.backgroundColor = [UIColor grayColor];
        [customerView addSubview:lineV8];
        //视频帧率4/8/12/16/20/24/28
        UILabel *fpsL = [[UILabel alloc] initWithFrame:CGRectMake(15, 146, 120, 31)];
        fpsL.text = @"视频帧率(帧/秒)";
        fpsL.backgroundColor = [UIColor clearColor];
        [customerView addSubview:fpsL];
        
        streamFpsArr = [NSArray arrayWithObjects:@"4",@"8",@"12",@"16",@"20",@"24",@"28", nil];
        iStreamFpsSeg = [[UISegmentedControl alloc] initWithItems:streamFpsArr];
        iStreamFpsSeg.frame = CGRectMake(10, 185, kWidth-20, 31);
        iStreamFpsSeg.selectedSegmentIndex = self.iStreamFpsIndex;
        [iStreamFpsSeg addTarget:self action:@selector(streamFpsSegAction:) forControlEvents:UIControlEventValueChanged];
        [customerView addSubview:iStreamFpsSeg];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeybord)];
        [scrollView addGestureRecognizer:tap];
    }
}

- (void)hiddenKeybord
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

- (void)iMainStreamUserOptionSegAction:(id)sender
{
    customerView.hidden = YES;
    customerSetSw.on = NO;
    switch (iMainStreamUserOptionSeg.selectedSegmentIndex) {
        case 0:
        {
            streamF.text = @"1024";
            iStreamFpsSeg.selectedSegmentIndex = 1;
            imageResolutionSeg.selectedSegmentIndex = 0;
        }
            break;
        case 1:
        {
            streamF.text = @"768";
            iStreamFpsSeg.selectedSegmentIndex = 2;
            imageResolutionSeg.selectedSegmentIndex = 1;
        }
            break;
        case 2:
        {
            streamF.text = @"512";
            iStreamFpsSeg.selectedSegmentIndex = 3;
            imageResolutionSeg.selectedSegmentIndex = 2;
        }
            break;
        case 3:
        {
            streamF.text = @"256";
            iStreamFpsSeg.selectedSegmentIndex = 4;
            imageResolutionSeg.selectedSegmentIndex = 3;
        }
            break;
        default:
            break;
    }
}

//高级设置开关
- (void)customerSetSwitchAction:(id)sender
{
    [UIView animateWithDuration:0.15 animations:^{
        if (customerSetSw.on) {
            //自定义设置
            customerView.hidden = NO;
            iMainStreamUserOptionSeg.selectedSegmentIndex = -1;
        }else{
            //关闭自定义设置
            customerView.hidden = YES;
            iMainStreamUserOptionSeg.selectedSegmentIndex = self.iMainStreamUserOptionIndex-1;
        }
    }];
}

//图像分辨率
- (void)imageResolutionSegAction:(id)sender
{
    
}
//帧率
- (void)streamFpsSegAction:(id)sender
{
    
}
//判断输入的值是否介于两者之间
- (BOOL)bandStreamIsLegalNum:(int)startNum to:(int)endNum withNumString:(NSString *)numString
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
- (BOOL)audioVolIsLegalNum:(int)startNum to:(int)endNum withNumString:(NSString *)numString
{
    int audioVol = [numString intValue];
    if (audioVol >= startNum && audioVol <= endNum) {
        return YES;
    }else{
        UIAlertView *errorV = [[UIAlertView alloc] initWithTitle:@"错误" message:[NSString stringWithFormat:@"相机音量值应该设为%d-%d",startNum,endNum] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [errorV show];
        return NO;
    }
}

- (void)finishAction:(id)sender
{
    BOOL bandflag = [self bandStreamIsLegalNum:128 to:2000 withNumString:streamF.text];
    BOOL audioflag = [self audioVolIsLegalNum:0 to:100 withNumString:audioVolF.text];
    if (!bandflag) {
        return;
    }
    else if (!audioflag)
    {
        return;
    }
    [self.view endEditing:YES];
    [self isLoadingView];
    NSDictionary *setCameraDataDict;
    if (self.isLow) {
        setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInteger:audioSw.on ],@"iEnableAudioIn",
                             audioVolF.text,@"iAudioVol",
                             [NSNumber numberWithInteger:iMainStreamUserOptionSeg.selectedSegmentIndex+1],@"iMainStreamUserOption",
                             nil];
    }else
    {
        if (customerSetSw.on) {
            //自定义设置
            setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithInteger:audioSw.on ],@"iEnableAudioIn",
                                 audioVolF.text,@"iAudioVol",
                                 [NSNumber numberWithInteger:flipImageSeg.selectedSegmentIndex],@"iFlipImage",
                                 [NSNumber numberWithInteger:ntscOrPalSeg.selectedSegmentIndex+1],@"iNTSCPAL",
                                 [NSNumber numberWithInteger:imageResolutionSeg.selectedSegmentIndex+1],@"iImageResolution",
                                 streamF.text,@"iStreamBitrate",
                                 [streamFpsArr objectAtIndex:iStreamFpsSeg.selectedSegmentIndex],@"iStreamFps",
                                 nil];
        }else
        {
            if (imageResolutionSeg.selectedSegmentIndex==3) {
                setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:audioSw.on ],@"iEnableAudioIn",
                                     audioVolF.text,@"iAudioVol",
                                     [NSNumber numberWithInteger:flipImageSeg.selectedSegmentIndex],@"iFlipImage",
                                     [NSNumber numberWithInteger:ntscOrPalSeg.selectedSegmentIndex+1],@"iNTSCPAL",
                                     [NSNumber numberWithInteger:iMainStreamUserOptionSeg.selectedSegmentIndex+1],@"iMainStreamUserOption",
                                     [NSNumber numberWithInteger:imageResolutionSeg.selectedSegmentIndex+2],@"iImageResolution",
                                     streamF.text,@"iStreamBitrate",
                                     [streamFpsArr objectAtIndex:iStreamFpsSeg.selectedSegmentIndex],@"iStreamFps",
                                     nil];
            }else{
                setCameraDataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSNumber numberWithInteger:audioSw.on ],@"iEnableAudioIn",
                                     audioVolF.text,@"iAudioVol",
                                     [NSNumber numberWithInteger:flipImageSeg.selectedSegmentIndex],@"iFlipImage",
                                     [NSNumber numberWithInteger:ntscOrPalSeg.selectedSegmentIndex+1],@"iNTSCPAL",
                                     [NSNumber numberWithInteger:iMainStreamUserOptionSeg.selectedSegmentIndex+1],@"iMainStreamUserOption",
                                     [NSNumber numberWithInteger:imageResolutionSeg.selectedSegmentIndex+1],@"iImageResolution",
                                     streamF.text,@"iStreamBitrate",
                                     [streamFpsArr objectAtIndex:iStreamFpsSeg.selectedSegmentIndex],@"iStreamFps",
                                     nil];
  
            }
        }
    }
//    NSLog(@"setCamera:%@",setCameraDataDict);
    NSString *setCameraDataString = [setCameraDataDict JSONString];
    NSString *strWithUTF8 = [setCameraDataString encodeChinese];
    NSString *setURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=control&access_token=%@&deviceid=%@&command=%@",self.access_token,self.deviceid,strWithUTF8];
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

- (void)alertViewShowWithTitle:(NSString*)string andMessage:(NSString*)message
{
    UIAlertView *setError = [[UIAlertView alloc] initWithTitle:string
                                                       message:message
                                                      delegate:nil
                                             cancelButtonTitle:@"好"
                                             otherButtonTitles:nil, nil];
    [setError show];
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

#pragma mark - textFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:streamF up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:streamF up:NO];
}
//视图上移的方法
- (void)animateTextField: (UITextField *) textField up: (BOOL) up
{
    //设置视图上移的距离，单位像素
    const int movementDistance = 180; // tweak as needed
    //三目运算，判定是否需要上移视图或者不变
    int movement = (up ? -movementDistance : movementDistance);
    //设置动画的名字
    [UIView beginAnimations: @"Animation" context: nil];
    //设置动画的开始移动位置
    [UIView setAnimationBeginsFromCurrentState: YES];
    //设置动画的间隔时间
    [UIView setAnimationDuration: 0.20];
    //设置视图移动的位移
    scrollView.frame = CGRectOffset(scrollView.frame, 0, movement);
    //设置动画结束
    [UIView commitAnimations];
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
    [scrollView endEditing:YES];
}
@end
