//
//  AddDeviceViewController.m
//  NewProject
//
//  Created by zhxf on 14-3-5.
//  Copyright (c) 2014年 Steven. All rights reserved.
//

#import "AddDeviceViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CFNetwork/CFNetwork.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <CommonCrypto/CommonDigest.h>
#import "SecurtyStyleViewController.h"
#import "IPObtainStyleViewController.h"
#import "NSString+encodeChinese.h"

#define kHost @"192.168.62.1"
#define kPort 7860
#define kTimeout 30

@interface AddDeviceViewController ()<UIAlertViewDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate,UITextFieldDelegate,IPObtainStyleViewControllerDelegate,SecurtyStyleViewControllerDelegate,MBProgressHUDDelegate>
{
    UITextField  *deviceF,*deviceDetailF,*SSIDPWF,*SSIDF,*SSIDPWFconfirm;
    UIAlertView *nextAlertview,*loginAlterView,*configurationTipView;
    NSArray *securyArr;
    UIScrollView *scrollView;
    //    UITextField *userField;
    MBProgressHUD *_loadingView;
    int setHeight;
    UIButton *ipStyleBtn,*securtyBtn,*shareBtn;
    NSInteger IPIndexPath,securtyIndexPath;
    NSDictionary *ipParameraDict;
//    UISegmentedControl *hexOrAscii;
}
@end

@implementation AddDeviceViewController

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
    background.image = [UIImage imageNamed:backGroundImage];
    [self.view addSubview:background];
    background.userInteractionEnabled = YES;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 64)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    float backHeight;
    if (iOS7) {
        backHeight = kStatusbarHeight + 5;
    }else
    {
        backHeight = kStatusbarHeight + 25;
    }
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, backHeight, 120, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64)];
    scrollView.contentSize = CGSizeMake(kWidth, kHeight);
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    self.wifiBssid = @"";
    if (self.isAddDevice) {
       
        setHeight = 0;
        [backBtn setTitle:@"配置摄像头" forState:UIControlStateNormal];
        UILabel *deviceL = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 80, 30)];
        deviceL.text = @"MAC地址:";
        deviceL.backgroundColor = [UIColor clearColor];
        
        [scrollView addSubview:deviceL];
        deviceF = [[UITextField alloc] initWithFrame:CGRectMake(90, 6, kWidth-100, 30)];
        if (self.isScanFlag) {
            deviceF.text = self.deviceID;
            deviceF.enabled = NO;
        }else
        {
            deviceF.enabled = YES;
            deviceF.returnKeyType = UIReturnKeyNext;
            deviceF.placeholder = @"设备MAC地址不区分大小写";
            deviceF.font = [UIFont systemFontOfSize:15];
            deviceF.delegate = self;
        }
        deviceF.allowsEditingTextAttributes = YES;
        deviceF.borderStyle = UITextBorderStyleRoundedRect;
        deviceF.keyboardType = UIKeyboardTypeNamePhonePad;
        [scrollView addSubview:deviceF];
        
        UILabel *deviceDetail = [[UILabel alloc] initWithFrame:CGRectMake(10, 46, 80, 30)];
        deviceDetail.text = @"起个名吧:";
        deviceDetail.backgroundColor = [UIColor clearColor];
        [scrollView addSubview:deviceDetail];
        deviceDetailF = [[UITextField alloc] initWithFrame:CGRectMake(90, 46, kWidth-100, 30)];
        deviceDetailF.borderStyle = UITextBorderStyleRoundedRect;
        deviceDetailF.returnKeyType = UIReturnKeyNext;
        deviceDetailF.keyboardType = UIKeyboardTypeDefault;
        deviceDetailF.delegate = self;
        deviceDetailF.text = @"我的乐现";
        deviceDetailF.placeholder = @"请给乐现起个名字吧";
        [scrollView addSubview:deviceDetailF];
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 323, kWidth-20, 46)];
        tipLabel.text = @"温馨提示：配置摄像头前请长按5s摄像头的Reset(复位)键。";
        tipLabel.textColor = [UIColor yellowColor];
        tipLabel.numberOfLines = 2;
        [scrollView addSubview:tipLabel];
    }else
    {
        setHeight = 50;
        [backBtn setTitle:@"更换网络" forState:UIControlStateNormal];
    }
    
    UILabel *SSIDL = [[UILabel alloc] initWithFrame:CGRectMake(10, 86-setHeight, 80, 30)];
    SSIDL.text = @"WiFi名称:";
    SSIDL.backgroundColor = [UIColor clearColor];

    [scrollView addSubview:SSIDL];
    SSIDF = [[UITextField alloc] initWithFrame:CGRectMake(90, 86-setHeight, kWidth-100, 30)];
    SSIDF.borderStyle = UITextBorderStyleRoundedRect;
    SSIDF.textColor = [UIColor grayColor];
    SSIDF.placeholder = @"请输入WiFi名";
    SSIDF.text = [self fetchSSIDInfo];
//    SSIDF.text = @"zhonghexunfei";
//    SSIDF.delegate = self;
//    SSIDF.enabled = NO;
    [scrollView addSubview:SSIDF];
    
//    NSLog(@"wifi:%@",[self fetchSSIDInfo]);
//    if (![self fetchSSIDInfo]) {
//        NSLog(@"wifi没打开");
//        UIButton *obtainWifiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        obtainWifiBtn.frame = CGRectMake(100, 86, 180, 30);
//        obtainWifiBtn.backgroundColor = [UIColor blueColor];
//        [obtainWifiBtn setTitle:@"获取wifi" forState:UIControlStateNormal];
//        [obtainWifiBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//        [scrollView addSubview:obtainWifiBtn];
//        [obtainWifiBtn addTarget:self action:@selector(obtainWifiAction) forControlEvents:UIControlEventTouchUpInside];
//    }
    
    UILabel *SSIDPW = [[UILabel alloc] initWithFrame:CGRectMake(10, 126-setHeight, 80, 30)];
    SSIDPW.text = @"WiFi密码:";
    SSIDPW.backgroundColor = [UIColor clearColor];

    [scrollView addSubview:SSIDPW];
    SSIDPWF = [[UITextField alloc] initWithFrame:CGRectMake(90, 126-setHeight, kWidth-100, 30)];
    SSIDPWF.borderStyle = UITextBorderStyleRoundedRect;
    SSIDPWF.returnKeyType = UIReturnKeyNext;
    SSIDPWF.placeholder = @"请输入WiFi密码";
    SSIDPWF.keyboardType = UIKeyboardTypeNamePhonePad;
    SSIDPWF.delegate = self;
    [scrollView addSubview:SSIDPWF];
    
    UILabel *SSIDPWconfirm = [[UILabel alloc] initWithFrame:CGRectMake(10, 166-setHeight, 80, 30)];
    SSIDPWconfirm.text = @"确认密码:";
    SSIDPWconfirm.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:SSIDPWconfirm];
    SSIDPWFconfirm = [[UITextField alloc] initWithFrame:CGRectMake(90, 166-setHeight, kWidth-100, 30)];
    SSIDPWFconfirm.borderStyle = UITextBorderStyleRoundedRect;
    SSIDPWFconfirm.returnKeyType = UIReturnKeyDone;
    SSIDPWFconfirm.placeholder = @"请再次输入WiFi密码";
    SSIDPWFconfirm.delegate = self;
    SSIDPWFconfirm.keyboardType = UIKeyboardTypeNamePhonePad;
    [scrollView addSubview:SSIDPWFconfirm];
    
    UIView  *lineL = [[UIView alloc] initWithFrame:CGRectMake(2, 201, kWidth-4, 1)];
    lineL.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineL];
    
    UILabel *securtyStyleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 211, 145, 24)];
    securtyStyleLab.text = @"高级设置";
    securtyStyleLab.backgroundColor = [UIColor clearColor];

    securtyStyleLab.font = [UIFont systemFontOfSize:24];
    [scrollView addSubview:securtyStyleLab];
    
    UILabel *ipStyleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 246, 140, 34)];
    ipStyleLabel.text = @"IP地址获取方式:";
    ipStyleLabel.backgroundColor = [UIColor clearColor];

    [scrollView addSubview:ipStyleLabel];
    ipStyleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    ipStyleBtn.frame = CGRectMake(220, 246, 80, 34);
//    [ipStyleBtn setBackgroundColor:[UIColor grayColor]];
    [ipStyleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [ipStyleBtn setTitle:@"自动获取" forState:UIControlStateNormal];
    [ipStyleBtn addTarget:self action:@selector(ipSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:ipStyleBtn];
    
    UILabel *securtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 286, 200, 34)];
    securtyLabel.text = @"路由器无线认证安全类型:";
    securtyLabel.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:securtyLabel];
    securtyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    securtyBtn.frame = CGRectMake(220, 286, 80, 34);
    [securtyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [securtyBtn setTitle:@"WPA*" forState:UIControlStateNormal];
    [securtyBtn addTarget:self action:@selector(securtySelectAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:securtyBtn];
    self.identifify = @"";
    
    UIView  *lineL2 = [[UIView alloc] initWithFrame:CGRectMake(2, 321, kWidth-4, 1)];
    lineL2.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:lineL2];
    
//    securyArr = [NSArray arrayWithObjects:@"[WPA2-PSK-TKIP+CCMP]",@"[WPA-PSK-TKIP+CCMP]",@"[WPA2-EAP-TKIP+CCMP]",@"[WPA-EAP-TKIP+CCMP]",@"[WEP]",@"[ESS]", nil];
    securyArr = [NSArray arrayWithObjects:@"[WPA2-PSK-TKIP+CCMP]",@"[WPA2-EAP-TKIP+CCMP]",@"[WEP]",@"[ESS]", nil];
    self.security = @"[WPA2-PSK-TKIP+CCMP]";
    self.wepStyle = @"1";
    //
//    NSArray *wepStyleArr = [NSArray arrayWithObjects:@"Hex",@"Ascii", nil];
//    hexOrAscii = [[UISegmentedControl alloc] initWithItems:wepStyleArr];
//    hexOrAscii.frame = CGRectMake(80, 345, 160, 42);
//    [hexOrAscii addTarget:self action:@selector(wepStyleAction:) forControlEvents:UIControlEventValueChanged];
//    hexOrAscii.selectedSegmentIndex = 0;
//    hexOrAscii.hidden = YES;
//    [self.view addSubview:hexOrAscii];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(80, 370, 160, 40);
    [startBtn setBackgroundImage:[UIImage imageNamed:@"kaishipeizhi_anniu@2x"] forState:UIControlStateNormal];
    if (self.isAddDevice) {
        [startBtn setTitle:@"开始配置" forState:UIControlStateNormal];
    }else
    {
        [startBtn setTitle:@"更换网络" forState:UIControlStateNormal];
    }
    [startBtn addTarget:self action:@selector(startConfigure) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:startBtn];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeybord)];
    [scrollView addGestureRecognizer:tap];

    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
}

- (void)hiddenKeybord
{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}
//- (void)obtainWifiAction
//{
//    SSIDF.text = [self fetchSSIDInfo];
//}
- (void)backBtn:(id)sender
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//获取WiFi名称
- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
//    ////NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
//        ////NSLog(@"%@ => %@", ifnam, info);
        NSString *BSSID = [info objectForKey:@"BSSID"];
//        ////NSLog(@"BSSID:%@",BSSID);
        self.wifiBssid = BSSID;
//        NSString *SSIDDATAT = [info objectForKey:@"SSIDDATA"];
//        ////NSLog(@"SSIDDATA:%@",SSIDDATAT);
//        NSData *ssiddata = [info objectForKey:@"SSIDDATA"];
//        NSString *ssidda = [NSString stringWithFormat:@"%@",ssiddata ];
//        ////NSLog(@"ssiddata:%@",ssidda);
        if (info && [info count]) { break; }
    }
    NSString *SSID = [info objectForKey:@"SSID"];
    return SSID;
}

//开始配置或更换网络
- (void)startConfigure
{
    if (self.isAddDevice) {
        //配置设备
        int isLow;
        NSString *hexdeviceID;
        switch (deviceF.text.length) {
            case 13:
            {
                isLow = 1;
                hexdeviceID = [deviceF.text substringFromIndex:1];
            }
                break;
            case 12:
            {
                isLow = 0;
                hexdeviceID = deviceF.text;
            }
                break;
            default:
            {
                UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"该设备ID不合法" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                [view show];
                return;
            }
                break;
        }
        const char* a = [hexdeviceID cStringUsingEncoding:NSASCIIStringEncoding];
        //    NSLog(@"a.length:%d=======%s",deviceF.text.length,a);
        int64_t deviceIDint64 = MacAddr2DecDeviceID(a, isLow);//
        
        if (SSIDF.text.length == 0) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"只允许在WiFi环境下配置" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [view show];
            return;
        }
        else if ([deviceDetailF.text isEqualToString:@""]||[SSIDPWF.text isEqualToString:@""]||[SSIDPWFconfirm.text isEqualToString:@""]) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备描述或密码不能为空" message:@"设备描述或密码不能为空" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [view show];
            return ;
        }else if (![SSIDPWF.text isEqualToString:SSIDPWFconfirm.text])
        {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"密码输入不一致" message:@"密码输入不一致" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [view show];
            return ;
        }else if (deviceDetailF.text.length > 64) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备名称不能超过64个字符" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [view show];
            return;
        }
        //向Baidu服务器注册设备
        NSString *des = [deviceDetailF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *strWithUTF8 = [des encodeChinese];
        //https://pcs.baidu.com/rest/2.0/pcs/device?method=register&deviceid=123456&access_token=52.88be325d08d983f7403be8438c0c1eed.2592000.1403337720.1812238483-2271149&device_type=1&desc=摄像头描述
        NSString *URLstr = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=register&deviceid=%lld&access_token=%@&device_type=1&desc=%@",deviceIDint64,self.access_token,strWithUTF8];
        [self isLoadingView];
        
        [[AFHTTPRequestOperationManager manager] POST:URLstr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //--------------------向Baidu注册成功，隐藏loadingView-------------------------
            [_loadingView hide:YES];
            
            [self connectToWifi];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            ////NSLog(@"==========注册失败===============");
            //--------------------向Baidu注册成功，隐藏loginAlterView-------------------------
            //        [loginAlterView dismissWithClickedButtonIndex:0 animated:YES];
            NSDictionary *errorDict = [error userInfo];
            //        ////NSLog(@"dict:%@",errorDict);
            [_loadingView hide:YES];
            
            NSString *NSLocalizedDescription = [errorDict objectForKey:@"NSLocalizedDescription"];
            ////NSLog(@"NSLocalizedDescription:%@",NSLocalizedDescription);//Request failed: forbidden (403)
            if ([NSLocalizedDescription rangeOfString:@"403"].location) {
                UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"设备已经注册过了" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                [errorView show];
                return ;
            }else if ([NSLocalizedDescription rangeOfString:@"503"].location)
            {
                UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"添加设备出错或网络问题" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                [errorView show];
                return ;
            }else if ([NSLocalizedDescription rangeOfString:@"400"].location)
            {
                UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"访问的参数错误" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                [errorView show];
                return ;
            }
            return ;
        }];
    }else
    {
        //更换网络
        if (SSIDF.text.length == 0) {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"只允许在WiFi环境下配置" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [view show];
            return;
        }else if (SSIDPWF.text.length == 0)
        {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"密码不能为空" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [view show];
            return;
        }
        else if (![SSIDPWF.text isEqualToString:SSIDPWFconfirm.text])
        {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"密码输入不一致" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [view show];
            return ;
        }
        [self connectToWifi];
    }
}

- (void)connectToWifi
{
    nextAlertview = [[UIAlertView alloc] initWithTitle:nil message:@"1.请切换到“系统设置”>>“无线局域网”\n2.连接Joyshow_cam开头的摄像头热点,(密码为123456789)\n3.切换回此页面，点击下一步" delegate:self cancelButtonTitle:@"下一步" otherButtonTitles:nil, nil];
    nextAlertview.delegate = self;
    [nextAlertview show];
    
}

//32位MD5加密方式
//- (NSString *)getMd5_32Bit_String:(NSString *)srcString{
//    const char *cStr = [srcString UTF8String];
//    unsigned char digest[CC_MD5_DIGEST_LENGTH];
//    CC_MD5( cStr, strlen(cStr), digest );
//    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
//    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
//        [result appendFormat:@"%02x", digest[i]];
//    return result;
//}

- (NSMutableString *)exchangeString:(NSString *)string
{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i=0; i<32; i++) {
        //一一截取字符串，加入到可变数组中
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        [arr addObject:s];
    }
    //数组交换
    [arr exchangeObjectAtIndex:1 withObjectAtIndex:6];
    [arr exchangeObjectAtIndex:4 withObjectAtIndex:13];
    [arr exchangeObjectAtIndex:21 withObjectAtIndex:29];
    [arr exchangeObjectAtIndex:20 withObjectAtIndex:25];
    NSMutableString *mutableString = [NSMutableString string];
    for (NSString *s in arr) {
        //遍历数组，加到可变数组中
        [mutableString appendString:s];
    }
    return mutableString;
}

#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.view setNeedsDisplay];
    //判断WiFi名是否以joyshow开头
    if ([[self fetchSSIDInfo]hasPrefix:@"Joyshow_cam" ]) {
        [self openUDPServer];
        [self isLoadingView];

        self.security = [securyArr objectAtIndex:securtyIndexPath];
        if (IPIndexPath) {
            self.dhcp    = @"0";
            self.ipaddr  = [ipParameraDict objectForKey:@"ipaddr"];
            self.mask    = [ipParameraDict objectForKey:@"mask"];
            self.gateway = [ipParameraDict objectForKey:@"gateway"];
        }else
        {
            self.dhcp    = @"1";
            self.ipaddr  = @"";
            self.mask    = @"";
            self.gateway = @"";
        }
        SSIDF.text = [SSIDF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        SSIDPWF.text = [SSIDPWF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:kUserId];
        NSString *dataStr = [NSString stringWithFormat:@"1%@%@%@%@%@%@%@2%@%@%@%@%@",self.wifiBssid,SSIDF.text,self.security,self.identifify,SSIDPWF.text,userID,self.access_token,self.wepStyle,self.dhcp,self.ipaddr,self.mask,self.gateway];
        NSLog(@"MD5加密前dataStr:%@",dataStr);
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"1",@"opcode",//1为注册
                                  self.wifiBssid,@"bssid",//
                                  SSIDF.text,@"ssid",//WiFi名称
                                  self.security,@"security",//加密方式
                                  self.identifify,@"identify",//二次加密的密码
                                  SSIDPWF.text,@"pwd",//WiFi密码
                                  userID,@"userId",//登录的用户名
                                  self.access_token,@"accessToken",//accessToken
                                //  [[NSUserDefaults standardUserDefaults] objectForKey:kUserRefreshToken],@"refreshToken",
                                  @"2",@"osType",//2为iOS平台
                                  self.wepStyle,@"hexAscii",//16进制或ascll
                                  self.dhcp,@"dhcp",//1为自动
                                  self.ipaddr,@"ipaddr",//ip
                                  self.mask,@"mask",//掩码
                                  self.gateway,@"gateway",//路由器
                                  @"",@"url",//保留URL
                                  @"",@"reserved",nil];//保留参数
        NSString *md5String = [NSString getMd5_32Bit_String:dataStr];//得到md5加密后的32位字符串
        NSLog(@"MD5加密后md5String:%@",md5String);//0ea7ccca8f7eeefb255e1931cb1409aa
        
        NSMutableString *md5exchangeString = [self exchangeString:md5String];//1,6;4,13;21,29;20,25交换
        NSInteger length = dataStr.length;//data的长度
        NSString *md5Length = [NSString stringWithFormat:@"%ld",(long)length];
        NSDictionary *headDict = [NSDictionary dictionaryWithObjectsAndKeys:md5Length,@"length",md5exchangeString,@"verify", nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:headDict,@"head",dataDict,@"data", nil];
        NSString *sendString = [dict JSONString];
        NSLog(@"发送的数据：%@",sendString);
        [self sendMassage:sendString];
        [self backBtn:nil];
        return;
    }
    if (nextAlertview == alertView ) {
        [self connectToWifi];
    }
}

#pragma mark - UDP Socket
//建立基于UDP的Socket连接
-(void)openUDPServer{
	//初始化udp
    self.udpSocket=[[AsyncUdpSocket alloc] initWithDelegate:self];
	//绑定端口
	NSError *error = nil;
//	BOOL bindFlag =
    [self.udpSocket bindToPort:kPort error:&error];
//    if (bindFlag) {
//        NSLog(@"bind success");
//    }else
//    {
//        NSLog(@"bind fail");
//    }
    //绑定地址
    //    [self.udpSocket bindToAddress:@"192.168.8.1" port:7860 error:&error];
    
    //发送广播设置
    //    [self.udpSocket enableBroadcast:YES error:&error];
    
    //加入群里，能接收到群里其他客户端的消息
    //    [self.udpSocket joinMulticastGroup:@"224.0.0.2" error:&error];
    
   	//启动接收线程
	[self.udpSocket receiveWithTimeout:-1 tag:0];
}

//通过UDP,发送消息
-(void)sendMassage:(NSString *)message
{
//	NSMutableString *sendString = [NSMutableString stringWithCapacity:100];
//	[sendString appendString:message];
    NSData *sendData = [message dataUsingEncoding:NSUTF8StringEncoding];
	//开始发送
	BOOL res = [self.udpSocket sendData:sendData
								 toHost:kHost
								   port:kPort
							withTimeout:-1
                                    tag:0];
    
   	if (!res) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
														message:@"发送失败"
													   delegate:self
											  cancelButtonTitle:@"取消"
											  otherButtonTitles:nil];
		[alert show];
	}
}

#pragma mark -
#pragma mark UDP Delegate Methods
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    [self.udpSocket receiveWithTimeout:-1 tag:0];
    ////NSLog(@"host---->%@",host);
    _loadingView.hidden = YES;
   	//接收到数据回调，显示出来
//	NSString *info=[[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
//	NSLog(@"UDP代理接收到的数据：%@",info);
	//已经处理完毕
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"配置成功"
													message:@"1.请切换到“系统设置”>>“无线局域网”\n2.断开Joyshow_cam开头的摄像头热点\n3.连接到可上网的WiFi热点\n4.切换回此页面，再次刷新页面"
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	//无法发送时,返回的异常提示信息
    _loadingView.hidden = YES;
    [nextAlertview show];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法发送"
													message:[error description]
												   delegate:nil
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
	//无法接收时，返回异常提示信息
    _loadingView.hidden = YES;
    [nextAlertview show];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法接收"
													message:[error description]
												   delegate:nil
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
//    [scrollView endEditing:YES];
}

#pragma mark - 高级设置
//IP模式选择
- (void)ipSelectAction:(id)sender
{
    IPObtainStyleViewController *ipVC = [[IPObtainStyleViewController alloc] init];
    ipVC.delegate = self;
    ipVC.selectedIndex = IPIndexPath;
    if (IPIndexPath) {
        ipVC.ipParameter = ipParameraDict;
    }
    [self presentViewController:ipVC animated:YES completion:nil];
//    [[SliderViewController sharedSliderController].navigationController pushViewController:ipVC animated:YES];
}

//路由器无线加密方式
- (void)securtySelectAction:(id)sender
{
    SecurtyStyleViewController *securtyVC = [[SecurtyStyleViewController alloc] init];
    securtyVC.delegate = self;
    securtyVC.selectIndex = securtyIndexPath;
    securtyVC.pwd = self.identifify;
//    [[SliderViewController sharedSliderController].navigationController pushViewController:securtyVC animated:YES];
    [self presentViewController:securtyVC animated:YES completion:nil];
}
#pragma mark - delegate
//IP模式代理
- (void)ipObtainStyle:(NSInteger)integer withStaticParameter:(NSDictionary *)ipParameter
{
    IPIndexPath = integer;
    if (integer) {
        ////NSLog(@"1");
//        NSString *subnetMask = [ipParameter objectForKey:@"subnetMask"];
//        ////NSLog(@"subnetmask:%@",subnetMask);
        ipParameraDict = ipParameter;
        [ipStyleBtn setTitle:@"手动设置" forState:UIControlStateNormal];
        
    }else
    {
        ////NSLog(@"0");
        [ipStyleBtn setTitle:@"自动获取" forState:UIControlStateNormal];
    }
}
//无线加密方式
- (void)securtyStyleSelect:(NSString *)securtyStyle withIndex:(NSInteger)index withpwd:(NSString *)pwd
{
    ////NSLog(@"securtyStyle:%@,index:%d,pwd:%@",securtyStyle,index,pwd);
    securtyIndexPath = index;
    self.identifify = pwd;
    [securtyBtn setTitle:securtyStyle forState:UIControlStateNormal];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    [textField resignFirstResponder];
    if (deviceF == textField) {
        [deviceDetailF becomeFirstResponder];
    }
    else if (deviceDetailF == textField) {
        [SSIDPWF becomeFirstResponder];
    }else if(SSIDPWF == textField)
    {
        [SSIDPWFconfirm becomeFirstResponder];
    }else
    {
        [self.view endEditing:YES];
    }
    return YES;
}

- (void)isLoadingView
{
    if (_loadingView) {
        [_loadingView show:YES];
        return;
    }
    _loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_loadingView];
    _loadingView.delegate = self;
    _loadingView.labelText = @"loading";
    _loadingView.detailsLabelText = @"发送中，请稍后……";
    _loadingView.square = YES;
    [_loadingView show:YES];
    _loadingView.color = [UIColor grayColor];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.view setNeedsDisplay];
//    if (self.isAddDevice) {
//        UIAlertView *tipview = [[UIAlertView alloc] initWithTitle:@"为确保配置摄像头成功，请先用针长按5秒摄像头的reset(复位)按钮" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
//        [tipview show];
//    }
}

//16进制的Mac地址转换为10进制的
int64_t MacAddr2DecDeviceID(const char* pMacAddr, int iDeviceType)
{
	if (NULL == pMacAddr)
		return 0;
    
	int i = 0;
	int iMacAddrDecValue[12];
	int iSegDecValue[6];
	int iValidInputFlag = 1;
	int64_t i64RetValue = 0;
	
	for (i = 0; i < 12; i++)
	{
		if (pMacAddr[i] >= 0x30 && pMacAddr[i] <= 0x39)
			iMacAddrDecValue[i] = pMacAddr[i] - 0x30;
		else if (pMacAddr[i] >= 0x41 && pMacAddr[i] <= 0x46)
			iMacAddrDecValue[i] = 10 + pMacAddr[i] - 0x41;
		else if (pMacAddr[i] >= 0x61 && pMacAddr[i] <= 0x66)
			iMacAddrDecValue[i] = 10 + pMacAddr[i] - 0x61;
		else
		{
			iValidInputFlag = 0;
			break;
		}
	}
	if (0 == iValidInputFlag)
		return 0;
    
	for (i = 0; i < 6; i++)
	{
		iSegDecValue[i] = (iMacAddrDecValue[2*i]<<4) + iMacAddrDecValue[2*i+1];
	}
    
	if (iDeviceType)
		i64RetValue += 1;
    
	for (i = 5; i >= 0; i--)
	{
		i64RetValue = (i64RetValue<<8);
		i64RetValue	+= iSegDecValue[i];
	}
    
	return i64RetValue;
}

@end
