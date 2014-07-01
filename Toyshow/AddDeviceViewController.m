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
#import "JSONKit.h"
#import "NetworkRequest.h"
#import "NetworkRequest.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonDigest.h>
#import "SecurtyStyleViewController.h"
#import "IPObtainStyleViewController.h"
#import "SliderViewController.h"
#import "MBProgressHUD.h"

#define kTestHost @"telnet://towel.blinkenlights.nl"
#define kTestPort 23

@interface AddDeviceViewController ()<UIAlertViewDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate,UITextFieldDelegate,IPObtainStyleViewControllerDelegate,SecurtyStyleViewControllerDelegate,MBProgressHUDDelegate>
{
    UITextField *deviceDetailF,*SSIDPWF,*SSIDF,*SSIDPWFconfirm;
    UIAlertView *nextAlertview,*loginAlterView,*configurationTipView;
    NSArray *securyArr;
//    UIView *userView;
//    UITextField *userField;
    MBProgressHUD *_loadingView;

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
    UIImageView *background = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    background.image = [UIImage imageNamed:backGroundImage];
    [self.view addSubview:background];
    background.userInteractionEnabled = YES;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 120, 22);
    [backBtn setTitle:@"配置摄像头" forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    UILabel *deviceL = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 100, 30)];
    deviceL.text = @"设备ID:";
    [self.view addSubview:deviceL];
    UITextField *deviceF = [[UITextField alloc] initWithFrame:CGRectMake(100, 70, 180, 30)];
    deviceF.text = self.deviceID;
    deviceF.enabled = NO;
    deviceF.allowsEditingTextAttributes = YES;
    deviceF.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:deviceF];
    
    UILabel *deviceDetail = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, 100, 30)];
    deviceDetail.text = @"设备描述:";
    [self.view addSubview:deviceDetail];
    deviceDetailF = [[UITextField alloc] initWithFrame:CGRectMake(100, 110, 180, 30)];
    deviceDetailF.borderStyle = UITextBorderStyleRoundedRect;
    deviceDetailF.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:deviceDetailF];
    
    UILabel *SSIDL = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 100, 30)];
    SSIDL.text = @"WiFi名称:";
    [self.view addSubview:SSIDL];
    SSIDF = [[UITextField alloc] initWithFrame:CGRectMake(100, 150, 180, 30)];
    SSIDF.borderStyle = UITextBorderStyleRoundedRect;
    SSIDF.text = [self fetchSSIDInfo];
//    SSIDF.text = @"zhonghexunfei";
    SSIDF.enabled = NO;
    [self.view addSubview:SSIDF];
    
    UILabel *SSIDPW = [[UILabel alloc] initWithFrame:CGRectMake(10, 190, 100, 30)];
    SSIDPW.text = @"WiFi密码:";
    [self.view addSubview:SSIDPW];
    SSIDPWF = [[UITextField alloc] initWithFrame:CGRectMake(100, 190, 180, 30)];
    SSIDPWF.borderStyle = UITextBorderStyleRoundedRect;
    SSIDPWF.returnKeyType = UIReturnKeyNext;
    SSIDPWF.text = @"zhxf0602";
    [self.view addSubview:SSIDPWF];
    
    UILabel *SSIDPWconfirm = [[UILabel alloc] initWithFrame:CGRectMake(10, 230, 80, 30)];
    SSIDPWconfirm.text = @"确认密码:";
    [self.view addSubview:SSIDPWconfirm];
    SSIDPWFconfirm = [[UITextField alloc] initWithFrame:CGRectMake(100, 230, 180, 30)];
    SSIDPWFconfirm.borderStyle = UITextBorderStyleRoundedRect;
    SSIDPWFconfirm.returnKeyType = UIReturnKeyDone;
    SSIDPWFconfirm.text = @"zhxf0602";
    [self.view addSubview:SSIDPWFconfirm];
    
    UILabel  *lineL = [[UILabel alloc] initWithFrame:CGRectMake(2, 265, 320-4, 1)];
    lineL.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineL];
    UILabel *securtyStyleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 275, 145, 24)];
    securtyStyleLab.text = @"高级设置";
    securtyStyleLab.font = [UIFont systemFontOfSize:24];
    [self.view addSubview:securtyStyleLab];
    
    UILabel *ipStyleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 310, 140, 34)];
    ipStyleLabel.text = @"IP地址获取方式:";
    [self.view addSubview:ipStyleLabel];
    ipStyleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    ipStyleBtn.frame = CGRectMake(220, 310, 80, 34);
//    [ipStyleBtn setBackgroundColor:[UIColor grayColor]];
    [ipStyleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [ipStyleBtn setTitle:@"自动获取" forState:UIControlStateNormal];
    [ipStyleBtn addTarget:self action:@selector(ipSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:ipStyleBtn];
    
    UILabel *securtyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 350, 200, 34)];
    securtyLabel.text = @"路由器无线认证安全类型:";
    [self.view addSubview:securtyLabel];
    securtyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    securtyBtn.frame = CGRectMake(220, 350, 80, 34);
    [securtyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [securtyBtn setTitle:@"WPA*" forState:UIControlStateNormal];
    [securtyBtn addTarget:self action:@selector(securtySelectAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:securtyBtn];
    self.identifify = @"";

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
    startBtn.frame = CGRectMake(80, 420, 160, 40);
    [startBtn setBackgroundImage:[UIImage imageNamed:@"kaishipeizhi_anniu@2x"] forState:UIControlStateNormal];
    [startBtn setTitle:@"开始配置" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startConfigure) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
}

- (void)backBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//获取WiFi名称
- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
//    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
//        NSLog(@"%@ => %@", ifnam, info);
        NSString *BSSID = [info objectForKey:@"BSSID"];
//        NSLog(@"BSSID:%@",BSSID);
        self.wifiBssid = BSSID;
//        NSString *SSIDDATAT = [info objectForKey:@"SSIDDATA"];
//        NSLog(@"SSIDDATA:%@",SSIDDATAT);
//        NSData *ssiddata = [info objectForKey:@"SSIDDATA"];
//        NSString *ssidda = [NSString stringWithFormat:@"%@",ssiddata ];
//        NSLog(@"ssiddata:%@",ssidda);
        if (info && [info count]) { break; }
    }
    NSString *SSID = [info objectForKey:@"SSID"];
    return SSID;
}

//开始配置
- (void)startConfigure
{
    //判断扫描到的二维码是否符合设备ID
    if ([self.deviceID hasPrefix:@"1100"]) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备ID不合法" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
        return ;
    }
    else if ([deviceDetailF.text isEqualToString:@""]||[SSIDPWF.text isEqualToString:@""]||[SSIDPWFconfirm.text isEqualToString:@""]) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备描述或密码不能为空" message:@"设备描述或密码不能为空" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
        return ;
    }else if (![SSIDPWF.text isEqualToString:SSIDPWFconfirm.text])
    {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"密码输入不一致" message:@"密码输入不一致" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
        return ;
    }else if (deviceDetailF.text.length > 12) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备名称不能超过12个字符" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
        return;
    }
    //向Baidu服务器注册设备
//    NSData *data = [URLstr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *des = [deviceDetailF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSString *descc = [NSString stringWithUTF8String:[desc UTF8String]];
    NSString *strWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)des, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
                                                  //https://pcs.baidu.com/rest/2.0/pcs/device?method=register&deviceid=123456&access_token=52.88be325d08d983f7403be8438c0c1eed.2592000.1403337720.1812238483-2271149&device_type=1&desc=摄像头描述
    NSString *URLstr = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=register&deviceid=%@&access_token=%@&device_type=1&desc=%@",self.deviceID,self.access_token,strWithUTF8];
    NSLog(@"urlSTR:%@",URLstr);
//    return ;
    [self isLoadingView];

    [[AFHTTPRequestOperationManager manager] POST:URLstr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //--------------------向Baidu注册成功，隐藏loginAlterView-------------------------
//        [loginAlterView dismissWithClickedButtonIndex:0 animated:YES];
        
        NSDictionary *dict = (NSDictionary *)responseObject;
//        NSLog(@"dict:%@",dict);
        NSString *stream_id = [dict objectForKey:@"stream_id"];
        NSLog(@"注册stream_id:%@",stream_id);
        [_loadingView hide:YES];

        [self connectToWifi];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"==========注册失败===============");
        //--------------------向Baidu注册成功，隐藏loginAlterView-------------------------
//        [loginAlterView dismissWithClickedButtonIndex:0 animated:YES];
        NSDictionary *errorDict = [error userInfo];
//        NSLog(@"dict:%@",errorDict);
        [_loadingView hide:YES];

        NSString *NSLocalizedDescription = [errorDict objectForKey:@"NSLocalizedDescription"];
        NSLog(@"NSLocalizedDescription:%@",NSLocalizedDescription);//Request failed: forbidden (403)
        if ([NSLocalizedDescription rangeOfString:@"403"].location) {
            UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"设备已经注册过了" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errorView show];
            return ;
        }else if ([NSLocalizedDescription rangeOfString:@"503"].location)
        {
            UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"添加设备出错或网络问题" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errorView show];
            return ;
        }else if ([NSLocalizedDescription rangeOfString:@"400"].location)
        {
            UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"错误信息" message:@"访问的参数错误" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errorView show];
            return ;
        }
        return ;
    }];
    
//    loginAlterView = [[UIAlertView alloc] initWithTitle:nil message:@"载入中\n请稍后……" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
//    [loginAlterView show];
}

- (void)connectToWifi
{
    nextAlertview = [[UIAlertView alloc] initWithTitle:@"连接设备AP" message:@"1.请切换到“系统设置”>>“无线局域网”\n2.连接Joyshow开头的摄像头热点,(密码为123456789)\n3.切换回此页面，点击下一步" delegate:self cancelButtonTitle:@"下一步" otherButtonTitles:nil, nil];
    nextAlertview.delegate = self;
    [nextAlertview show];
    
}
//- (void)loginAlterViewDismiss:(id)sender
//{
//
//}

//32位MD5加密方式
- (NSString *)getMd5_32Bit_String:(NSString *)srcString{
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
}

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
    if ([[self fetchSSIDInfo]hasPrefix:@"Joyshow" ]) {
        [self openUDPServer];
        _loadingView.hidden = NO;
//        if (hexOrAscii.hidden) {
//            self.wepStyle = @"1";
//        }
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
        const char *str2 = [self.userID UTF8String];
        
        NSString *userName = [NSString stringWithCString:str2 encoding:NSUTF8StringEncoding];
        
        NSString *dataStr = [NSString stringWithFormat:@"1%@%@%@%@%@%@%@2%@%@%@%@%@",self.wifiBssid,SSIDF.text,self.security,self.identifify,SSIDPWF.text,userName,self.access_token,self.wepStyle,self.dhcp,self.ipaddr,self.mask,self.gateway];
        NSLog(@"dataStr:%@",dataStr);
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"1",@"opcode",//1为注册
                                  self.wifiBssid,@"bssid",//
                                  SSIDF.text,@"ssid",//WiFi名称
                                  self.security,@"security",//加密方式
                                  self.identifify,@"identify",//二次加密的密码
                                  SSIDPWF.text,@"pwd",//WiFi密码
                                  userName,@"userId",//百度用户名
                                  self.access_token,@"accessToken",//accessToken
                                  @"2",@"osType",//2为iOS平台
                                  self.wepStyle,@"hexAscii",//16进制或ascll
                                  self.dhcp,@"dhcp",//1为自动
                                  self.ipaddr,@"ipaddr",//ip
                                  self.mask,@"mask",//掩码
                                  self.mask,@"geteway",//路由器
                                  @"",@"url",//保留URL
                                  @"",@"reserved",nil];//保留参数
        NSLog(@"dataDict:%@",dataDict);
        NSString *md5String = [self getMd5_32Bit_String:dataStr];//得到md5加密后的32位字符串
        NSLog(@"md5String:%@",md5String);//0ea7ccca8f7eeefb255e1931cb1409aa
        
        NSMutableString *md5exchangeString = [self exchangeString:md5String];//1,6;4,13;21,29;20,25交换
        NSLog(@"md5exchangeString:%@",md5exchangeString);
        NSInteger length = dataStr.length;//data的长度
        NSString *md5Length = [NSString stringWithFormat:@"%ld",(long)length];
        NSDictionary *headDict = [NSDictionary dictionaryWithObjectsAndKeys:md5Length,@"length",md5exchangeString,@"verify", nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:headDict,@"head",dataDict,@"data", nil];
        NSString *sendString = [dict JSONString];
        [self sendMassage:sendString];
//        configurationTipView = [[UIAlertView alloc] initWithTitle:@"配置摄像头" message:@"正在配置，请稍后……" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
//        [configurationTipView show];
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
//	self.udpSocket=tempSocket;
    //	[tempSocket release];
	//绑定端口
	NSError *error = nil;
	[self.udpSocket bindToPort:7860 error:&error];
    
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
	NSMutableString *sendString=[NSMutableString stringWithCapacity:100];
	[sendString appendString:message];
	//开始发送
	BOOL res = [self.udpSocket sendData:[sendString dataUsingEncoding:NSUTF8StringEncoding]
								 toHost:@"192.168.62.1"
								   port:7860
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
    NSLog(@"host---->%@",host);
    _loadingView.hidden = YES;
   	//接收到数据回调，显示出来
	NSString *info=[[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
	NSLog(@"UDP代理接收到的数据：%@",info);
	//已经处理完毕
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"配置成功"
													message:@"1.请切换到“系统设置”>>“无线局域网”\n2.断开Joyshow开头的摄像头热点\n3.切换回此页面，再次刷新页面"
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
    [self backBtn:nil];
//    [configurationTipView dismissWithClickedButtonIndex:0 animated:YES];
	return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	//无法发送时,返回的异常提示信息
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
//    [self presentViewController:ipVC animated:YES completion:nil];
    [[SliderViewController sharedSliderController].navigationController pushViewController:ipVC animated:YES];
}

//路由器无线加密方式
- (void)securtySelectAction:(id)sender
{
    SecurtyStyleViewController *securtyVC = [[SecurtyStyleViewController alloc] init];
    securtyVC.delegate = self;
    securtyVC.selectIndex = securtyIndexPath;
    securtyVC.pwd = self.identifify;
    [[SliderViewController sharedSliderController].navigationController pushViewController:securtyVC animated:YES];
}
#pragma mark - delegate
//IP模式代理
- (void)ipObtainStyle:(NSInteger)integer withStaticParameter:(NSDictionary *)ipParameter
{
    IPIndexPath = integer;
    if (integer) {
        NSLog(@"1");
//        NSString *subnetMask = [ipParameter objectForKey:@"subnetMask"];
//        NSLog(@"subnetmask:%@",subnetMask);
        ipParameraDict = ipParameter;
        [ipStyleBtn setTitle:@"手动设置" forState:UIControlStateNormal];
        
    }else
    {
        NSLog(@"0");
        [ipStyleBtn setTitle:@"自动获取" forState:UIControlStateNormal];
    }
}
//无线加密方式
- (void)securtyStyleSelect:(NSString *)securtyStyle withIndex:(NSInteger)index withpwd:(NSString *)pwd
{
    NSLog(@"securtyStyle:%@,index:%d,pwd:%@",securtyStyle,index,pwd);
    securtyIndexPath = index;
    self.identifify = pwd;
    [securtyBtn setTitle:securtyStyle forState:UIControlStateNormal];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (deviceDetailF == textField) {
        [SSIDPWF becomeFirstResponder];
    }else if(SSIDPWF == textField)
    {
        [SSIDPWFconfirm becomeFirstResponder];
    }
    return YES;
}

- (void)isLoadingView
{
    _loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_loadingView];
    
    _loadingView.delegate = self;
    _loadingView.labelText = @"loading";
    _loadingView.detailsLabelText = @"向服务器注册中，请稍后……";
    _loadingView.square = YES;
    [_loadingView show:YES];
    _loadingView.color = [UIColor grayColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view setNeedsDisplay];
}

@end
